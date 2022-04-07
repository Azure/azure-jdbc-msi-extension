package com.azure.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SampleController {

    @Value("${mysql.database}")
    private String databaseConnectionString;
    @Value("${mysql.username}")
    private String username;

    @GetMapping("/")
    public String getServerDate() {
        String result = "not executed";
        Connection connection;
        try {
            String connectionString = databaseConnectionString + "&user=" + username;
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

    @GetMapping("/token")
    public String getAccessToken() {
        DefaultAzureCredential azureCredential = new DefaultAzureCredentialBuilder().build();

        TokenRequestContext tokenRequest = new TokenRequestContext()
                .addScopes("https://ossrdbms-aad.database.windows.net");
        AccessToken accessToken = azureCredential.getToken(tokenRequest).block();
        return accessToken.getToken();
    }

}
