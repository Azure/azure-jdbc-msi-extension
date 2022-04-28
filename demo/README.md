# Azure JDBC MSI Demo application
This project demonstrates how to connect to a database using the Azure JDBC MSI.

## Prerequisites
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
* [Terraform](https://www.terraform.io/downloads.html)
* Postgresql client: psql
* Mysql client: mysql. 
* Assuming a Linux environment. All tests performed on Ubuntu 20.4 on WSL2.
* Azure subscription

## Setup
* Assuming that user already has an Azure subcription.
* On terminal:
    * az login
    * cd demo/deployment folder
    * execute

```bash
./deploy-wizard.sh
```
This command returns the parameters to deploy the demo
```bash
Usage: ./deploy-wizard.sh <database> <application_hosting> <location> <name> <identity_type> <aad_administrator_name>
<database>            -> mysql | postgresql
<application_hosting> -> appservice | spring
<location>            -> your Azure preferred location
<name>                -> your Application name. All Azure resources will be created based on this name
<identity_type>       -> SystemAssigned | UserAssigned. Managed Identity type: system or user assigned. Azure Spring Cloud only supports system assigned identity
<aad admin username>  -> your Azure AD postgresql admin username. youruser@tenant.onmicrosoft.com / youruser@yourdomain.com.
```
For instance to deploy mysql database on appservice using user assigned identity:
```bash
./deploy-wizard.sh mysql appservice eastus myapp UserAssigned myadmin@mytenant.onmicrosoft.com
```

This scripts will create the following resources:
* A resource group
* A database server. It could be:
  * Azure Database for Mysql server single instance with an AAD administrator
  * Azure Database for Postgresql server single instance with an AAD administrator
* A hosting environment:
  * Azure App Service with a System Managed Identity or User Assigned Identity and System Assigned Identity.
  * Azure Spring Cloud with a System Managed Identity. Currently, Azure Spring Cloud only supports System Assigned Identity.
* In case of selecting User Assigned Identity, a Managed Identity will be created.

## How deployment works
The deployment is based on Terraform, so if the scripts parameters change then the resources will be destroyed and recreated accordingly.
The deployment is done in three steps:
* First step is to create the resources. It also includes to configure the applications with a database connection string that includes the corresponding plugin, the database username and other parameters if required.
* Second step is to create the database logins associated to the managed identities and grant the permissions to the database.
* Third step is to deploy a demo application.

## Run the application
The terraform deployment has the following parameter as an output _application_url_. Open that url on a browser or execute curl <url> to test the application. The url should be something like https://app-[name]-dev.azurewebsites.net/ for appservice and https://asc-[name]-dev-app-[name].azuremicroservices.io/ for spring. It can be retrieved from Azure portal in any case.

When opening the url the result should show the database server time.

For testing purposes the application also provides the access token used to connect to the database. To retrieve it open https://[url]/token



## References
* [Terraform](https://www.terraform.io/)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

