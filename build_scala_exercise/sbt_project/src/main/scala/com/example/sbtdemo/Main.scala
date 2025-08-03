package com.example.sbtdemo

import scala.io.Source
import scala.util.{Try, Success, Failure}

/**
 * Main application entry point
 */
object Main extends App {

  def printUsage(): Unit = {
    println("SBT Demo Application")
    println("Usage: sbt run [options]")
    println("Options:")
    println("  --file <path>    Process CSV file")
    println("  --data <nums>    Process comma-separated numbers")
    println("  --help           Show this help")
  }

  def processFile(filename: String): Unit = {
    Try {
      val lines  = Source.fromFile(filename).getLines().toList
      val result = DataProcessor.processCsvData(lines)

      println(s"Processing file: $filename")
      println(s"Total numbers: ${result("total_numbers")}")
      println(s"Positive numbers: ${result("positive_count")}")
      println(s"Negative numbers: ${result("negative_count")}")

      val stats = result("statistics").asInstanceOf[Map[String, Double]]
      println("Statistics:")
      stats.foreach {
        case (key, value) =>
          println(f"  $key: $value%.2f")
      }
    } match {
      case Success(_)  => println("File processed successfully")
      case Failure(ex) => println(s"Error processing file: ${ex.getMessage}")
    }
  }

  def processData(data: String): Unit = {
    DataProcessor.parseCsvLine(data) match {
      case Success(numbers) =>
        val stats = DataProcessor.calculateStats(numbers)
        println(s"Processing data: $data")
        println("Statistics:")
        stats.foreach {
          case (key, value) =>
            println(f"  $key: $value%.2f")
        }
      case Failure(ex) =>
        println(s"Error parsing data: ${ex.getMessage}")
    }
  }

  // Parse command line arguments
  args.toList match {
    case "--help" :: _ =>
      printUsage()
    case "--file" :: filename :: _ =>
      processFile(filename)
    case "--data" :: data :: _ =>
      processData(data)
    case Nil =>
      println("SBT Demo Application - Running default example")
      val sampleData = List("1,2,3,4,5", "6,7,8,9,10", "-1,-2,3,4")
      val result     = DataProcessor.processCsvData(sampleData)
      println("Sample data processing:")
      println(result)
    case _ =>
      println("Invalid arguments. Use --help for usage information.")
      printUsage()
  }
}
