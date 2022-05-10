package com.azure.jdbc.web;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.PostConstruct;

@RestController
public class SampleController {

    @Value("${database.connection.clientid:}")
    private String clientId;

    private final JdbcTemplate jdbcTemplate;

    public SampleController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/")
    public String getServerDate() {
        return "server date is : " + jdbcTemplate.queryForObject("SELECT now() as now", String.class);
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
