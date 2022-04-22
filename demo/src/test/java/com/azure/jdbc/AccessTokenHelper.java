package com.azure.jdbc;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;

public class AccessTokenHelper {
    public String getAccessToken() {
        DefaultAzureCredential azureCredential = new DefaultAzureCredentialBuilder().build();

        TokenRequestContext tokenRequest = new TokenRequestContext()
                .addScopes("https://ossrdbms-aad.database.windows.net");
        AccessToken accessToken = azureCredential.getToken(tokenRequest).block();
        return accessToken.getToken();
    }

    public String getAccessToken(String clientId) {
        DefaultAzureCredential azureCredential = new DefaultAzureCredentialBuilder().managedIdentityClientId(clientId)
                .build();

        TokenRequestContext tokenRequest = new TokenRequestContext()
                .addScopes("https://ossrdbms-aad.database.windows.net");
        AccessToken accessToken = azureCredential.getToken(tokenRequest).block();
        return accessToken.getToken();
    }

}
