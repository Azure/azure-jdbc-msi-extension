package com.azure.jdbc.msi.extension.mysql;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenCredential;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.AzureCliCredentialBuilder;
import com.azure.identity.ChainedTokenCredentialBuilder;
import com.azure.identity.ManagedIdentityCredential;
import com.azure.identity.ManagedIdentityCredentialBuilder;
import com.mysql.cj.callback.MysqlCallbackHandler;
import com.mysql.cj.callback.UsernameCallback;
import com.mysql.cj.protocol.AuthenticationPlugin;
import com.mysql.cj.protocol.Protocol;
import com.mysql.cj.protocol.a.NativeConstants;
import com.mysql.cj.protocol.a.NativePacketPayload;
import java.io.UnsupportedEncodingException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

/**
 * The Authentication plugin that enables Azure AD managed identity support.
 */
public class AzureMySqlMSIAuthenticationPlugin implements AuthenticationPlugin<NativePacketPayload> {

    /**
     * Stores the access token.
     */
    private AccessToken accessToken;

    /**
     * Stores the callback handler.
     */
    private MysqlCallbackHandler callbackHandler;

    /**
     * Stores the protocol.
     */
    private Protocol<NativePacketPayload> protocol;

    @Override
    public void destroy() {
    }

    @Override
    public String getProtocolPluginName() {
        return "azure_mysql_msi";
    }

    @Override
    public void init(Protocol<NativePacketPayload> protocol) {
        this.protocol = protocol;
    }

    @Override
    public void init(Protocol<NativePacketPayload> protocol, MysqlCallbackHandler callbackHandler) {
        this.init(protocol);
        this.callbackHandler = callbackHandler;
    }

    @Override
    public boolean isReusable() {
        return true;
    }

    @Override
    public boolean nextAuthenticationStep(NativePacketPayload fromServer,
            List<NativePacketPayload> toServer) {

        /*
         * See com.mysql.cj.protocol.a.authentication.MysqlClearPasswordPlugin
         */
        toServer.clear();
        NativePacketPayload response;

        if (fromServer == null || accessToken == null || accessToken.isExpired()) {
            response = new NativePacketPayload(new byte[0]);
        } else if (protocol.getSocketConnection().isSSLEstablished()) {
            try {
                response = new NativePacketPayload(
                        accessToken.getToken().getBytes(
                                protocol.getServerSession()
                                        .getCharsetSettings()
                                        .getPasswordCharacterEncoding()));
                response.setPosition(response.getPayloadLength());
                response.writeInteger(NativeConstants.IntegerDataType.INT1, 0);
                response.setPosition(0);
            } catch (UnsupportedEncodingException uee) {
                response = new NativePacketPayload(new byte[0]);
            }
        } else {
            response = new NativePacketPayload(new byte[0]);
        }

        toServer.add(response);
        return true;
    }

    @Override
    public boolean requiresConfidentiality() {
        return true;
    }

    @Override
    public void reset() {
        accessToken = null;
    }

    @Override
    public void setAuthenticationParameters(String username, String password) {

        /*
         * If username is specified use it as a managed identity (and if it
         * fails let the AzureCliCredential have a chance), otherwise assume
         * system assigned managed identity.
         */
        TokenCredential credential;

        if (username != null) {
            ArrayList<TokenCredential> credentials = new ArrayList<>();
            credentials.add(new ManagedIdentityCredentialBuilder()
                    .clientId(username).build());
            credentials.add(new AzureCliCredentialBuilder().build());
            credential = new ChainedTokenCredentialBuilder().addAll(credentials).build();
        } else {
            credential = new ManagedIdentityCredentialBuilder().build();
            username = ((ManagedIdentityCredential) credential).getClientId();
        }

        /**
         * Setup the username callback.
         */
        callbackHandler.handle(new UsernameCallback(username));

        /*
         * Setup the access token.
         */
        if (username != null) {
            TokenRequestContext request = new TokenRequestContext();
            ArrayList<String> scopes = new ArrayList<>();
            scopes.add("https://ossrdbms-aad.database.windows.net");
            request.setScopes(scopes);
            accessToken = credential.getToken(request).block(Duration.ofSeconds(30));
        }
    }

    @Override
    public void setSourceOfAuthData(String sourceOfAuthData) {
    }
}
