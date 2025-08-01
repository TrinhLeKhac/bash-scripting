package com.example

import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.BeforeAndAfterAll
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import com.holdenkarau.spark.testing.DataFrameSuiteBase

/**
 * Test suite for WordCount application
 */
class WordCountTest extends AnyFunSuite with DataFrameSuiteBase {
  
  test("WordCount should count words correctly") {
    val spark = SparkSession.builder()
      .appName("WordCountTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      // Create test data
      val testData = Seq(
        "hello world",
        "hello spark",
        "world of spark",
        "hello world spark"
      ).toDF("value")
      
      // Perform word count
      val wordCount = testData
        .select(explode(split(col("value"), "\\s+")).as("word"))
        .filter(col("word") =!= "")
        .groupBy("word")
        .count()
        .orderBy(desc("count"))
        .collect()
      
      // Verify results
      val wordCountMap = wordCount.map(row => row.getString(0) -> row.getLong(1)).toMap
      
      assert(wordCountMap("hello") == 3)
      assert(wordCountMap("world") == 2)
      assert(wordCountMap("spark") == 3)
      assert(wordCountMap("of") == 1)
      
    } finally {
      spark.stop()
    }
  }
  
  test("WordCount should handle empty strings") {
    val spark = SparkSession.builder()
      .appName("WordCountEmptyTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val testData = Seq(
        "",
        "   ",
        "hello",
        "",
        "world"
      ).toDF("value")
      
      val wordCount = testData
        .select(explode(split(col("value"), "\\s+")).as("word"))
        .filter(col("word") =!= "")
        .groupBy("word")
        .count()
        .collect()
      
      val wordCountMap = wordCount.map(row => row.getString(0) -> row.getLong(1)).toMap
      
      assert(wordCountMap.size == 2)
      assert(wordCountMap("hello") == 1)
      assert(wordCountMap("world") == 1)
      
    } finally {
      spark.stop()
    }
  }
  
  test("WordCount should be case sensitive") {
    val spark = SparkSession.builder()
      .appName("WordCountCaseTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val testData = Seq(
        "Hello hello HELLO",
        "World world"
      ).toDF("value")
      
      val wordCount = testData
        .select(explode(split(col("value"), "\\s+")).as("word"))
        .filter(col("word") =!= "")
        .groupBy("word")
        .count()
        .collect()
      
      val wordCountMap = wordCount.map(row => row.getString(0) -> row.getLong(1)).toMap
      
      assert(wordCountMap("Hello") == 1)
      assert(wordCountMap("hello") == 1)
      assert(wordCountMap("HELLO") == 1)
      assert(wordCountMap("World") == 1)
      assert(wordCountMap("world") == 1)
      
    } finally {
      spark.stop()
    }
  }
  
  test("WordCount should handle special characters") {
    val spark = SparkSession.builder()
      .appName("WordCountSpecialCharsTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val testData = Seq(
        "hello, world!",
        "spark-streaming",
        "data@processing"
      ).toDF("value")
      
      val wordCount = testData
        .select(explode(split(col("value"), "\\s+")).as("word"))
        .filter(col("word") =!= "")
        .groupBy("word")
        .count()
        .collect()
      
      val words = wordCount.map(_.getString(0)).toSet
      
      // Words with punctuation should be treated as separate words
      assert(words.contains("hello,"))
      assert(words.contains("world!"))
      assert(words.contains("spark-streaming"))
      assert(words.contains("data@processing"))
      
    } finally {
      spark.stop()
    }
  }
}