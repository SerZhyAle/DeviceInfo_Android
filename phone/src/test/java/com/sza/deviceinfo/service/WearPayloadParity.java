package com.sza.deviceinfo.service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Source-level check shared by the unit test and the fast, standalone Java invocation. */
public final class WearPayloadParity {
    private static final String[] CLASSES = {"WearSystemInfoReportPayload", "WearSystemInfoReportAck"};
    private static final Pattern PROPERTY = Pattern.compile(
            "^@SerializedName\\(\"([A-Za-z_][A-Za-z0-9_]*)\"\\)\\s+val\\s+"
                    + "([A-Za-z_][A-Za-z0-9_]*)\\s*:\\s*([A-Za-z_][A-Za-z0-9_.]*\\??)"
                    + "(?:\\s*=\\s*(.+))?$");
    private static final Pattern VERSION = Pattern.compile(
            "(?m)^\\h*const\\h+val\\h+FORMAT_VERSION\\h*:\\h*Int\\h*=\\h*(\\d+)\\h*$");

    private WearPayloadParity() {}

    public static void check(Path phone, Path wear) throws IOException {
        checkSources(Files.readString(phone, StandardCharsets.UTF_8),
                Files.readString(wear, StandardCharsets.UTF_8));
    }

    static void checkSources(String phone, String wear) {
        for (String className : CLASSES) {
            Map<String, String> phoneFields = fields(phone, className);
            Map<String, String> wearFields = fields(wear, className);
            if (!phoneFields.equals(wearFields)) {
                throw new IllegalStateException(className + " does not match: phone=" + phoneFields
                        + ", wear=" + wearFields);
            }
        }
        if (!version(phone).equals(version(wear))) {
            throw new IllegalStateException("FORMAT_VERSION does not match between phone and wear");
        }
    }

    private static Map<String, String> fields(String source, String className) {
        Pattern header = Pattern.compile("^data\\s+class\\s+" + className + "\\s*\\(\\s*$");
        Map<String, String> fields = new LinkedHashMap<>();
        Map<String, String> wireNames = new LinkedHashMap<>();
        boolean inConstructor = false;
        boolean finished = false;
        String[] lines = source.split("\\R");
        for (int index = 0; index < lines.length; index++) {
            String line = lines[index].trim();
            if (!inConstructor) {
                if (header.matcher(line).matches()) {
                    if (finished) throw new IllegalStateException("Duplicate " + className);
                    inConstructor = true;
                }
                continue;
            }
            if (line.matches("\\)\\s*\\{?")) {
                String tail = String.join("\n", Arrays.copyOfRange(lines, index + 1, lines.length));
                if (className.equals("WearSystemInfoReportPayload")) {
                    if (!line.endsWith("{")) {
                        throw new IllegalStateException("Unsupported class body in " + className);
                    }
                    checkPayloadBody(tail);
                } else if (line.endsWith("{") || stripLeadingComments(tail).startsWith("{")) {
                    throw new IllegalStateException("Unsupported class body in " + className);
                }
                inConstructor = false;
                finished = true;
                continue;
            }
            if (line.isEmpty() || line.startsWith("//")) continue;
            if (line.endsWith(",")) line = line.substring(0, line.length() - 1).trim();
            Matcher property = PROPERTY.matcher(line);
            if (!property.matches()) {
                throw new IllegalStateException("Unrecognized field in " + className + ": " + line);
            }
            String wireName = property.group(1);
            String name = property.group(2);
            String type = property.group(3);
            String defaultValue = property.group(4) == null ? "<none>" : property.group(4).trim();
            if (fields.put(name, wireName + ":" + type + "=" + defaultValue) != null
                    || wireNames.put(wireName, name) != null) {
                throw new IllegalStateException("Duplicate field or wire name in " + className);
            }
        }
        if (!finished || inConstructor || fields.isEmpty()) {
            throw new IllegalStateException("Missing, empty or incomplete constructor for " + className);
        }
        return fields;
    }

    // Gson also serializes instance properties declared in a class body. Allow only the known
    // companion constant there, so a future body property cannot bypass the constructor check.
    private static void checkPayloadBody(String body) {
        String rest = consume(body, "^companion\\s+object\\s*\\{");
        rest = consume(rest, "^const\\s+val\\s+FORMAT_VERSION\\s*:\\s*Int\\s*=\\s*\\d+\\b");
        rest = consume(rest, "^\\}");
        consume(rest, "^\\}");
    }

    private static String consume(String text, String pattern) {
        String rest = stripLeadingComments(text);
        Matcher matcher = Pattern.compile(pattern).matcher(rest);
        if (!matcher.find()) throw new IllegalStateException("Unsupported class body in report payload");
        return rest.substring(matcher.end());
    }

    private static String stripLeadingComments(String text) {
        String rest = text.stripLeading();
        while (rest.startsWith("//") || rest.startsWith("/*")) {
            if (rest.startsWith("//")) {
                int end = rest.indexOf('\n');
                rest = end < 0 ? "" : rest.substring(end + 1).stripLeading();
            } else {
                int end = rest.indexOf("*/", 2);
                if (end < 0) throw new IllegalStateException("Unterminated comment in class body");
                rest = rest.substring(end + 2).stripLeading();
            }
        }
        return rest;
    }

    private static String version(String source) {
        Matcher matcher = VERSION.matcher(source);
        if (!matcher.find()) throw new IllegalStateException("Missing FORMAT_VERSION");
        String value = matcher.group(1);
        if (matcher.find()) throw new IllegalStateException("Duplicate FORMAT_VERSION");
        return value;
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Usage: java WearPayloadParity.java <phone-source> <wear-source>");
            System.exit(2);
        }
        try {
            check(Path.of(args[0]), Path.of(args[1]));
            System.out.println("PASS: report and ack fields and format version match");
        } catch (IOException | IllegalStateException error) {
            System.err.println("FAIL: " + error.getMessage());
            System.exit(1);
        }
    }
}
