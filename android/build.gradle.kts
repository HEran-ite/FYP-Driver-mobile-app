allprojects {
    repositories {
        // Try Google first (usually fastest)
        google()
        // Explicit Maven Central URL (more reliable than mavenCentral() function)
        maven {
            name = "Maven Central"
            url = uri("https://repo1.maven.org/maven2/")
        }
        // Fallback to mavenCentral() function
        mavenCentral()
        // Additional fallback repositories
        maven {
            name = "JitPack"
            url = uri("https://jitpack.io")
        }
    }
    
    // Force Kotlin version to avoid version conflicts
    configurations.all {
        resolutionStrategy {
            force("org.jetbrains.kotlin:kotlin-reflect:2.1.0")
            force("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.1.0")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
