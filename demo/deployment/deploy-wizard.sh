function deployMySql() {
  cd terraform/modules/mysql
  terraform init
  terraform apply -auto-approve
  cd ../../..
}

function deployPostgres() {
  echo "Deploying Postgres"
  docker run --name postgres -d postgres:9.6
}

if (($# < 3))
then
    echo "Usage: $0 <database> <application_hosting> <location> <name>"
    echo "<database>            -> mysql | postgresql"
    echo "<application_hosting> -> appservice | spring"
    echo "<location>            -> your Azure preferred location"
    echo "<name>                -> your Application name. All Azure resources will be created based on this name"
else
    database=$1
    application_hosting=$2
    location=$3
    name=$4
    if [ "$database" == "mysql" ]
    then
        deployMySql
    elif [ "$database" == "postgresql" ]
    then
       deployMySql
    else
        echo "Unknown database: $database"
    fi
fi
