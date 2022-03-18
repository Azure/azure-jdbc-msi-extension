# README

## How to run the test?

You can either run the test using its main method and then you pass in the JDBC 
URL directly, or if you are running the test using JUnit integration you will 
have to pass the JDBC URL using the -Durl=xxx syntax.

Note only user-assigned managed identity can be supported at this time because
the JDBC driver does not have a username callback.

## What does the JDBC URL look like?

```
jdbc:postgresql://hostname:portNumber/databaseName?sslmode=require&authenticationPluginClassName=com.azure.postgresql.auth.plugin.AzurePostgresMSIAuthenticationPlugin&user=username
```

### Required modifiable properties

1. `hostname` is the hostname of the PostgreSQL instance
2. `portNumber` is the port number of the PostgreSQL instance
3. `databaseName` is the name of the PostgreSQL database to connect to
4. `username` is the username to connect with (format should be `user@hostname-only`)

Note `hostname-only` is the first part of the FQDN hostname.

### Required fixed properties

* `sslmode` needs to be set to `require`.
* `authenticationPluginClassName` needs to be set to `com.azure.postgresql.auth.plugin.AzurePostgresqlMSIAuthenticationPlugin`

## Background information

* https://docs.microsoft.com/en-us/azure/postgresql/howto-connect-with-managed-identity
* https://github.com/spaceteams/postgres-rds-authentication-plugin
* https://github.com/pgjdbc/pgjdbc/blob/master/pgjdbc/src/main/java/org/postgresql/plugin/AuthenticationPlugin.java
