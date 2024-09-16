# streamlit_appservice
## instructions
get the acr login server from terraform output and store in local envvar
```bash
export ACR_SERVER=$(terraform output -raw acr_login_server)
```

build the docker image and tag image with slentra
```bash
docker build -t $ACR_SERVER/slentra:latest .
```

login to acr
```bash
az acr login --name $ACR_SERVER
```

push the image to acr
```bash
docker push $ACR_SERVER/slentra:latest
```

> Note: If the container app already exists, then copy the full id from the console output and replace the id in the below command
> ```bash
> terraform import azurerm_container_app.app /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-streamlit/providers/Microsoft.Web/sites/app-name
> ```