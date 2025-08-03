ThisBuild / version := "1.0.0"
ThisBuild / scalaVersion := "2.13.12"
ThisBuild / organization := "com.example"

lazy val root = (project in file("."))
  .settings(
    name := "spark-sbt-demo",
    description := "Apache Spark application with SBT build",
    
    // Spark and Scala dependencies
    libraryDependencies ++= Seq(

      
      // Configuration and Logging
      "com.typesafe" % "config" % "1.4.2",
      "com.typesafe.scala-logging" %% "scala-logging" % "3.9.5",
      "ch.qos.logback" % "logback-classic" % "1.4.11",
      
      // Exclude conflicting SLF4J provider from Spark
      "org.apache.spark" %% "spark-core" % "3.5.0" exclude("org.apache.logging.log4j", "log4j-slf4j2-impl"),
      "org.apache.spark" %% "spark-sql" % "3.5.0" exclude("org.apache.logging.log4j", "log4j-slf4j2-impl"),
      "org.apache.spark" %% "spark-mllib" % "3.5.0" exclude("org.apache.logging.log4j", "log4j-slf4j2-impl"),
      

      
      // Testing
      "org.scalatest" %% "scalatest" % "3.2.17" % Test,
      "com.holdenkarau" %% "spark-testing-base" % "3.5.0_1.4.7" % Test
    ),
    
    // Compiler options
    scalacOptions ++= Seq(
      "-deprecation",
      "-encoding", "UTF-8",
      "-feature",
      "-unchecked",
      "-Xlint",
      "-Ywarn-dead-code",
      "-Ywarn-numeric-widen",
      "-Ywarn-value-discard"
    ),
    
    // Test configuration
    Test / testOptions += Tests.Argument("-oD"),
    Test / parallelExecution := false,
    Test / fork := true,
    Test / javaOptions ++= Seq(
      "-Xmx2G",
      "-XX:+UseG1GC"
    ),
    
    // Assembly plugin settings
    assembly / mainClass := Some("com.example.sparksbt.SparkDataProcessor"),
    assembly / assemblyJarName := "spark-sbt-demo.jar",
    
    // Assembly merge strategy for Spark
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", xs @ _*) => MergeStrategy.discard
      case PathList("reference.conf") => MergeStrategy.concat
      case PathList("application.conf") => MergeStrategy.concat
      case "log4j.properties" => MergeStrategy.first
      case x if x.endsWith(".class") => MergeStrategy.first
      case x if x.endsWith(".properties") => MergeStrategy.first
      case x if x.endsWith(".xml") => MergeStrategy.first
      case _ => MergeStrategy.first
    },
    
    // Run configuration
    run / fork := false,
    run / javaOptions ++= Seq(
      "-Xmx4G",
      "-XX:+UseG1GC",
      "-Dspark.master=local[*]",
      "-Dspark.app.name=SparkSBTDemo",

      "--add-opens=java.base/java.lang=ALL-UNNAMED",
      "--add-opens=java.base/java.lang.invoke=ALL-UNNAMED",
      "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED",
      "--add-opens=java.base/java.io=ALL-UNNAMED",
      "--add-opens=java.base/java.net=ALL-UNNAMED",
      "--add-opens=java.base/java.nio=ALL-UNNAMED",
      "--add-opens=java.base/java.util=ALL-UNNAMED",
      "--add-opens=java.base/java.util.concurrent=ALL-UNNAMED",
      "--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED",
      "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED",
      "--add-opens=java.base/sun.nio.cs=ALL-UNNAMED",
      "--add-opens=java.base/sun.security.action=ALL-UNNAMED",
      "--add-opens=java.base/sun.util.calendar=ALL-UNNAMED",
      "--add-opens=java.security.jgss/sun.security.krb5=ALL-UNNAMED",
      "--add-opens=java.base/javax.security.auth=ALL-UNNAMED"
    ),
    
    // Spark specific settings
    resolvers ++= Seq(
      "Apache Staging" at "https://repository.apache.org/content/repositories/staging/"
    )
  )