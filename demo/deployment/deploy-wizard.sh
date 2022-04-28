function createDatabaseUser() {
    database_type=$1
    echo "Creating users for database type: $database_type"

    database_fqdn=$(terraform output database_fqdn | tr -d '"')
    admin_username=$(terraform output admin_username | tr -d '"')
    username=$(terraform output application_username | tr -d '"')
    application_id=$(terraform output application_identity | tr -d '"')
    dbname=$(terraform output database_name | tr -d '"')

    user_id=%%user_id%%
    login_name=%%login_name%%
    tdbname=%%dbname%%

    if [ "$database_type" == "postgresql" ]; then
        rm -f tmp_users_processed.sql
        # the following command creates a sql file from the template, replacing the username and the azure application id
        # very important: postgresql uses the application id, not the object id
        sed "s|$user_id|$application_id|g" ./../postgresql/postgresql_create_user.sql | sed "s|$login_name|$username|g" | sed "s|$tdbname|$dbname|g" >tmp_users_processed.sql
        cat tmp_users_processed.sql

        export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken)
        
        psql "host=$database_fqdn port=5432 dbname=$dbname user=$admin_username dbname=postgres sslmode=require" <tmp_users_processed.sql
    elif [ "$database_type" == "mysql" ]; then
        rm -f tmp_users_processed.sql
        # the following command creates a sql file from the template, replacing the username and the azure application id
        # very important: mysql and postgresql uses the application id, not the object id
        sed "s|$user_id|$application_id|g" ./../mysql/mysql_create_user.sql | sed "s|$login_name|$username|g" >tmp_users_processed.sql
        cat tmp_users_processed.sql
        # executes the user creation
        mysql -h $database_fqdn --user $admin_username --enable-cleartext-plugin --password=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken) <tmp_users_processed.sql
    fi

    # cleanup
    rm -f tmp_users_processed.sql
}

function print_usage() {
    echo "Usage: $1 <database> <application_hosting> <location> <name> <identity_type> <aad_administrator_name>"
    echo "<database>            -> mysql | postgresql"
    echo "<application_hosting> -> appservice | spring"
    echo "<location>            -> your Azure preferred location"
    echo "<name>                -> your Application name. All Azure resources will be created based on this name"
    echo "<identity_type>       -> SystemAssigned | UserAssigned. Managed Identity type: system or user assigned. Azure Spring Cloud only supports system assigned identity"
    echo "<aad admin username>  -> your Azure AD postgresql admin username. youruser@tenant.onmicrosoft.com / youruser@yourdomain.com."
}

echo "args count: $#"
if (($# < 6)); then
    print_usage $0
else
    database=$1
    application_hosting=$2
    location=$3
    name=$4
    identity_type=$5
    aad_administrator_name=$6

    cd terraform
    echo "Deploying infrastructure"
    echo "aad_administrator_name: $aad_administrator_name"
    terraform init
    terraform apply -var location=$location \
        -var application_name=$name \
        -var database_type=$database \
        -var hosting_type=$application_hosting \
        -var identity_type=$identity_type \
        -var aad_administrator_name=$aad_administrator_name -auto-approve

    resource_group=$(terraform output resource_group | tr -d '"')
    application_name=$(terraform output application_name | tr -d '"')

    if [ "$application_hosting" == "spring" ]; then
        spring_cloud_service_name=$(terraform output spring_cloud_service_name | tr -d '"')
    fi

    echo "Create managed identity users in database"
    createDatabaseUser $database
    cd ../../..
    echo "Build application"
    mvn clean package -DskipTests
    if [ "$application_hosting" == "appservice" ]; then
        echo "Deploying application to app service"
        az webapp deploy --resource-group $resource_group \
            --name $application_name \
            --src-path ./demo/target/azure-jdbc-msi-demo-sample-0.0.1-SNAPSHOT.jar \
            --type jar
    elif [ "$application_hosting" == "spring" ]; then
        echo "Deploying applicatio to Azure Spring Cloud"
        az spring-cloud app deploy --service $spring_cloud_service_name \
            --resource-group $resource_group \
            --name $application_name \
            --runtime-version Java_11 \
            --no-wait \
            --artifact-path ./demo/target/azure-jdbc-msi-demo-sample-0.0.1-SNAPSHOT.jar
    else
        echo "Unknown application hosting: $application_hosting"
    fi
fi
