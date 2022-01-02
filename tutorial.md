# Setup Infraxys Server on GCP

This walkthrough assists with the setup of Infraxys Server in GCP.

## Prerequisites


[//]: # (<walkthrough-project-setup billing="true"></walkthrough-project-setup>)

### Application Default credentials should be set 

This account should have permission to create projects.  

<TODO: specify exact list of permissions needed>. 

Run the following command to validate this:
```bash
gcloud auth list;
```
If no account is active, then login using:

```bash
gcloud auth application-default login;
```

### Start the configuration

- Run setup.sh:
```bash
./setup.sh;
```


[//]: # (```bash)
[//]: # (echo "{{project-id}}";)
[//]: # (```)

[//]: # (<walkthrough-editor-open-file filePath="cloudshell_open/gcp-services-tutorial/variables.auto.tfvars.example">Open README.md</walkthrough-editor-open-file>)
[//]: # (<walkthrough-footnote>Using project {{project-id}}</walkthrough-footnote>)

[//]: # (## Step 3)

[//]: # ()
[//]: # (- Some text in step 2)
