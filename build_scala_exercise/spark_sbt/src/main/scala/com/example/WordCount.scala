package com.example

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

/**
 * Spark WordCount application demonstrating basic text processing
 */
object WordCount {
  
  def main(args: Array[String]): Unit = {
    // Create Spark session
    val spark = SparkSession.builder()
      .appName("WordCount")
      .config("spark.sql.adaptive.enabled", "true")
      .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      // Input and output paths
      val inputPath = if (args.length > 0) args(0) else "input.txt"
      val outputPath = if (args.length > 1) args(1) else "output"
      
      println(s"Processing file: $inputPath")
      println(s"Output directory: $outputPath")
      
      // Read text file
      val textDF = spark.read.text(inputPath)
      
      // Perform word count
      val wordCountDF = textDF
        .select(explode(split(col("value"), "\\s+")).as("word"))
        .filter(col("word") =!= "")
        .groupBy("word")
        .count()
        .orderBy(desc("count"))
      
      // Show results
      println("Top 20 words:")
      wordCountDF.show(20)
      
      // Save results
      wordCountDF
        .coalesce(1)
        .write
        .mode("overwrite")
        .option("header", "true")
        .csv(outputPath)
      
      println(s"Results saved to: $outputPath")
      
      // Print statistics
      val totalWords = wordCountDF.agg(sum("count")).collect()(0).getLong(0)
      val uniqueWords = wordCountDF.count()
      
      println(s"Total words: $totalWords")
      println(s"Unique words: $uniqueWords")
      
    } catch {
      case e: Exception =>
        println(s"Error processing file: ${e.getMessage}")
        e.printStackTrace()
        System.exit(1)
    } finally {
      spark.stop()
    }
  }
}