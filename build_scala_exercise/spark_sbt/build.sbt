ThisBuild / version := "1.0.0"
ThisBuild / scalaVersion := "2.12.17"
ThisBuild / organization := "com.example"

lazy val root = (project in file("."))
  .settings(
    name := "spark-sbt-demo",
    
    // Spark and Scala versions
    val sparkVersion = "3.4.0",
    val scalaVersion = "2.12.17",
    
    // Dependencies
    libraryDependencies ++= Seq(
      // Spark Core
      "org.apache.spark" %% "spark-core" % sparkVersion % "provided",
      "org.apache.spark" %% "spark-sql" % sparkVersion % "provided",
      "org.apache.spark" %% "spark-mllib" % sparkVersion % "provided",
      "org.apache.spark" %% "spark-streaming" % sparkVersion % "provided",
      
      // Configuration
      "com.typesafe" % "config" % "1.4.2",
      
      // Logging
      "org.slf4j" % "slf4j-api" % "2.0.7",
      "ch.qos.logback" % "logback-classic" % "1.4.7",
      
      // JSON processing
      "org.json4s" %% "json4s-native" % "4.0.6",
      "org.json4s" %% "json4s-jackson" % "4.0.6",
      
      // Testing
      "org.scalatest" %% "scalatest" % "3.2.15" % Test,
      "com.holdenkarau" %% "spark-testing-base" % s"${sparkVersion}_1.4.0" % Test
    ),
    
    // Compiler options
    scalacOptions ++= Seq(
      "-deprecation",
      "-encoding", "UTF-8",
      "-feature",
      "-unchecked",
      "-Xlint",
      "-Ywarn-dead-code"
    ),
    
    // Assembly settings for fat JAR
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", "services", xs @ _*) => MergeStrategy.filterDistinctLines
      case PathList("META-INF", xs @ _*) => MergeStrategy.discard
      case "application.conf" => MergeStrategy.concat
      case "reference.conf" => MergeStrategy.concat
      case _ => MergeStrategy.first
    },
    
    assembly / assemblyJarName := s"${name.value}-${version.value}-assembly.jar",
    
    // Exclude Spark from assembly (provided scope)
    assembly / assemblyExcludedJars := {
      val cp = (assembly / fullClasspath).value
      cp filter { jar =>
        jar.data.getName.contains("spark-") ||
        jar.data.getName.contains("hadoop-") ||
        jar.data.getName.contains("scala-library")
      }
    },
    
    // Test settings
    Test / parallelExecution := false,
    Test / fork := true,
    Test / javaOptions ++= Seq("-Xmx2g"),
    
    // Run settings
    run / fork := true,
    run / javaOptions ++= Seq(
      "-Xmx4g",
      "-XX:+UseG1GC"
    ),
    
    // Resolvers
    resolvers ++= Seq(
      "Apache Staging" at "https://repository.apache.org/content/repositories/staging/",
      "Maven Central" at "https://repo1.maven.org/maven2/"
    )
  )