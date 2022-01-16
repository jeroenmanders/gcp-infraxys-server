package main

import (
	"context"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/joho/godotenv"

	"jeroenmanders/gcp-infraxys-server/config-collector/config"

	billing "cloud.google.com/go/billing/apiv1"
	"google.golang.org/api/iterator"
	billingpb "google.golang.org/genproto/googleapis/cloud/billing/v1"

	resourcemanager "cloud.google.com/go/resourcemanager/apiv3"
	resourcemanagerpb "google.golang.org/genproto/googleapis/cloud/resourcemanager/v3"
)

type HomePageValues struct {
	Organizations      map[string]string
	BillingAccounts    map[string]string
	DefaultProjectName string
}

type ConfigData struct {
	Organization   string
	BillingAccount string
	ProjectName    string
	ParentFolderID string
}

var server http.Server
var conf config.Config

func showHomePage(w http.ResponseWriter, _ *http.Request) {
	organizations, err := getOrganizations()
	if err != nil {
		fmt.Printf("Error retrieving organizations: %s", err.Error())
	}

	billingAccounts, err := getBillingAccounts()

	if err != nil {
		fmt.Printf("Error retrieving billing accounts: %s", err.Error())
	}

	data := &HomePageValues{
		Organizations:      organizations,
		BillingAccounts:    billingAccounts,
		DefaultProjectName: conf.DefaultProjectName,
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
	data.Organization = strings.TrimLeft(req.FormValue("organization"), "organizations/")
	data.BillingAccount = strings.TrimLeft(req.FormValue("billingAccount"), "billingAccounts/")
	data.ProjectName = req.FormValue("projectName")
	data.ParentFolderID = req.FormValue("parentFolderID")

	fileData := fmt.Sprintf(`org_id = "%s"
billing_account_id = "%s"
project_name = "%s"
parent_folder_id = "%s"
`, data.Organization, data.BillingAccount, data.ProjectName, data.ParentFolderID)

	log.Printf("Writing file %s\n", conf.VarsFile)
	fi, err := os.OpenFile(conf.VarsFile, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0600)

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

func getOrganizations() (map[string]string, error) {
	organizations := make(map[string]string)

	log.Println("Retrieving organizations.")
	ctx := context.Background()
	c, err := resourcemanager.NewOrganizationsClient(ctx)
	if err != nil {
		log.Printf("Error creating organizations client: %s", err.Error())
		return nil, err
	}

	defer func() { _ = c.Close() }()
	req := &resourcemanagerpb.SearchOrganizationsRequest{
		// TODO: Fill request struct fields.
		// See https://pkg.go.dev/google.golang.org/genproto/googleapis/cloud/resourcemanager/v3#SearchOrganizationsRequest.
	}
	it := c.SearchOrganizations(ctx, req)
	for {
		resp, err := it.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Printf("Error looping organizations: %s", err.Error())
			return nil, err
		}
		if resp.State == resourcemanagerpb.Organization_ACTIVE {
			organizations[resp.Name] = resp.DisplayName
		} else {
			log.Printf("Skipping not-active organization %s: ", resp.DisplayName)
		}
	}
	if len(organizations) == 0 {
		fmt.Println("No active organizations found.")
	}
	return organizations, nil
}

func getBillingAccounts() (map[string]string, error) {
	accounts := make(map[string]string)

	ctx := context.Background()
	log.Println("Retrieving billing accounts.")
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
			break
		}

		if err == iterator.Done {
			log.Println("Done with billing accounts.")
			break
		}

		if err != nil {
			fmt.Printf("Error with billing accounts: %s.\n", err.Error())
			return nil, err
		}

		if resp.Open {
			accounts[resp.Name] = resp.DisplayName
		} else {
			log.Printf("Not adding billing account '%s' because it's not open.\n", resp.DisplayName)
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
	conf = *config.New()
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
