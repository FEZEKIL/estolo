buildscript {
    repositories {
        google()
        mavenCentral()
        // Add the Maven address.
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
    dependencies {
        // Add dependencies.
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("com.huawei.agconnect:agcp:1.9.1.300")
        classpath("com.google.gms:google-services:4.4.4")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Add the Maven address.
        maven { url = uri("https://developer.huawei.com/repo/") }
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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = project.group.toString()
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
