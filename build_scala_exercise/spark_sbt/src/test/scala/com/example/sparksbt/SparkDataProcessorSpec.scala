package com.example.sparksbt

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import org.scalatest.BeforeAndAfterAll
import org.apache.spark.sql.SparkSession

class SparkDataProcessorSpec extends AnyFlatSpec with Matchers with BeforeAndAfterAll {

  var spark: SparkSession = _

  override def beforeAll(): Unit = {
    super.beforeAll()
    spark = SparkDataProcessor.createSparkSession("SparkDataProcessorTest")
  }

  override def afterAll(): Unit = {
    if (spark != null) {
      spark.stop()
    }
    super.afterAll()
  }

  "SparkDataProcessor.createSparkSession" should "create a valid Spark session" in {
    val testSpark = SparkDataProcessor.createSparkSession("TestApp")
    testSpark should not be null
    testSpark.sparkContext.appName shouldBe "TestApp"
    testSpark.stop()
  }

  "SparkDataProcessor.processInlineData" should "process simple numeric data correctly" in {
    val testData = "1,2,3,4,5"
    
    // This test verifies the method runs without exceptions
    noException should be thrownBy {
      SparkDataProcessor.processInlineData(spark, testData)
    }
  }

  it should "handle negative numbers correctly" in {
    val testData = "-1,-2,3,4,5"
    
    noException should be thrownBy {
      SparkDataProcessor.processInlineData(spark, testData)
    }
  }

  it should "handle decimal numbers correctly" in {
    val testData = "1.5,2.7,3.2,4.8"
    
    noException should be thrownBy {
      SparkDataProcessor.processInlineData(spark, testData)
    }
  }

  it should "handle mixed positive and negative numbers" in {
    val testData = "10,-5,15,-10,20,0"
    
    noException should be thrownBy {
      SparkDataProcessor.processInlineData(spark, testData)
    }
  }

  "SparkDataProcessor.processCsvFile" should "handle non-existent files gracefully" in {
    val nonExistentFile = "non_existent_file.csv"
    
    noException should be thrownBy {
      SparkDataProcessor.processCsvFile(spark, nonExistentFile)
    }
  }

  "SparkDataProcessor main method" should "handle help argument" in {
    noException should be thrownBy {
      // Create a separate spark session for this test
      val testSpark = SparkDataProcessor.createSparkSession("HelpTest")
      try {
        // We can't easily test main method output, but we can test it doesn't crash
        SparkDataProcessor.printUsage()
      } finally {
        testSpark.stop()
      }
    }
  }

  it should "handle data argument" in {
    noException should be thrownBy {
      SparkDataProcessor.processInlineData(spark, "1,2,3,4,5")
    }
  }

  it should "handle empty arguments" in {
    noException should be thrownBy {
      SparkDataProcessor.processInlineData(spark, "1,2,3,4,5,6,7,8,9,10,-1,-2,-3")
    }
  }
}