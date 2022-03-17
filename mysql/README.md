# README

## How to run the test?

You can either run the test using its main method and then you pass in the JDBC URL directly, or if you are running the test using JUnit integration you will have to pass the JDBC URL using the -Durl=xxx syntax.

## What does the JDBC URL look like?

```
jdbc:mysql://hostname:portNumber/databaseName?sslMode=REQUIRED&defaultAuthenticationPlugin=com.azure.mysql.auth.plugin.AzureMySqlMSIAuthenticationPlugin&authenticationPlugins=com.azure.mysql.auth.plugin.AzureMySqlMSIAuthenticationPlugin&user=username
```

### Required modifiable properties

1. `hostname` is the hostname of the MySQL instance
2. `portNumber` is the port number of the MySQL instance
3. `databaseName` is the name of the MySQL database to connect to
4. `username` is the username to connect with (format should be `user@tenant@hostname-only`)

Note `hostname-only` is the first part of the FQDN hostname.

### Required fixed properties

* `sslMode` needs to be set to REQUIRED.
* `defaultAuthenticationPlugin` needs to be set to the implementing class name in this case `com.azure.mysql.auth.plugin.AzureMySqlMSIAuthenticationPlugin`
* `authenticationPlugins` needs to be set to `com.azure.mysql.auth.plugin.AzureMySqlMSIAuthenticationPlugin`

## Background information

* https://docs.microsoft.com/en-us/azure/mysql/howto-connect-with-managed-identity 
* https://dev.mysql.com/doc/connector-j/8.0/en/connector-j-connp-props-authentication.html
* https://techcommunity.microsoft.com/t5/azure-database-for-mysql-blog/how-to-connect-to-azure-database-for-mysql-using-managed/ba-p/1518196#:~:text=%20How%20to%20connect%20to%20Azure%20Database%20for,the%20Managed%20Identity%20GUID%20and%20then...%20More%20
