package com.sza.deviceinfo.ui;

import java.nio.file.Files;
import java.nio.file.Path;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/** Resource-level checks; actual hit bounds still require an Android view hierarchy. */
public final class PhoneUiSizingResources {
    private static final String ANDROID = "http://schemas.android.com/apk/res/android";

    private PhoneUiSizingResources() { }

    public static void verify() throws Exception {
        Path root = root();
        Path res = root.resolve("phone/src/main/res");
        Document dimens = read(res.resolve("values/dimens.xml"));
        require(dp(dimension(dimens, "touch_target_min_height")) >= 48, "phone target height below 48dp");
        require(dp(dimension(dimens, "system_info_group_copy_button_width")) >= 48, "copy target width below 48dp");
        Document header = read(res.resolve("layout/view_collapsible_section_header.xml"));
        Element toggle = id(header, "csh_toggleRow");
        Element trailing = id(header, "csh_trailingSlot");
        require(toggle.getParentNode().isSameNode(trailing.getParentNode()), "header and copy target must be siblings");
        require("@dimen/touch_target_min_height".equals(toggle.getAttributeNS(ANDROID, "minHeight")), "header minimum is not wired");
        Element title = id(header, "csh_title");
        require(!title.hasAttributeNS(ANDROID, "maxLines") && !title.hasAttributeNS(ANDROID, "ellipsize"), "header title is truncated");
        for (String layout : new String[] {"layout", "layout-land"}) {
            Element row = id(read(res.resolve(layout + "/item_system_info_field.xml")), "rowSystemInfoField");
            require("@dimen/touch_target_min_height".equals(row.getAttributeNS(ANDROID, "minHeight")), layout + " field minimum is not wired");
        }
    }

    public static void main(String[] args) throws Exception {
        verify();
        System.out.println("Phone UI sizing resources: OK");
    }

    private static Path root() {
        Path path = Path.of(System.getProperty("user.dir")).toAbsolutePath();
        while (path != null && !Files.isRegularFile(path.resolve("settings.gradle.kts"))) path = path.getParent();
        if (path == null) throw new IllegalStateException("Repository root not found");
        return path;
    }

    private static Document read(Path path) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        return factory.newDocumentBuilder().parse(path.toFile());
    }

    private static String dimension(Document doc, String name) {
        NodeList items = doc.getElementsByTagName("dimen");
        for (int i = 0; i < items.getLength(); i++) {
            Element item = (Element) items.item(i);
            if (name.equals(item.getAttribute("name"))) return item.getTextContent().trim();
        }
        throw new IllegalStateException("Missing dimension " + name);
    }

    private static Element id(Document doc, String name) {
        NodeList elements = doc.getElementsByTagName("*");
        for (int i = 0; i < elements.getLength(); i++) {
            Element element = (Element) elements.item(i);
            if (("@+id/" + name).equals(element.getAttributeNS(ANDROID, "id"))) return element;
        }
        throw new IllegalStateException("Missing view " + name);
    }

    private static float dp(String value) {
        require(value.endsWith("dp"), "Expected dp dimension: " + value);
        return Float.parseFloat(value.substring(0, value.length() - 2));
    }

    private static void require(boolean condition, String message) {
        if (!condition) throw new IllegalStateException(message);
    }
}
