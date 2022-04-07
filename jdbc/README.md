# MySQL

## How to run the test?

You can either run the test using its main method and then you pass in the JDBC URL directly, or if you are running the test using JUnit integration you will have to pass the JDBC URL using the -Durl=xxx syntax.

Before connecting to Azure Database for MySQL, make sure you have [assigned the required privileges of the specific database](https://dev.mysql.com/doc/refman/8.0/en/grant.html#grant-database-privileges) to [the MySQL user for your managed identity](https://docs.microsoft.com/azure/mysql/howto-connect-with-managed-identity#creating-a-mysql-user-for-your-managed-identity).

## What does the JDBC URL look like?

```
jdbc:mysql://hostname:portNumber/databaseName?sslMode=REQUIRED&defaultAuthenticationPlugin=com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin&authenticationPlugins=com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin&user=username
```

### Required modifiable properties

1. `hostname` is the hostname of the MySQL instance
2. `portNumber` is the port number of the MySQL instance
3. `databaseName` is the name of the MySQL database to connect to
4. `username` is the username to connect with (format should be `user@tenant@hostname-only`)

Note `hostname-only` is the first part of the FQDN hostname.

### Required fixed properties

* `sslMode` needs to be set to REQUIRED.
* `defaultAuthenticationPlugin` needs to be set to the implementing class name in this case `com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin`
* `authenticationPlugins` needs to be set to `com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin`

## Background information

* https://docs.microsoft.com/azure/mysql/howto-connect-with-managed-identity 
* https://dev.mysql.com/doc/connector-j/8.0/en/connector-j-connp-props-authentication.html
* https://techcommunity.microsoft.com/t5/azure-database-for-mysql-blog/how-to-connect-to-azure-database-for-mysql-using-managed/ba-p/1518196#:~:text=%20How%20to%20connect%20to%20Azure%20Database%20for,the%20Managed%20Identity%20GUID%20and%20then...%20More%20


# PostgreSQL

# README

## How to run the test?

You can either run the test using its main method and then you pass in the JDBC
URL directly, or if you are running the test using JUnit integration you will
have to pass the JDBC URL using the -Durl=xxx syntax.

Before connecting to Azure Database for PostgreSQL, make sure you have [assigned the required privileges of the specific database](https://www.postgresql.org/docs/current/sql-grant.html) to [the PostgreSQL user for your managed identity](https://docs.microsoft.com/azure/postgresql/howto-connect-with-managed-identity#creating-a-postgresql-user-for-your-managed-identity).

Note only user-assigned managed identity can be supported at this time because
the JDBC driver does not have a username callback.

## What does the JDBC URL look like?

```
jdbc:postgresql://hostname:portNumber/databaseName?sslmode=require&authenticationPluginClassName=com.azure.jdbc.msi.extension.postgresql.AzurePostgresMSIAuthenticationPlugin&user=username
```

### Required modifiable properties

1. `hostname` is the hostname of the PostgreSQL instance
2. `portNumber` is the port number of the PostgreSQL instance
3. `databaseName` is the name of the PostgreSQL database to connect to
4. `username` is the username to connect with (format should be `user@hostname-only`)

Note `hostname-only` is the first part of the FQDN hostname.

### Required fixed properties

* `sslmode` needs to be set to `require`.
* `authenticationPluginClassName` needs to be set to `com.azure.jdbc.msi.extension.postgresql.AzurePostgresqlMSIAuthenticationPlugin`

## Background information

* https://docs.microsoft.com/azure/postgresql/howto-connect-with-managed-identity
* https://github.com/spaceteams/postgres-rds-authentication-plugin
* https://github.com/pgjdbc/pgjdbc/blob/master/pgjdbc/src/main/java/org/postgresql/plugin/AuthenticationPlugin.java
