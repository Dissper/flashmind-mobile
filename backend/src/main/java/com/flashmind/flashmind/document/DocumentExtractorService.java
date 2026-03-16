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
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

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
        String title = normalizeTitle(stripExtension(originalFilename));

        try {
            String extractedText = switch (type) {
                case PDF -> extractPdf(file.getBytes());
                case DOCX -> extractDocx(file.getInputStream());
                case PPTX -> extractPptx(file.getInputStream());
            };

            String normalized = extractedText == null ? "" : cleanExtractedText(extractedText);
            if (normalized.isBlank()) {
                throw new BadRequestException("No extractable text found. Scanned PDFs, OCR, and images are not supported.");
            }

            if (normalized.length() > properties.getDocument().getMaxExtractedTextLength()) {
                normalized = normalized.substring(0, properties.getDocument().getMaxExtractedTextLength());
            }

            return new ExtractedDocument(title, normalized, detectLanguage(normalized));
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

    private String normalizeTitle(String rawTitle) {
        String normalized = rawTitle
                .replaceAll("[^\\p{L}\\p{N}]+", " ")
                .replaceAll("\\s+", " ")
                .trim();

        return normalized.isBlank() ? "Untitled Deck" : normalized;
    }

    private String cleanExtractedText(String rawText) {
        List<String> cleanedLines = new ArrayList<>();

        for (String rawLine : rawText.split("\\R")) {
            String line = rawLine.replaceAll("\\s+", " ").trim();
            if (line.isBlank()) {
                continue;
            }
            if (startsReferenceSection(line)) {
                break;
            }
            if (isBoilerplateLine(line)) {
                continue;
            }

            cleanedLines.add(line);
        }

        String cleaned = String.join("\n", cleanedLines)
                .replaceAll("\\n{3,}", "\n\n")
                .trim();

        if (cleaned.isBlank()) {
            return rawText.trim();
        }

        return cleaned;
    }

    private boolean startsReferenceSection(String line) {
        String normalized = line.toLowerCase(Locale.ROOT).trim();
        return normalized.equals("references")
                || normalized.equals("bibliography")
                || normalized.equals("works cited")
                || normalized.equals("referencias");
    }

    private boolean isBoilerplateLine(String line) {
        String normalized = line.toLowerCase(Locale.ROOT);

        if (normalized.contains("@")) {
            return true;
        }
        if (normalized.contains("contents lists available")
                || normalized.contains("sciencedirect")
                || normalized.contains("journal homepage")
                || normalized.contains("available online at")
                || normalized.contains("corresponding author")
                || normalized.contains("doi.org")
                || normalized.startsWith("doi:")
                || normalized.startsWith("received ")
                || normalized.startsWith("accepted ")
                || normalized.startsWith("available online ")
                || normalized.startsWith("©")
                || normalized.startsWith("copyright")) {
            return true;
        }
        if ((normalized.contains("university")
                || normalized.contains("department of")
                || normalized.contains("faculty of")
                || normalized.contains("institute of")
                || normalized.contains("school of"))
                && line.length() <= 140) {
            return true;
        }
        if ((normalized.startsWith("keywords")
                || normalized.startsWith("keyword")
                || normalized.startsWith("author affiliations"))
                && line.length() <= 160) {
            return true;
        }
        if (line.length() <= 4) {
            return true;
        }

        return false;
    }

    private String detectLanguage(String text) {
        String normalized = text.toLowerCase(Locale.ROOT);

        int spanishSignals = 0;
        int englishSignals = 0;

        if (normalized.matches(".*[áéíóúñ¿¡].*")) {
            spanishSignals += 2;
        }

        spanishSignals += countMatches(normalized,
                " el ", " la ", " los ", " las ", " una ", " para ", " con ", " como ", " que ", " del ",
                " se ", " en ", " por ", " su ", " puede ", " estudio ", " investigación ");
        englishSignals += countMatches(normalized,
                " the ", " and ", " for ", " with ", " from ", " this ", " that ", " study ", " research ",
                " can ", " may ", " are ", " is ");

        return spanishSignals >= englishSignals ? "Spanish" : "English";
    }

    private int countMatches(String text, String... patterns) {
        int count = 0;
        for (String pattern : patterns) {
            if (text.contains(pattern)) {
                count++;
            }
        }
        return count;
    }
}
