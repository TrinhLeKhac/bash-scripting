ThisBuild / version := "1.0.0"
ThisBuild / scalaVersion := "2.12.17"
ThisBuild / organization := "com.example"

lazy val root = (project in file("."))
  .settings(
    name := "sbt-demo",
    
    // Scala compiler options
    scalacOptions ++= Seq(
      "-deprecation",
      "-encoding", "UTF-8",
      "-feature",
      "-unchecked",
      "-Xfatal-warnings",
      "-Xlint",
      "-Ywarn-dead-code",
      "-Ywarn-numeric-widen",
      "-Ywarn-value-discard"
    ),
    
    // Dependencies
    libraryDependencies ++= Seq(
      // Core dependencies
      "org.typelevel" %% "cats-core" % "2.9.0",
      "com.typesafe" % "config" % "1.4.2",
      "ch.qos.logback" % "logback-classic" % "1.4.7",
      
      // JSON processing
      "io.circe" %% "circe-core" % "0.14.5",
      "io.circe" %% "circe-generic" % "0.14.5",
      "io.circe" %% "circe-parser" % "0.14.5",
      
      // Testing
      "org.scalatest" %% "scalatest" % "3.2.15" % Test,
      "org.scalatestplus" %% "mockito-4-6" % "3.2.15.0" % Test
    ),
    
    // Assembly plugin settings
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", xs @ _*) => MergeStrategy.discard
      case "application.conf" => MergeStrategy.concat
      case "reference.conf" => MergeStrategy.concat
      case _ => MergeStrategy.first
    },
    
    assembly / assemblyJarName := s"${name.value}-${version.value}-assembly.jar",
    
    // Test settings
    Test / parallelExecution := false,
    Test / testOptions += Tests.Argument("-oDF"),
    
    // Compiler warnings as errors in CI
    scalacOptions ++= (if (sys.env.contains("CI")) Seq("-Xfatal-warnings") else Seq.empty),
    
    // Resolver for dependencies
    resolvers ++= Seq(
      "Maven Central" at "https://repo1.maven.org/maven2/",
      "Typesafe Repository" at "https://repo.typesafe.com/typesafe/releases/"
    )
  )

// Custom tasks
lazy val printClasspath = taskKey[Unit]("Print the compile classpath")
printClasspath := {
  val cp = (Compile / fullClasspath).value
  println("Compile classpath:")
  cp.files.foreach(f => println(s"  ${f.getAbsolutePath}"))
}

// Development settings
ThisBuild / watchBeforeCommand := Watch.clearScreen
ThisBuild / watchTriggeredMessage := Watch.clearScreenOnTrigger
ThisBuild / watchForceTriggerOnAnyChange := true

// Publishing settings (for libraries)
ThisBuild / publishMavenStyle := true
ThisBuild / publishTo := {
  val nexus = "https://oss.sonatype.org/"
  if (isSnapshot.value)
    Some("snapshots" at nexus + "content/repositories/snapshots")
  else
    Some("releases" at nexus + "service/local/staging/deploy/maven2")
}