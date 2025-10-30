package com.company.lms.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DatabaseConnection {
    private static final Logger logger = LoggerFactory.getLogger(DatabaseConnection.class);
    private static String DB_URL;
    private static String DB_USERNAME;
    private static String DB_PASSWORD;
    private static String DB_DRIVER;
    
    static {
        try {
            Properties props = new Properties();
            InputStream input = DatabaseConnection.class.getClassLoader()
                    .getResourceAsStream("database.properties");
            
            if (input == null) {
                throw new IOException("Unable to find database.properties");
            }
            
            props.load(input);
            
            DB_DRIVER = props.getProperty("db.driver");
            DB_URL = props.getProperty("db.url");
            DB_USERNAME = props.getProperty("db.username");
            DB_PASSWORD = props.getProperty("db.password");
            
            Class.forName(DB_DRIVER);
            logger.info("Database driver loaded successfully");
            
        } catch (IOException | ClassNotFoundException e) {
            logger.error("Error loading database configuration", e);
            throw new RuntimeException("Failed to initialize database connection", e);
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
    }
    
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                logger.error("Error closing connection", e);
            }
        }
    }
    
    public static void testConnection() {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                logger.info("Database connection test successful");
            }
        } catch (SQLException e) {
            logger.error("Database connection test failed", e);
        }
    }
}
