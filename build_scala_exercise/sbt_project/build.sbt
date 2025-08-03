ThisBuild / version := "1.0.0"
ThisBuild / scalaVersion := "2.13.12"
ThisBuild / organization := "com.example"

lazy val root = (project in file("."))
  .settings(
    name := "sbt-demo",
    description := "SBT Demo Project with Scala",
    
    // Dependencies
    libraryDependencies ++= Seq(
      "org.scalatest" %% "scalatest" % "3.2.17" % Test,
      "org.scalactic" %% "scalactic" % "3.2.17",
      "com.typesafe.scala-logging" %% "scala-logging" % "3.9.5",
      "ch.qos.logback" % "logback-classic" % "1.4.11"
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
    
    // Assembly plugin settings
    assembly / mainClass := Some("com.example.sbtdemo.Main"),
    assembly / assemblyJarName := "sbt-demo.jar",
    
    // Assembly merge strategy
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", xs @ _*) => MergeStrategy.discard
      case PathList("reference.conf") => MergeStrategy.concat
      case _ => MergeStrategy.first
    },
    
    // Run configuration
    run / fork := true,
    run / javaOptions ++= Seq(
      "-Xmx1G",
      "-XX:+UseG1GC"
    )
  )