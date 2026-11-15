package com.sza.deviceinfo.service;

import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.Test;

public class WearSystemInfoReportPayloadParityTest {
    private static final String PHONE = "phone/src/main/kotlin/com/sza/deviceinfo/domain/model/"
            + "WearSystemInfoReportPayload.kt";
    private static final String WEAR = "wear/src/main/kotlin/com/sza/deviceinfo/wear/data/wear/"
            + "WearSystemInfoReportPayload.kt";

    @Test
    public void phoneAndWearHaveIdenticalReportAndAckSchemas() throws IOException {
        Path root = repositoryRoot();
        WearPayloadParity.check(root.resolve(PHONE), root.resolve(WEAR));
    }

    @Test
    public void oneSidedWireChangesAreRejected() throws IOException {
        Path root = repositoryRoot();
        String phone = Files.readString(root.resolve(PHONE), StandardCharsets.UTF_8);
        String wear = Files.readString(root.resolve(WEAR), StandardCharsets.UTF_8);
        String[][] mutations = {
                {"@SerializedName(\"requestId\")", "@SerializedName(\"differentId\")"},
                {"val deviceModel: String", "val model: String"},
                {"val deviceModel: String", "val deviceModel: Long"},
                {"val deviceModel: String", "val deviceModel: String?"},
                {"val reason: String? = null", "val reason: String? = \"unknown\""},
                {"val reportText: String", "val reportText: String,\n    @SerializedName(\"extra\") val extra: String? = null"},
                {"companion object {", "val extra = \"new\"\n    companion object {"},
                {"const val FORMAT_VERSION: Int = 1", "const val FORMAT_VERSION: Int = 2"},
                {"@SerializedName(\"deviceModel\") ", ""}
        };
        for (String[] mutation : mutations) {
            String changed = wear.replace(mutation[0], mutation[1]);
            assertNotEquals("Mutation did not apply: " + mutation[0], wear, changed);
            IllegalStateException failure = assertThrows(IllegalStateException.class,
                    () -> WearPayloadParity.checkSources(phone, changed));
            assertTrue("Unexpected failure: " + failure.getMessage(),
                    failure.getMessage().contains("does not match")
                            || failure.getMessage().contains("Unrecognized field")
                            || failure.getMessage().contains("Unsupported class body"));
        }
    }

    private static Path repositoryRoot() {
        Path path = Path.of(System.getProperty("user.dir", ".")).toAbsolutePath();
        while (path != null && !Files.isRegularFile(path.resolve("settings.gradle.kts"))) {
            path = path.getParent();
        }
        if (path == null) throw new IllegalStateException("Could not locate repository root");
        return path;
    }
}
