package com.example.sbtdemo

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import scala.util.{Success, Failure}

class DataProcessorSpec extends AnyFlatSpec with Matchers {

  "DataProcessor.calculateStats" should "calculate correct statistics for valid numbers" in {
    val numbers = List(1.0, 2.0, 3.0, 4.0, 5.0)
    val stats = DataProcessor.calculateStats(numbers)
    
    stats("count") shouldBe 5.0
    stats("sum") shouldBe 15.0
    stats("mean") shouldBe 3.0
    stats("min") shouldBe 1.0
    stats("max") shouldBe 5.0
  }

  it should "handle empty list" in {
    val numbers = List.empty[Double]
    val stats = DataProcessor.calculateStats(numbers)
    
    stats("count") shouldBe 0.0
    stats("sum") shouldBe 0.0
    stats("mean") shouldBe 0.0
    stats("min") shouldBe 0.0
    stats("max") shouldBe 0.0
  }

  it should "handle single number" in {
    val numbers = List(42.0)
    val stats = DataProcessor.calculateStats(numbers)
    
    stats("count") shouldBe 1.0
    stats("sum") shouldBe 42.0
    stats("mean") shouldBe 42.0
    stats("min") shouldBe 42.0
    stats("max") shouldBe 42.0
  }

  "DataProcessor.filterNumbers" should "filter positive numbers correctly" in {
    val numbers = List(-2.0, -1.0, 0.0, 1.0, 2.0)
    val positive = DataProcessor.filterNumbers(numbers, _ > 0)
    
    positive shouldBe List(1.0, 2.0)
  }

  it should "filter negative numbers correctly" in {
    val numbers = List(-2.0, -1.0, 0.0, 1.0, 2.0)
    val negative = DataProcessor.filterNumbers(numbers, _ < 0)
    
    negative shouldBe List(-2.0, -1.0)
  }

  "DataProcessor.parseCsvLine" should "parse valid CSV line" in {
    val line = "1.0, 2.5, 3.7, 4.2"
    val result = DataProcessor.parseCsvLine(line)
    
    result shouldBe Success(List(1.0, 2.5, 3.7, 4.2))
  }

  it should "handle invalid CSV line" in {
    val line = "1.0, invalid, 3.7"
    val result = DataProcessor.parseCsvLine(line)
    
    result shouldBe a[Failure[_]]
  }

  it should "handle empty CSV line" in {
    val line = ""
    val result = DataProcessor.parseCsvLine(line)
    
    result shouldBe a[Failure[_]]
  }

  "DataProcessor.processCsvData" should "process multiple CSV lines correctly" in {
    val csvLines = List("1,2,3", "4,5,6", "-1,-2,3")
    val result = DataProcessor.processCsvData(csvLines)
    
    // Numbers: 1,2,3,4,5,6,-1,-2,3 = 9 total
    // Positive: 1,2,3,4,5,6,3 = 7 positive (3 appears twice)
    // Negative: -1,-2 = 2 negative
    // Sum: 1+2+3+4+5+6+(-1)+(-2)+3 = 21
    result("total_numbers") shouldBe 9
    result("positive_count") shouldBe 7
    result("negative_count") shouldBe 2
    
    val stats = result("statistics").asInstanceOf[Map[String, Double]]
    stats("count") shouldBe 9.0
    stats("sum") shouldBe 21.0
  }

  it should "handle mixed valid and invalid lines" in {
    val csvLines = List("1,2,3", "invalid,line", "4,5,6")
    val result = DataProcessor.processCsvData(csvLines)
    
    result("total_numbers") shouldBe 6
    result("positive_count") shouldBe 6
    result("negative_count") shouldBe 0
  }

  it should "handle empty input" in {
    val csvLines = List.empty[String]
    val result = DataProcessor.processCsvData(csvLines)
    
    result("total_numbers") shouldBe 0
    result("positive_count") shouldBe 0
    result("negative_count") shouldBe 0
  }
}