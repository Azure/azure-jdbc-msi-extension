package com.azure.jdbc.msi.extension.postgresql;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenCredential;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.AzureCliCredentialBuilder;
import com.azure.identity.ChainedTokenCredentialBuilder;
import com.azure.identity.ManagedIdentityCredentialBuilder;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Properties;
import org.postgresql.plugin.AuthenticationPlugin;
import org.postgresql.plugin.AuthenticationRequestType;
import org.postgresql.util.PSQLException;
import static org.postgresql.util.PSQLState.INVALID_PASSWORD;

/**
 * The Authentication plugin that enables Azure AD managed identity support.
 */
public class AzurePostgresqlMSIAuthenticationPlugin implements AuthenticationPlugin {

    /**
     * Stores the access token.
     */
    private AccessToken accessToken;

    /**
     * Stores the properties.
     */
    private Properties properties;

    /**
     * Constructor.
     */
    public AzurePostgresqlMSIAuthenticationPlugin() {
    }

    /**
     * Constructor with properties.
     *
     * @param properties the properties.
     */
    public AzurePostgresqlMSIAuthenticationPlugin(Properties properties) {
        this.properties = properties;
    }

    /**
     * Get the password.
     * 
     * @param art the authentication request type.
     * @return the password.
     * @throws PSQLException when an error occurs. 
     */
    @Override
    public char[] getPassword(AuthenticationRequestType art) throws PSQLException {
        char[] password;

        String username = properties.getProperty("user");

        ArrayList<TokenCredential> credentials = new ArrayList<>();
        credentials.add(new ManagedIdentityCredentialBuilder()
                .clientId(username).build());
        credentials.add(new AzureCliCredentialBuilder().build());
        TokenCredential credential = new ChainedTokenCredentialBuilder().addAll(credentials).build();

        TokenRequestContext request = new TokenRequestContext();
        ArrayList<String> scopes = new ArrayList<>();
        scopes.add("https://ossrdbms-aad.database.windows.net");
        request.setScopes(scopes);
        accessToken = credential.getToken(request).block(Duration.ofSeconds(30));

        if (accessToken != null) {
            password = accessToken.getToken().toCharArray();
        } else {
            throw new PSQLException("Unable to acquire access token", INVALID_PASSWORD);
        }

        return password;
    }
}
