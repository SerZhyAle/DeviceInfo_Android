package com.sza.deviceinfo.wear.ui;

import java.nio.file.Files;
import java.nio.file.Path;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/** Resource-level check; rendered targets and edge scaling still require a watch. */
public final class WearUiSizingResources {
    private WearUiSizingResources() { }

    public static void verify() throws Exception {
        Path root = Path.of(System.getProperty("user.dir")).toAbsolutePath();
        while (root != null && !Files.isRegularFile(root.resolve("settings.gradle.kts"))) root = root.getParent();
        if (root == null) throw new IllegalStateException("Repository root not found");
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        NodeList items = factory.newDocumentBuilder()
            .parse(root.resolve("wear/src/main/res/values/dimens.xml").toFile()).getElementsByTagName("dimen");
        for (int i = 0; i < items.getLength(); i++) {
            Element item = (Element) items.item(i);
            if ("system_info_touch_target_min".equals(item.getAttribute("name"))) {
                String value = item.getTextContent().trim();
                if (value.endsWith("dp") && Float.parseFloat(value.substring(0, value.length() - 2)) >= 48) return;
                throw new IllegalStateException("Wear target below 48dp: " + value);
            }
        }
        throw new IllegalStateException("Missing Wear target dimension");
    }

    public static void main(String[] args) throws Exception {
        verify();
        System.out.println("Wear UI sizing resource: OK");
    }
}
