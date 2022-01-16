package main

import (
	"context"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"

	"jeroenmanders/gcp-infraxys-server/config-collector/config"

	billing "cloud.google.com/go/billing/apiv1"
	"google.golang.org/api/iterator"
	billingpb "google.golang.org/genproto/googleapis/cloud/billing/v1"
)

type HomePageValues struct {
	BillingAccounts map[string]string
}

type ConfigData struct {
	BillingAccount string
	Domain         string
	ParentFolderID string
}

var server http.Server

func showHomePage(w http.ResponseWriter, _ *http.Request) {
	fmt.Println("In showHomePage")

	billingAccounts, err := getBillingAccounts()

	if err != nil {
		fmt.Printf("Error: %s", err.Error())
	}

	data := &HomePageValues{
		BillingAccounts: billingAccounts,
	}

	t, _ := template.ParseFiles("templates/homepage.html")
	if err = t.Execute(w, data); err != nil {
		fmt.Printf("Error: %v", err.Error())
	}
}

func postConfig(w http.ResponseWriter, req *http.Request) {
	if err := req.ParseForm(); err != nil {
		_, _ = fmt.Fprintf(w, "ParseForm() err: %v", err.Error())
		return
	}

	data := &ConfigData{}

	data.BillingAccount = req.FormValue("billingAccount")
	data.Domain = req.FormValue("orgDomain")
	data.ParentFolderID = req.FormValue("parentFolderID")

	fileData := fmt.Sprintf(`billing_account_id = "%s"
domain = "%s"
parent_folder_id = "%s"
`, data.BillingAccount, data.Domain, data.ParentFolderID)

	fi, err := os.OpenFile("../temp.auto.tfvars", os.O_RDWR|os.O_CREATE, 0600)

	if err != nil {
		fmt.Printf("Error opening output file: %s.\n", err.Error())
		return
	}

	defer func() { _ = fi.Close() }()

	if _, err = fi.WriteString(fileData); err != nil {
		fmt.Printf("Error writing to file: %s\n", err.Error())
		return
	}

	t, err := template.ParseFiles("templates/config.html")
	if err != nil {
		fmt.Printf("Error parsing config.html: %s.\n", err.Error())
		return
	}

	if err = t.Execute(w, data); err != nil {
		fmt.Printf("Error applying parsed template: %s", err.Error())
	}
}

func stop(w http.ResponseWriter, _ *http.Request) {
	fmt.Println("Stopping server")

	if f, ok := w.(http.Flusher); ok {
		f.Flush()
	}

	_ = server.Shutdown(context.Background())
}

func getBillingAccounts() (map[string]string, error) {
	accounts := make(map[string]string)

	ctx := context.Background()
	fmt.Println("Retrieving billing accounts.")
	billingClient, err := billing.NewCloudBillingClient(ctx)

	if err != nil {
		fmt.Printf("Error retrieving billing accounts: %s.", err.Error())
		return nil, err
	}

	defer func() { _ = billingClient.Close() }()

	billingReq := &billingpb.ListBillingAccountsRequest{}
	it := billingClient.ListBillingAccounts(ctx, billingReq)

	for {
		resp, err := it.Next()
		if resp == nil {
			fmt.Println("No more billing accounts.")
			break
		}

		if err == iterator.Done {
			fmt.Println("Done with billing accounts.")
			break
		}

		if err != nil {
			fmt.Printf("Error with billing accounts: %s.\n", err.Error())
			return nil, err
		}

		fmt.Println("Processing billing account")
		if resp.Open {
			fmt.Printf("Adding billing account '%s'.\n", resp.DisplayName)
			accounts[resp.Name] = resp.DisplayName
		} else {
			fmt.Printf("Not adding billing account '%s' because it's not open.\n", resp.DisplayName)
		}
	}

	if len(accounts) == 0 {
		fmt.Println("No billing accounts found. If you have access to billing accounts, then attribute 'quota_project_id' might be set in ~/.config/gcloud/application_default_credentials.json")
	}
	return accounts, nil
}

func init() {
	if err := godotenv.Load(".env.local"); err != nil {
		log.Print("No .env.local file found. Parameters have to be in environment variables.")
	}
}

func main() {
	conf := config.New()
	portArg := fmt.Sprintf(":%d", conf.Port)

	if conf.HostPort == 0 {
		conf.HostPort = conf.Port
	}

	var webURL string

	if conf.WebHost == "" {
		webURL = fmt.Sprintf("http://localhost:%d", conf.HostPort)
	} else {
		webURL = fmt.Sprintf("https://%d-%s/?authuser=0", conf.HostPort, conf.WebHost)
	}

	fmt.Printf("Starting service on port %d\n", conf.Port)

	m := http.NewServeMux()
	server = http.Server{Addr: portArg, Handler: m}

	m.HandleFunc("/", showHomePage)
	m.HandleFunc("/config", postConfig)
	m.HandleFunc("/stop", stop)

	fmt.Printf("Please open a new browser tab with url: %s\n", webURL)

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}

	log.Printf("Done")
}
