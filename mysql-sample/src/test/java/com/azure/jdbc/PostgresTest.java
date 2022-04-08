package com.azure.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
public class PostgresTest {

    @Value("${mysql.database}")
	private String databaseConnectionString;
	@Value("${mysql.username}")
	private String username;

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

    
}
