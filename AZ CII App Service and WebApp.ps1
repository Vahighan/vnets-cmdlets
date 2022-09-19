az group create --name myResourceGroup --location westeurope 

#note: myResourceGroup==build-agents-01

#pushing image to registry
 az acr create --name ContainerReg --resource-group build-agents-01 --sku Basic --admin-enabled true

    az acr credential show --resource-group build-agents-01 --name ContainerReg

#configuring app service to deploy image from registry
az appservice plan create 
    --resource-group build-agents-01 
    --name Appservice
    --is-linux
    --location westeurope 
    --sku Basic

    az webapp create --resource-group build-agents-01 --plan Appservice --name Webapp --deployment-container-image-name ContainerReg.azurecr.io/appsvc-tutorial-custom-image:latest

   az webapp config appsettings set --resource-group build-agents-01 --name Webapp --settings WEBSITES_PORT=8000

 az account show --query id --output tsv

 az role assignment create --assignee <principal-id> --scope /subscriptions/0327ac12-a6a5-463b-bd9b-6fdc2b473b00/resourceGroups/build-agents-01/providers/Microsoft.ContainerRegistry/registries/ContainerReg --role "AcrPull"

az resource update --ids /subscriptions/0327ac12-a6a5-463b-bd9b-6fdc2b473b00/resourceGroups/myResourceGroup/providers/Microsoft.Web/sites/Webapp/config/web --set properties.acrUseManagedIdentityCreds=True

az webapp config container set --name Webapp --resource-group build-agents-01 --docker-custom-image-name ContainerReg.azurecr.io/appsvc-tutorial-custom-image:latest --docker-registry-server-url https://ContainerReg.azurecr.io

#automation - continuous deployment

az webapp deployment container config --enable-cd true --name Webapp --resource-group build-agents-01 --query CI_CD_URL --output tsv

az acr webhook create --name appserviceCD --registry ContainerReg --uri '<ci-cd-url>' --actions push --scope appsvc-tutorial-custom-image:latest

#testing whether webhook is configured correctly
eventId=$(az acr webhook ping --name appserviceCD --registry <registry-name> --query id --output tsv)
az acr webhook list-events --name appserviceCD --registry <registry-name> --query "[?id=='$eventId'].eventResponseMessage"