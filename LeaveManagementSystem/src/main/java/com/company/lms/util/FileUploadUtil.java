package com.company.lms.util;

import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

public class FileUploadUtil {
    private static final Logger logger = LoggerFactory.getLogger(FileUploadUtil.class);
    
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final String[] ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif"};
    private static final String[] ALLOWED_DOCUMENT_EXTENSIONS = {".pdf", ".doc", ".docx", ".xls", ".xlsx"};
    
    public static String uploadFile(Part filePart, String uploadDir, String fileType) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        if (filePart.getSize() > MAX_FILE_SIZE) {
            throw new IOException("File size exceeds maximum limit of 5MB");
        }
        
        String fileName = extractFileName(filePart);
        String fileExtension = getFileExtension(fileName);
        
        if (!isValidExtension(fileExtension, fileType)) {
            throw new IOException("Invalid file type. Allowed types: " + getAllowedExtensions(fileType));
        }
        
        String uniqueFileName = generateUniqueFileName(fileExtension);
        
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        Path filePath = uploadPath.resolve(uniqueFileName);
        
        try {
            Files.copy(filePart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            logger.info("File uploaded successfully: {}", uniqueFileName);
            return uniqueFileName;
        } catch (IOException e) {
            logger.error("Error uploading file", e);
            throw e;
        }
    }
    
    public static String uploadAvatar(Part filePart, String uploadDir) throws IOException {
        return uploadFile(filePart, uploadDir, "image");
    }
    
    public static String uploadDocument(Part filePart, String uploadDir) throws IOException {
        return uploadFile(filePart, uploadDir, "document");
    }
    
    public static boolean deleteFile(String filePath) {
        try {
            Path path = Paths.get(filePath);
            return Files.deleteIfExists(path);
        } catch (IOException e) {
            logger.error("Error deleting file: {}", filePath, e);
            return false;
        }
    }
    
    private static String extractFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "unknown";
    }
    
    private static String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0) {
            return fileName.substring(lastDotIndex).toLowerCase();
        }
        return "";
    }
    
    private static boolean isValidExtension(String extension, String fileType) {
        String[] allowedExtensions = fileType.equals("image") ? ALLOWED_IMAGE_EXTENSIONS : ALLOWED_DOCUMENT_EXTENSIONS;
        
        for (String allowed : allowedExtensions) {
            if (allowed.equalsIgnoreCase(extension)) {
                return true;
            }
        }
        return false;
    }
    
    private static String getAllowedExtensions(String fileType) {
        String[] extensions = fileType.equals("image") ? ALLOWED_IMAGE_EXTENSIONS : ALLOWED_DOCUMENT_EXTENSIONS;
        return String.join(", ", extensions);
    }
    
    private static String generateUniqueFileName(String extension) {
        return UUID.randomUUID().toString() + extension;
    }
    
    public static String getFileSizeDisplay(long sizeInBytes) {
        if (sizeInBytes < 1024) {
            return sizeInBytes + " B";
        } else if (sizeInBytes < 1024 * 1024) {
            return String.format("%.2f KB", sizeInBytes / 1024.0);
        } else {
            return String.format("%.2f MB", sizeInBytes / (1024.0 * 1024.0));
        }
    }
}