package test;

import java.sql.Connection;
import java.sql.DriverManager;
import org.junit.Test;

/**
 * A test that can be used to verify that managed identity is working with your
 * MySQL JDBC connection.
 */
public class JDBCTest {

    /**
     * Test connection.
     */
    @Test
    public void testConnection() {
        main(new String[]{System.getProperty("url")});
    }

    /**
     * Main method.
     *
     * @param arguments the arguments.
     */
    public static void main(String[] arguments) {
        Connection connection;
        try {
            connection = DriverManager.getConnection(arguments[0]);

            if (connection != null) {
                System.out.println("Successfully connected.");
                System.out.println(connection.isValid(10));
            } else {
                System.out.println("Failed to connect.");
            }
        } catch (Exception e) {
            e.printStackTrace(System.err);
        }
    }
}
