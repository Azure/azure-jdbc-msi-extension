cd terraform/app-service
terraform init
terraform apply
mysql_host=$(terraform output database_host | tr -d '"')
admin_username=$(terraform output admin_username | tr -d '"')
username=$(terraform output mysql_application_username | tr -d '"')
application_id=$(terraform output application_identity | tr -d '"')
resource_group=$(terraform output resource_group | tr -d '"')
application_name=$(terraform output application_name | tr -d '"')
cd ../../
cd mysql
./prepare_user.sh $mysql_host $admin_username $application_id $username

cd ../../..
mvn package -DskiptTests
az webapp deploy --resource-group $resource_group \
    --name $application_name \
    --src-path ./mysql-sample/target/azure-jdbc-msi-mysql-sample-0.0.1-SNAPSHOT.jar \
    --type jar