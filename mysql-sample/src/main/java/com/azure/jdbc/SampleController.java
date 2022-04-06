package com.azure.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SampleController {

    @GetMapping("/")
    public String getServerDate(){
        String result = "not executed";
        Connection connection;
        try {            
            String connectionString = "jdbc:mysql://mysql-msi-jdbc-dev.mysql.database.azure.com:3306/Db?sslMode=REQUIRED&useSSL=true&defaultAuthenticationPlugin=com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin&authenticationPlugins=com.azure.jdbc.msi.extension.mysql.AzureMySqlMSIAuthenticationPlugin&user=sqladmin@mysql-msi-jdbc-dev";
            connection = DriverManager.getConnection(connectionString);

            if (connection != null) {
                result = connection.prepareStatement("SELECT now() as now").executeQuery().getString("now");
                connection.close();
            } else {
                result = "Failed to connect.";
            }
        } catch (Exception e) {
            result = e.getMessage();
        }
        return result;
    }
    
}
