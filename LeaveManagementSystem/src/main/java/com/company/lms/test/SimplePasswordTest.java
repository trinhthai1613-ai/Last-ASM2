package com.company.lms.test;

import java.security.MessageDigest;

/**
 * TEST ĐƠN GIẢN - CHẠY CLASS NÀY ĐỂ TEST HASH
 */
public class SimplePasswordTest {
    
    public static void main(String[] args) {
        System.out.println("=".repeat(60));
        System.out.println("           TEST PASSWORD HASH");
        System.out.println("=".repeat(60));
        System.out.println();
        
        // Test với password "123456"
        String password = "123456";
        String hash = hashPassword(password);
        
        System.out.println("Password test: " + password);
        System.out.println("Hash SHA-256:  " + hash);
        System.out.println();
        
        // Hash chuẩn để so sánh
        String correctHash = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92";
        
        System.out.println("Hash chuẩn:    " + correctHash);
        System.out.println();
        
        if (hash.equals(correctHash)) {
            System.out.println("✅ Hash ĐÚNG!");
        } else {
            System.out.println("❌ Hash SAI!");
        }
        
        System.out.println();
        System.out.println("=".repeat(60));
    }
    
    private static String hashPassword(String plainPassword) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainPassword.getBytes());
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
            
        } catch (Exception e) {
            throw new RuntimeException("Cannot hash password", e);
        }
    }
}