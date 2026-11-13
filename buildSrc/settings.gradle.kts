// buildSrc holds the build logic that has to be tested: the PACKAGE-VERSIONING derivation and the release
// signing reader. It reads the root version catalog so JUnit is pinned in one place.
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        mavenCentral()
    }
    versionCatalogs {
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}

rootProject.name = "buildSrc"
