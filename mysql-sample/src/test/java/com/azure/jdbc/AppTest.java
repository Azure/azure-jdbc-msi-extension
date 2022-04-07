package com.azure.jdbc;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
public class AppTest {
	@Value("${mysql.database}")
	private String databaseConnectionString;
	@Value("${mysql.username}")
	private String username;

	@Test
	void contextLoads() {
	}

	/*
	 * This test will fail if it is not possible to connect to the database.
	 * The credentials are taken from the context. For instance Azure CLI
	 * credentials or VSCode extension credentials.
	 */
	@Test
	void getServerTime() throws SQLException {
		Connection connection;

		String connectionString = databaseConnectionString + "&user=" + username;
		connection = DriverManager.getConnection(connectionString);

		if (connection != null) {
			try {
				String result = connection.prepareStatement("SELECT now() as now").executeQuery().getString("now");
				assertNotNull(result);
			} finally {
				connection.close();
			}
		} else {
			fail("Failed to connect.");
		}
	}

	/*
	 * This test will fail if it is not possible to connect to the database.
	 * The credentials are taken from the context. For instance Azure CLI
	 * credentials or VSCode extension credentials.
	 */
	@Test
	void getServerTimeExplicitPassword() throws SQLException {
		Connection connection;

		connection = DriverManager.getConnection(databaseConnectionString, username, getAccessToken());

		if (connection != null) {
			try {
				ResultSet queryResult = connection.prepareStatement("SELECT now() as now").executeQuery();
				if (queryResult.next()){
					String result = queryResult.getString("now");
					assertNotNull(result);
				}
			} finally {
				connection.close();
			}
		} else {
			fail("Failed to connect.");
		}
	}

	public String getAccessToken() {
        DefaultAzureCredential azureCredential = new DefaultAzureCredentialBuilder().build();

        TokenRequestContext tokenRequest = new TokenRequestContext()
                .addScopes("https://ossrdbms-aad.database.windows.net");
        AccessToken accessToken = azureCredential.getToken(tokenRequest).block();
		String token= accessToken.getToken();
		return token;
    }
}
