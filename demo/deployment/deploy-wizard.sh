# if any of the following fails, the script fails
set -e

function createDatabaseUser() {
    database_type=$1
    echo "Creating users for database type: $database_type"

    database_fqdn=$(terraform output database_fqdn | tr -d '"')
    admin_username=$(terraform output admin_username | tr -d '"')
    username=$(terraform output application_username | tr -d '"')
    application_id=$(terraform output application_identity | tr -d '"')
    dbname=$(terraform output database_name | tr -d '"')
    jdbc_url=$(terraform output jdbc_url | tr -d '"')
    database_host_name=$(terraform output database_host_name | tr -d '"')

    user_id=%%user_id%%
    login_name=%%login_name%%
    tdbname=%%dbname%%

    if [ "$database_type" == "postgresql" ]; then
        rm -f tmp_users_processed.sql
        # the following command creates a sql file from the template, replacing the username and the azure application id
        # very important: postgresql uses the application id, not the object id
        sed "s|$user_id|$application_id|g" ./../postgresql/postgresql_create_user.sql | sed "s|$login_name|$username|g" | sed "s|$tdbname|$dbname|g" >tmp_users_processed.sql
        cat tmp_users_processed.sql && echo

        export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken)

        psql "host=$database_fqdn port=5432 dbname=$dbname user=$admin_username dbname=postgres sslmode=require" <tmp_users_processed.sql
    elif [ "$database_type" == "mysql" ]; then
        rm -f tmp_users_processed.sql
        # the following command creates a sql file from the template, replacing the username and the azure application id
        # very important: mysql and postgresql uses the application id, not the object id
        sed "s|$user_id|$application_id|g" ./../mysql/mysql_create_user.sql | sed "s|$login_name|$username|g" >tmp_users_processed.sql
        cat tmp_users_processed.sql && echo
        # executes the user creation
        mysql -h "$database_fqdn" --user "$admin_username" --enable-cleartext-plugin --password="$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken)" <tmp_users_processed.sql
    fi

    # cleanup
    rm -f tmp_users_processed.sql

    # connection string
    echo "Managed identity connection string: $jdbc_url&user=$username@$database_host_name"
    echo "AAD admin connection string:        $jdbc_url&user=$admin_username"

}

function print_usage() {
    echo "Usage: $1 <database> <application_hosting> <location> <name> <identity_type> <aad_administrator_name> <aad_domain>"
    echo "<database>                -> mysql | postgresql"
    echo "<application_hosting>     -> appservice | spring"
    echo "<location>                -> your Azure preferred location"
    echo "<name>                    -> your Application name. All Azure resources will be created based on this name"
    echo "<identity_type>           -> SystemAssigned | UserAssigned. Managed Identity type: system or user assigned. Azure Spring Cloud only supports system assigned identity"
    echo "<aad_administrator_name>  -> your Azure AD admin username. youruser@tenant.onmicrosoft.com / youruser@yourdomain.com."
    echo "<aad_domain>              -> your Azure AD domain. tenant.onmicrosoft.com / yourdomain.com"
}

function print_local_test() {
    echo
    echo "To test the application locally, please configure the local profile."
    echo "You can use the Azure AD administrator account."
    echo "The deployment script configured the Azure CLI account as Azure AD administrator."
    echo "Configure database.connection.url and spring.datasource.url"
}

if (($# < 6)); then
    print_usage "$0"
else
    database=$1
    application_hosting=$2
    location=$3
    name=$4
    identity_type=$5
    aad_administrator_name=$6
    if [ "$database" == "mysql" ] && [ $# -lt 7 ]; then
        echo "MySQL requires the domain name as well"
        print_usage "$0"
        exit 1
    else
        aad_domain=$7
    fi

    cd terraform
    echo "======================================================"
    echo "*********** Deploying infrastructure *****************"
    echo "======================================================"
    echo "aad_administrator_name: $aad_administrator_name"
    terraform init
    terraform apply -var location="$location" \
        -var application_name="$name" \
        -var database_type="$database" \
        -var hosting_type="$application_hosting" \
        -var identity_type="$identity_type" \
        -var aad_administrator_name="$aad_administrator_name" \
        -var aad_domain="$aad_domain" \
        -auto-approve

    resource_group=$(terraform output resource_group | tr -d '"')
    application_name=$(terraform output application_name | tr -d '"')

    if [ "$application_hosting" == "spring" ]; then
        spring_cloud_service_name=$(terraform output spring_cloud_service_name | tr -d '"')
    fi

    echo "======================================================"
    echo "***** Create managed identity users in database ***** "
    echo "======================================================"
    createDatabaseUser "$database"
    cd ../../..
    echo "======================================================"
    echo "****************  Build application  *****************"
    echo "======================================================"
    mvn clean package -DskipTests
    if [ "$application_hosting" == "appservice" ]; then
        echo "======================================================"
        echo "****** Deploying application to app service  *********"
        echo "======================================================"
        az webapp deploy --resource-group "$resource_group" \
            --name "$application_name" \
            --src-path ./demo/target/azure-jdbc-msi-demo-sample-0.0.1-SNAPSHOT.jar \
            --type jar
    elif [ "$application_hosting" == "spring" ]; then
        echo "======================================================"
        echo "**** Deploying application to Azure Spring Cloud  ****"
        echo "======================================================"
        az spring-cloud app deploy --service "$spring_cloud_service_name" \
            --resource-group "$resource_group" \
            --name "$application_name" \
            --runtime-version Java_11 \
            --no-wait \
            --artifact-path ./demo/target/azure-jdbc-msi-demo-sample-0.0.1-SNAPSHOT.jar
    else
        echo "======================================================"
        echo "Unknown application hosting: $application_hosting"
        echo "======================================================"
        exit 1
    fi
    print_local_test
fi
