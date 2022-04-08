function deployAppService() {
    cd terraform/app-service
    terraform init
    terraform apply -var location=$1 -var application_name=$2 -var database_type=$3 -var aad_administrator_name=$4 -auto-approve
    cd ../../..
}

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
        sed "s|$user_id|$application_id|g" ./../../postgresql/postgresql_create_user.sql | sed "s|$login_name|$username|g" | sed "s|$tdbname|$dbname|g" >tmp_users_processed.sql
        cat tmp_users_processed.sql

        export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken)
        #port=5432 dbname=psqldb-fmiguel-msi-jdbc-dev user=postgresqladmin@psql-fmiguel-msi-jdbc-dev
        
        echo "host=$database_fqdn port=5432 dbname=$dbname user=$admin_username dbname=postgres sslmode=require"

        psql "host=$database_fqdn port=5432 dbname=$dbname user=$admin_username dbname=postgres sslmode=require" < tmp_users_processed.sql
    elif [ "$database_type" == "mysql" ]; then
        $file="./../../mysql/mysql_create_user.sql"
        rm -f tmp_users_processed.sql
        # the following command creates a sql file from the template, replacing the username and the azure application id
        # very important: mygresql uses the application id, not the object id
        sed "s|$user_id|$application_id|g" ./../../mysql/mysql_create_user.sql | sed "s|$login_name|$username|g" > tmp_users_processed.sql
        cat tmp_users_processed.sql
        # executes the user creation
        mysql -h $host --user $admin_username --enable-cleartext-plugin --password=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken) < tmp_users_processed.sql

    fi

    # cleanup
    rm -f tmp_users_processed.sql
}

function deploySpring() {
    cd terraform/azure-spring-cloud
    echo "Deploying Spring"
    terraform init
    terraform apply -var location=$1 -var application_name=$2 -var database_type=$3 -var aad_administrator_name=$4 -auto-approve

    resource_group=$(terraform output resource_group | tr -d '"')
    application_name=$(terraform output application_name | tr -d '"')
    spring_cloud_service_name=$(terraform output spring_cloud_service_name | tr -d '"')

    echo "Create managed identity users in database"
    createDatabaseUser $3
    cd ../..
    ls -la
    cd ../..
    ls -la
    mvn clean package -DskipTests 
    az spring-cloud app deploy --service $spring_cloud_service_name \
        --resource-group $resource_group \
        --name $application_name \
        --runtime-version Java_11 \
        --no-wait \
        --artifact-path ./demo/target/azure-jdbc-msi-demo-sample-0.0.1-SNAPSHOT.jar
}

if (($# < 3)); then
    echo "Usage: $0 <database> <application_hosting> <location> <name>"
    echo "<database>            -> mysql | postgresql"
    echo "<application_hosting> -> appservice | spring"
    echo "<location>            -> your Azure preferred location"
    echo "<name>                -> your Application name. All Azure resources will be created based on this name"
    echo "<aad admin username>  -> your Azure AD postgresql admin username. youruser@tenant.onmicrosoft.com / youruser@yourdomain.com. Only for postgresql"
else
    database=$1
    application_hosting=$2
    location=$3
    name=$4
    admin_username=$5
    if [ "$application_hosting" == "appservice" ]; then
        deployAppService $location $name $database $admin_username
    elif [ "$application_hosting" == "spring" ]; then
        deploySpring $location $name $database $admin_username
    else
        echo "Unknown database: $database"
    fi
fi
