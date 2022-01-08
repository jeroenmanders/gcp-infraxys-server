package main

import (
	billing "cloud.google.com/go/billing/apiv1"
	"context"
	"flag"
	"fmt"
	"google.golang.org/api/iterator"
	billingpb "google.golang.org/genproto/googleapis/cloud/billing/v1"
	"html/template"
	"log"
	"net/http"
	"os"
)

type ConfigValues struct {
	BillingAccounts map[string]string
}

type ConfigData struct {
	BillingAccount string
	Domain         string
	ParentFolderId string
}

var server http.Server

func showHomePage(w http.ResponseWriter, _ *http.Request) {
	billingAccounts, err := getBillingAccounts()
	if err != nil {
		fmt.Printf("Error: %s", err.Error())
	}
	data := &ConfigValues{
		BillingAccounts: billingAccounts,
	}
	//fmt.Printf("%+v", data.BillingAccounts)

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
	data.ParentFolderId = req.FormValue("parentFolderId")

	fileData := fmt.Sprintf(`billing_account_id = "%s"
domain = "%s"
parent_folder_id = "%s"
`, data.BillingAccount, data.Domain, data.ParentFolderId)

	fi, err := os.OpenFile("../test.auto.tfvars", os.O_RDWR|os.O_CREATE, 0600)

	if err != nil {
		fmt.Println("Error with Open()", err)
		return
	}

	defer func() { _ = fi.Close() }()
	_, err = fi.Write([]byte(fileData))
	if err != nil {
		fmt.Println("Error with Open()", err)
		return
	}

	t, _ := template.ParseFiles("templates/config.html")
	if err = t.Execute(w, data); err != nil {
		fmt.Printf("Error parsing template: %v", err.Error())
	}

}

func stop(_ http.ResponseWriter, _ *http.Request) {
	_ = server.Shutdown(context.Background())
}

func getBillingAccounts() (map[string]string, error) {
	accounts := make(map[string]string)

	ctx := context.Background()
	billingClient, err := billing.NewCloudBillingClient(ctx)

	defer func() { _ = billingClient.Close() }()
	if err != nil {
		return nil, err
	}

	billingReq := &billingpb.ListBillingAccountsRequest{}
	it := billingClient.ListBillingAccounts(ctx, billingReq)
	for {
		resp, err := it.Next()
		if resp == nil {
			break
		}
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, err
		}
		if resp.Open {
			//fmt.Printf("Adding billing account '%s'.\n", resp.DisplayName)
			accounts[resp.Name] = resp.DisplayName
		} else {
			fmt.Printf("Not adding billing account '%s' because it's not open.\n", resp.DisplayName)
		}
	}

	return accounts, nil
}

func main() {
	port := flag.Int("port", 8080, "Provide a port for this service to listen on")
	webHost := flag.String("web-host", "", "Provide the web-host to reach this server on")
	flag.Parse()
	portArg := fmt.Sprintf(":%d", *port)
	webUrl := fmt.Sprintf("https://%d-%s/?authuser=0", *port, *webHost)
	fmt.Println("Starting service on port ", portArg)
	m := http.NewServeMux()
	server = http.Server{Addr: portArg, Handler: m}
	m.HandleFunc("/", showHomePage)
	m.HandleFunc("/config", postConfig)
	m.HandleFunc("/stop", postConfig)
	fmt.Printf("Please open a new browser tab with url: %s\n", webUrl)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}
	log.Printf("Done")
}
