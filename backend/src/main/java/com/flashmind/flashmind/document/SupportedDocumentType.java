package com.flashmind.flashmind.document;

import com.flashmind.flashmind.common.BadRequestException;

public enum SupportedDocumentType {
    PDF(".pdf"),
    DOCX(".docx"),
    PPTX(".pptx");

    private final String extension;

    SupportedDocumentType(String extension) {
        this.extension = extension;
    }

    public static SupportedDocumentType fromFilename(String filename) {
        String normalized = filename.toLowerCase();
        for (SupportedDocumentType value : values()) {
            if (normalized.endsWith(value.extension)) {
                return value;
            }
        }
        throw new BadRequestException("Unsupported file type. Only PDF, DOCX, and PPTX are allowed.");
    }
}
