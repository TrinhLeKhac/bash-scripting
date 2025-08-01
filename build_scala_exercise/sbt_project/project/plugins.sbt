// SBT plugins for enhanced functionality

// Assembly plugin for creating fat JARs
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "2.1.1")

// Code formatting
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.5.0")

// Dependency updates
addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.6.4")

// Test coverage
addSbtPlugin("org.scoverage" % "sbt-scoverage" % "2.0.7")

// Native packager for creating distributions
addSbtPlugin("com.github.sbt" % "sbt-native-packager" % "1.9.16")

// Build info plugin
addSbtPlugin("com.eed3si9n" % "sbt-buildinfo" % "0.11.0")

// Git versioning
addSbtPlugin("com.github.sbt" % "sbt-git" % "2.0.1")

// Dependency graph
addSbtPlugin("net.virtual-void" % "sbt-dependency-graph" % "0.10.0-RC1")