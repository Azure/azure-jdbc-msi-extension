file=mysql_create_user.sql
user_id=%%user_id%%
login_name=%%login_name%%

host=$1
admin_username=$2
sample_userid=$3
sample_login_name=$4

rm -f tmp_users_processed.sql
# the following command creates a sql file from the template, replacing the username and the azure application id
# very important: mysql uses the application id, not the object id
sed "s|$user_id|$sample_userid|g" $file | sed "s|$login_name|$sample_login_name|g" > tmp_users_processed.sql
cat tmp_users_processed.sql
# executes the user creation
mysql -h $host --user $admin_username --enable-cleartext-plugin --password=`az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken` < tmp_users_processed.sql

# cleanup
rm -f tmp_users_processed.sql