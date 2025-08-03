package com.example.sbtdemo

import scala.util.{Try, Success, Failure}

/**
 * Data processing utilities for SBT demo project
 */
object DataProcessor {

  /**
   * Calculate statistics for a list of numbers
   */
  def calculateStats(numbers: List[Double]): Map[String, Double] = {
    if (numbers.isEmpty) {
      Map("count" -> 0, "sum" -> 0, "mean" -> 0, "min" -> 0, "max" -> 0)
    } else {
      Map(
        "count" -> numbers.length.toDouble,
        "sum"   -> numbers.sum,
        "mean"  -> numbers.sum / numbers.length,
        "min"   -> numbers.min,
        "max"   -> numbers.max
      )
    }
  }

  /**
   * Filter numbers based on condition
   */
  def filterNumbers(numbers: List[Double], condition: Double => Boolean): List[Double] = {
    numbers.filter(condition)
  }

  /**
   * Parse CSV line to numbers
   */
  def parseCsvLine(line: String): Try[List[Double]] = {
    Try {
      line.split(",").map(_.trim.toDouble).toList
    }
  }

  /**
   * Process CSV data and return statistics
   */
  def processCsvData(csvLines: List[String]): Map[String, Any] = {
    val allNumbers = csvLines.flatMap { line =>
      parseCsvLine(line) match {
        case Success(numbers) => numbers
        case Failure(_)       => List.empty[Double]
      }
    }

    val stats           = calculateStats(allNumbers)
    val positiveNumbers = filterNumbers(allNumbers, _ > 0)
    val negativeNumbers = filterNumbers(allNumbers, _ < 0)

    Map(
      "total_numbers"  -> allNumbers.length,
      "positive_count" -> positiveNumbers.length,
      "negative_count" -> negativeNumbers.length,
      "statistics"     -> stats
    )
  }

}
