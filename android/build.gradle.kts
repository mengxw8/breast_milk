allprojects {
    repositories {
        google()
        mavenCentral()
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

// jni 1.0.x checks namespace through a Groovy property that AGP 9 no longer exposes.
subprojects {
    if (name == "jni" || name == "jni_flutter") {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = if (project.name == "jni") "com.github.dart_lang.jni"
                    else "com.github.dart_lang.jni_flutter"
            }
        }
    }
}
