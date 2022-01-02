package main

import (
	billing "cloud.google.com/go/billing/apiv1"
	"context"
	"fmt"
	"google.golang.org/api/iterator"
	billingpb "google.golang.org/genproto/googleapis/cloud/billing/v1"
	"html/template"
	"net/http"
	"os"
)

type ConfigData struct {
	BillingAccounts map[string]string
}

func showInputForm(w http.ResponseWriter, req *http.Request) {
	billingAccounts, err := getBillingAccounts()
	if err != nil {
		fmt.Printf("Error: %s", err.Error())
	}
	data := &ConfigData{
		BillingAccounts: billingAccounts,
	}
	//fmt.Printf("%+v", data.BillingAccounts)

	t, _ := template.ParseFiles("webpage-template.html")
	t.Execute(w, data)
}

func postConfig(w http.ResponseWriter, req *http.Request) {
	if err := req.ParseForm(); err != nil {
		fmt.Fprintf(w, "ParseForm() err: %v", err)
		return
	}
	orgDomain := req.FormValue("orgDomain")
	parentFolderId := req.FormValue("parentFolderId")
	billingAccount := req.FormValue("billingAccount")
	fmt.Fprintf(w, "billlingAccount: %s\n", billingAccount)
	fmt.Fprintf(w, "orgDomain: %s\n", orgDomain)
	fmt.Fprintf(w, "parentFolderId: %s\n", parentFolderId)
	data := fmt.Sprintf(`billing_account_id = "%s"
domain = "%s"
parent_folder_id = "%s"
`, billingAccount, orgDomain, parentFolderId)
	fmt.Fprintf(w, data)

	fi, err := os.OpenFile("../test.auto.tfvars", os.O_RDWR|os.O_CREATE, 0600)

	if err != nil {
		fmt.Println("Error with Open()", err)
		return
	}
	defer fi.Close()
	_, err = fi.Write([]byte(data))
	if err != nil {
		fmt.Println("Error with Open()", err)
		return
	}
}

func getBillingAccounts() (map[string]string, error) {
	accounts := make(map[string]string)

	ctx := context.Background()
	billingClient, err := billing.NewCloudBillingClient(ctx)

	defer billingClient.Close()
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
	fmt.Println("Starting service ...")
	http.HandleFunc("/", showInputForm)
	http.HandleFunc("/config", postConfig)
	http.ListenAndServe(":8090", nil)
}
