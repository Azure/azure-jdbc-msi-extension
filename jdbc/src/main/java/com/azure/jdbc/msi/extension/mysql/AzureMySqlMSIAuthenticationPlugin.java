package com.azure.jdbc.msi.extension.mysql;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenCredential;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.mysql.cj.callback.MysqlCallbackHandler;
import com.mysql.cj.callback.UsernameCallback;
import com.mysql.cj.protocol.AuthenticationPlugin;
import com.mysql.cj.protocol.Protocol;
import com.mysql.cj.protocol.a.NativeConstants;
import com.mysql.cj.protocol.a.NativePacketPayload;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The Authentication plugin that enables Azure AD managed identity support.
 */
public class AzureMySqlMSIAuthenticationPlugin implements AuthenticationPlugin<NativePacketPayload> {
    // public static String PLUGIN_NAME = "aad_auth";
    public static String PLUGIN_NAME = "azure_mysql_msi";

    Logger logger = LoggerFactory.getLogger(AzureMySqlMSIAuthenticationPlugin.class);

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

    private String sourceOfAuthData;

    @Override
    public void destroy() {

    }

    @Override
    public String getProtocolPluginName() {
        return PLUGIN_NAME;
        // return "mysql_clear_password";
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

        // if (!(this.sourceOfAuthData.equals(PLUGIN_NAME) ||
        // this.sourceOfAuthData.equals("mysql_clear_password")) ||
        // fromServer.getPayloadLength() == 0) {
        // // Cannot do anything with whatever payload comes from the server, so just
        // skip this iteration and wait for a Protocol::AuthSwitchRequest or a
        // // Protocol::AuthNextFactor.
        // this.logger.info("Skipping authentication step, waiting for AuthSwitchRequest
        // or AuthNextFactor. sourceOfAuthData: " + this.sourceOfAuthData);
        // toServer.add(new NativePacketPayload(0));
        // return true;
        // }

        logger.info("sourceOfData=" + sourceOfAuthData + " fromServer.isAuthMethodSwitchRequestPacket()="
                + fromServer.isAuthMethodSwitchRequestPacket()
                + ", fromServer.isAuthMoreDataPacket()=" + fromServer.isAuthMoreDataPacket()
                + ", fromServer.isAuthNextFactorPacket()=" + fromServer.isAuthNextFactorPacket()
                + ", fromServer.isEOFPacket()=" + fromServer.isEOFPacket() + ", fromServer.isErrorPacket()="
                + fromServer.isErrorPacket() + ", fromServer.isOKPacket()=" + fromServer.isOKPacket()
                + ", fromServer.isResultSetOKPacket()=" + fromServer.isResultSetOKPacket());

        if (fromServer == null || accessToken == null || accessToken.isExpired()) {
            response = new NativePacketPayload(new byte[0]);
        } else if (protocol.getSocketConnection().isSSLEstablished()) {
            try {

                String password = accessToken.getToken();
                // response = new NativePacketPayload(
                // Security.scramble411(password,
                // fromServer.readBytes(StringSelfDataType.STRING_TERM),
                // this.protocol.getServerSession().getCharsetSettings().getPasswordCharacterEncoding()));
                response = new NativePacketPayload(
                        password.getBytes(
                                protocol.getServerSession()
                                        .getCharsetSettings()
                                        .getPasswordCharacterEncoding()));
                response.setPosition(response.getPayloadLength());
                response.writeInteger(NativeConstants.IntegerDataType.INT1, 0);
                response.setPosition(0);
            } catch (Exception uee) {
                logger.error(uee.getMessage(), uee);
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
        String clientId = getClientId();

        TokenCredential credential;
        if (clientId != null && !clientId.isEmpty()) {
            credential = new DefaultAzureCredentialBuilder().managedIdentityClientId(clientId).build();
        } else {
            credential = new DefaultAzureCredentialBuilder().build();
        }

        logger.info("sourceOfData= " + sourceOfAuthData + " username=" + username + " password=" + password);

        if (username != null) {
            // ArrayList<TokenCredential> credentials = new ArrayList<>();
            // credentials.add(new ManagedIdentityCredentialBuilder()
            // .clientId(username).build());
            // credentials.add(new AzureCliCredentialBuilder().build());
            // credential = new ChainedTokenCredentialBuilder().addAll(credentials).build();
        } else {
            // credential = new ManagedIdentityCredentialBuilder().build();
            // username = ((ManagedIdentityCredential) credential).getClientId();
        }

        /**
         * Setup the username callback.
         */
        // String normalizedUserName = username.replace("@microsoft.onmicrosoft.com",
        // "");
        String normalizedUserName = username;
        callbackHandler.handle(new UsernameCallback(normalizedUserName));

        /*
         * Setup the access token.
         */
        if (username != null) {
            TokenRequestContext request = new TokenRequestContext();
            ArrayList<String> scopes = new ArrayList<>();
            scopes.add("https://ossrdbms-aad.database.windows.net");
            request.setScopes(scopes);
            accessToken = credential.getToken(request).block(Duration.ofSeconds(30));
            password = accessToken.getToken();
        }
    }

    @Override
    public void setSourceOfAuthData(String sourceOfAuthData) {
        this.sourceOfAuthData = sourceOfAuthData;
    }

    private String getClientId() {
        String clientId;
        if (this.protocol.getPropertySet().getProperty("clientid") != null) {
            logger.info("clientid=" + this.protocol.getPropertySet().getProperty("clientid"));
            clientId = this.protocol.getPropertySet().getStringProperty("clientid").getStringValue();
        } else {
            clientId = null;
        }
        return clientId;

    }
}
