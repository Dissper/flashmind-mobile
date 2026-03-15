package com.flashmind.flashmind.document;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.config.AppProperties;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xslf.usermodel.XMLSlideShow;
import org.apache.poi.xslf.usermodel.XSLFShape;
import org.apache.poi.xslf.usermodel.XSLFSlide;
import org.apache.poi.xslf.usermodel.XSLFTextShape;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;

@Service
public class DocumentExtractorService {

    private final AppProperties properties;

    public DocumentExtractorService(AppProperties properties) {
        this.properties = properties;
    }

    public ExtractedDocument extract(MultipartFile file) {
        validateFile(file);
        String originalFilename = file.getOriginalFilename();
        SupportedDocumentType type = SupportedDocumentType.fromFilename(originalFilename);
        String title = stripExtension(originalFilename);

        try {
            String extractedText = switch (type) {
                case PDF -> extractPdf(file.getBytes());
                case DOCX -> extractDocx(file.getInputStream());
                case PPTX -> extractPptx(file.getInputStream());
            };

            String normalized = extractedText == null ? "" : extractedText.trim();
            if (normalized.isBlank()) {
                throw new BadRequestException("No extractable text found. Scanned PDFs, OCR, and images are not supported.");
            }

            if (normalized.length() > properties.getDocument().getMaxExtractedTextLength()) {
                normalized = normalized.substring(0, properties.getDocument().getMaxExtractedTextLength());
            }

            return new ExtractedDocument(title, normalized);
        } catch (IOException exception) {
            throw new BadRequestException("Could not read the uploaded document.");
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("A document file is required.");
        }
        if (file.getOriginalFilename() == null || file.getOriginalFilename().isBlank()) {
            throw new BadRequestException("The uploaded file must have a name.");
        }
        if (file.getSize() > properties.getDocument().getMaxFileSizeBytes()) {
            throw new BadRequestException("The uploaded file exceeds the 10 MB limit.");
        }
    }

    private String extractPdf(byte[] bytes) throws IOException {
        try (PDDocument document = PDDocument.load(bytes)) {
            int pageCount = document.getNumberOfPages();
            if (pageCount > properties.getDocument().getMaxPdfPages()) {
                throw new BadRequestException("PDF exceeds the configured page limit.");
            }

            PDFTextStripper stripper = new PDFTextStripper();
            stripper.setStartPage(1);
            stripper.setEndPage(pageCount);
            return stripper.getText(document);
        }
    }

    private String extractDocx(InputStream inputStream) throws IOException {
        try (XWPFDocument document = new XWPFDocument(inputStream)) {
            if (document.getParagraphs().size() > properties.getDocument().getMaxDocxParagraphs()) {
                throw new BadRequestException("DOCX exceeds the configured content limit.");
            }

            StringBuilder builder = new StringBuilder();
            document.getParagraphs().forEach(paragraph -> builder.append(paragraph.getText()).append('\n'));
            return builder.toString();
        }
    }

    private String extractPptx(InputStream inputStream) throws IOException {
        try (XMLSlideShow slideShow = new XMLSlideShow(inputStream)) {
            if (slideShow.getSlides().size() > properties.getDocument().getMaxPptxSlides()) {
                throw new BadRequestException("PPTX exceeds the configured slide limit.");
            }

            StringBuilder builder = new StringBuilder();
            for (XSLFSlide slide : slideShow.getSlides()) {
                for (XSLFShape shape : slide.getShapes()) {
                    if (shape instanceof XSLFTextShape textShape) {
                        builder.append(textShape.getText()).append('\n');
                    }
                }
            }
            return builder.toString();
        }
    }

    private String stripExtension(String filename) {
        String cleaned = StringUtils.cleanPath(filename);
        int lastDot = cleaned.lastIndexOf('.');
        if (lastDot > 0) {
            return cleaned.substring(0, lastDot);
        }
        return cleaned;
    }
}
