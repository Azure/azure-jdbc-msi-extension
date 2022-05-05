package com.azure.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenRequestContext;
import com.azure.core.util.Configuration;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SampleController {

    @Value("${database.connection.url}")
    private String databaseConnectionString;

    @Value("${database.connection.username:}")
    private String databaseUserName;

    @Value("${database.connection.clientid:}")
    private String clientId;

    @GetMapping("/")
    public String getServerDate() {
        String result = "not executed";
        Connection connection;
        try {
            if (databaseUserName == null || databaseUserName.isEmpty()) {
                connection = DriverManager.getConnection(databaseConnectionString);
            } else {
                connection = DriverManager.getConnection(databaseConnectionString, databaseUserName, getAccessToken());
            }

            if (connection != null) {
                ResultSet queryResult = connection.prepareStatement("SELECT now() as now").executeQuery();
                if (queryResult.next()) {
                    result = queryResult.getString("now");
                }
                connection.close();
            } else {
                result = "Failed to connect.";
            }
        } catch (SQLException se) {
            result = "Connection string=" + databaseConnectionString + "\nuserName=" + databaseUserName + "\nerror: "
                    + se.getMessage();
            se.printStackTrace();
        } catch (Exception e) {
            result = e.getMessage();
            e.printStackTrace();
        }
        return result;
    }

    @GetMapping("/token")
    public String getAccessToken() {
        String header;
        if (clientId == null || clientId.isEmpty()) {
            header = "clientId is not set\n";
        } else {
            header = "clientId=" + clientId + "\n";
        }
        try {
            DefaultAzureCredentialBuilder builder = new DefaultAzureCredentialBuilder();
            if (clientId != null && !clientId.isEmpty()) {
                builder.managedIdentityClientId(clientId);
            }
            DefaultAzureCredential azureCredential = builder.build();

            TokenRequestContext tokenRequest = new TokenRequestContext()
                    .addScopes("https://ossrdbms-aad.database.windows.net");
            AccessToken accessToken = azureCredential.getToken(tokenRequest).block();
            return header + accessToken.getToken();
        } catch (Exception e) {
            return header + e.getMessage();
        }
    }

}
