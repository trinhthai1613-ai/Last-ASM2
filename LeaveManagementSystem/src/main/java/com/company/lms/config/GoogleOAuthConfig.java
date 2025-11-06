package com.company.lms.config;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.util.store.MemoryDataStoreFactory;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class GoogleOAuthConfig {
    
    // ⚠️ QUAN TRỌNG: Thay đổi những giá trị này
    private static final String CLIENT_ID = "137952627305-2sq4reupfh6gknoqhmtg9kro3drifunv.apps.googleusercontent.com";
    private static final String CLIENT_SECRET = "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";
    private static final String REDIRECT_URI = "http://localhost:8080/LeaveManagementSystem/google-callback";
    
    // Các scope cần thiết
    private static final List<String> SCOPES = Arrays.asList(
        "openid",
        "email",
        "profile"
    );
    
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    private static final NetHttpTransport HTTP_TRANSPORT = new NetHttpTransport();
    
    private static GoogleAuthorizationCodeFlow flow;
    
    public static GoogleAuthorizationCodeFlow getFlow() throws IOException {
        if (flow == null) {
            GoogleClientSecrets.Details details = new GoogleClientSecrets.Details();
            details.setClientId(CLIENT_ID);
            details.setClientSecret(CLIENT_SECRET);
            
            GoogleClientSecrets clientSecrets = new GoogleClientSecrets();
            clientSecrets.setInstalled(details);
            
            flow = new GoogleAuthorizationCodeFlow.Builder(
                HTTP_TRANSPORT,
                JSON_FACTORY,
                clientSecrets,
                SCOPES
            )
            .setDataStoreFactory(new MemoryDataStoreFactory())
            .setAccessType("offline")
            .build();
        }
        return flow;
    }
    
    public static String getRedirectUri() {
        return REDIRECT_URI;
    }
    
    public static String getClientId() {
        return CLIENT_ID;
    }
}