package com.example.sparksbt

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._
import com.typesafe.scalalogging.LazyLogging

/**
 * Spark-based data processing application
 */
object SparkDataProcessor extends LazyLogging {

  // Define schema for CSV data
  val csvSchema = StructType(Array(
    StructField("values", StringType, true)
  ))

  /**
   * Create Spark session with optimized configuration
   */
  def createSparkSession(appName: String = "SparkDataProcessor"): SparkSession = {
    SparkSession.builder()
      .appName(appName)
      .master("local[*]")
      .config("spark.sql.adaptive.enabled", "true")
      .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
      .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
      .getOrCreate()
  }

  /**
   * Process CSV file using Spark DataFrame API
   */
  def processCsvFile(spark: SparkSession, filePath: String): Unit = {
    logger.info(s"Processing CSV file: $filePath")
    
    try {
      // Read CSV file
      val df = spark.read
        .option("header", "false")
        .option("inferSchema", "false")
        .schema(csvSchema)
        .csv(filePath)

      // Parse comma-separated values into individual numbers
      val numbersDF = df
        .select(explode(split(col("values"), ",")).cast(DoubleType).as("number"))
        .filter(col("number").isNotNull)

      // Calculate statistics
      val stats = numbersDF.agg(
        count("number").as("count"),
        sum("number").as("sum"),
        avg("number").as("mean"),
        min("number").as("min"),
        max("number").as("max"),
        stddev("number").as("stddev")
      ).collect()(0)

      // Count positive and negative numbers
      val positiveCount = numbersDF.filter(col("number") > 0).count()
      val negativeCount = numbersDF.filter(col("number") < 0).count()
      val zeroCount = numbersDF.filter(col("number") === 0).count()

      // Display results
      println(s"Processing file: $filePath")
      println(s"Total numbers: ${stats.getAs[Long]("count")}")
      println(s"Positive numbers: $positiveCount")
      println(s"Negative numbers: $negativeCount")
      println(s"Zero values: $zeroCount")
      println("Statistics:")
      println(f"  count: ${stats.getAs[Long]("count")}")
      println(f"  sum: ${stats.getAs[Double]("sum")}%.2f")
      println(f"  mean: ${stats.getAs[Double]("mean")}%.2f")
      println(f"  min: ${stats.getAs[Double]("min")}%.2f")
      println(f"  max: ${stats.getAs[Double]("max")}%.2f")
      println(f"  stddev: ${Option(stats.getAs[Double]("stddev")).getOrElse(0.0)}%.2f")

      logger.info("File processed successfully")
    } catch {
      case e: Exception =>
        logger.error(s"Error processing file: ${e.getMessage}")
        println(s"Error processing file: ${e.getMessage}")
    }
  }

  /**
   * Process inline data using Spark
   */
  def processInlineData(spark: SparkSession, data: String): Unit = {
    println(s"🔄 Starting to process inline data: $data")
    System.out.flush()
    logger.info(s"Processing inline data: $data")
    
    try {
      import spark.implicits._
      
      // Parse comma-separated data
      val numbers = data.split(",").map(_.trim.toDouble).toSeq
      val numbersDS = spark.createDataset(numbers)

      // Calculate statistics using Dataset API
      val stats = numbersDS.agg(
        count("value").as("count"),
        sum("value").as("sum"),
        avg("value").as("mean"),
        min("value").as("min"),
        max("value").as("max"),
        stddev("value").as("stddev")
      ).collect()(0)

      // Count categories
      val positiveCount = numbersDS.filter(_ > 0).count()
      val negativeCount = numbersDS.filter(_ < 0).count()
      val zeroCount = numbersDS.filter(_ == 0).count()

      // Display results
      println(s"\n📊 Processing data: $data")
      println(s"📈 Total numbers: ${numbers.length}")
      println(s"➕ Positive numbers: $positiveCount")
      println(s"➖ Negative numbers: $negativeCount")
      println(s"0️⃣  Zero values: $zeroCount")
      println("📋 Statistics:")
      println(f"  📊 count: ${stats.getAs[Long]("count")}")
      println(f"  ➕ sum: ${stats.getAs[Double]("sum")}%.2f")
      println(f"  📊 mean: ${stats.getAs[Double]("mean")}%.2f")
      println(f"  ⬇️  min: ${stats.getAs[Double]("min")}%.2f")
      println(f"  ⬆️  max: ${stats.getAs[Double]("max")}%.2f")
      println(f"  📏 stddev: ${Option(stats.getAs[Double]("stddev")).getOrElse(0.0)}%.2f")
      println("✅ Processing completed!")
      System.out.flush()

      logger.info("Data processed successfully")
    } catch {
      case e: Exception =>
        logger.error(s"Error processing data: ${e.getMessage}")
        println(s"Error parsing data: ${e.getMessage}")
    }
  }

  /**
   * Show usage information
   */
  def printUsage(): Unit = {
    println("Spark SBT Demo Application")
    println("Usage: spark-submit [spark-options] spark-sbt-demo.jar [options]")
    println("Options:")
    println("  --file <path>    Process CSV file")
    println("  --data <nums>    Process comma-separated numbers")
    println("  --help           Show this help")
    println("")
    println("Examples:")
    println("  spark-submit spark-sbt-demo.jar --file data/sample.csv")
    println("  spark-submit spark-sbt-demo.jar --data \"1,2,3,4,5\"")
  }

  /**
   * Main entry point
   */
  def main(args: Array[String]): Unit = {
    val spark = createSparkSession()
    
    try {
      args.toList match {
        case "--help" :: _ =>
          printUsage()
        case "--file" :: filename :: _ =>
          processCsvFile(spark, filename)
        case "--data" :: data :: _ =>
          processInlineData(spark, data)
        case Nil =>
          println("Spark SBT Demo Application - Running default example")
          val sampleData = "1,2,3,4,5,6,7,8,9,10,-1,-2,-3"
          processInlineData(spark, sampleData)
        case _ =>
          println("Invalid arguments. Use --help for usage information.")
          printUsage()
      }
    } finally {
      spark.stop()
    }
  }
}