package com.example

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.types._

/**
 * Spark Streaming Analytics application
 * Demonstrates real-time data processing capabilities
 */
object StreamingAnalytics {
  
  case class SensorReading(
    sensorId: String,
    timestamp: Long,
    temperature: Double,
    humidity: Double,
    location: String
  )
  
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("StreamingAnalytics")
      .config("spark.sql.streaming.checkpointLocation", "/tmp/checkpoint")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val inputPath = if (args.length > 0) args(0) else "/tmp/streaming_input"
      val outputPath = if (args.length > 1) args(1) else "/tmp/streaming_output"
      
      println(s"Monitoring directory: $inputPath")
      println(s"Output directory: $outputPath")
      
      // Define schema for sensor data
      val sensorSchema = StructType(Array(
        StructField("sensorId", StringType, true),
        StructField("timestamp", LongType, true),
        StructField("temperature", DoubleType, true),
        StructField("humidity", DoubleType, true),
        StructField("location", StringType, true)
      ))
      
      // Read streaming data from JSON files
      val sensorStream = spark.readStream
        .option("maxFilesPerTrigger", 1)
        .schema(sensorSchema)
        .json(inputPath)
      
      // Data transformations
      val processedStream = sensorStream
        .withColumn("processing_time", current_timestamp())
        .withColumn("temp_celsius", col("temperature"))
        .withColumn("temp_fahrenheit", col("temperature") * 9 / 5 + 32)
        .withColumn("comfort_level", 
          when(col("temperature").between(20, 25) && col("humidity").between(40, 60), "Comfortable")
          .when(col("temperature") > 30 || col("humidity") > 80, "Too Hot/Humid")
          .when(col("temperature") < 15 || col("humidity") < 30, "Too Cold/Dry")
          .otherwise("Moderate"))
      
      // Windowed aggregations
      val windowedAggregations = processedStream
        .withWatermark("processing_time", "10 minutes")
        .groupBy(
          window(col("processing_time"), "5 minutes", "1 minute"),
          col("location")
        )
        .agg(
          avg("temperature").as("avg_temperature"),
          max("temperature").as("max_temperature"),
          min("temperature").as("min_temperature"),
          avg("humidity").as("avg_humidity"),
          count("*").as("reading_count")
        )
      
      // Alert detection
      val alerts = processedStream
        .filter(
          col("temperature") > 35 || 
          col("temperature") < 5 || 
          col("humidity") > 90 || 
          col("humidity") < 10
        )
        .select(
          col("sensorId"),
          col("location"),
          col("temperature"),
          col("humidity"),
          col("processing_time"),
          lit("ALERT").as("alert_type"),
          when(col("temperature") > 35, "High Temperature")
            .when(col("temperature") < 5, "Low Temperature")
            .when(col("humidity") > 90, "High Humidity")
            .when(col("humidity") < 10, "Low Humidity")
            .as("alert_reason")
        )
      
      // Write processed data to console (for debugging)
      val consoleQuery = processedStream.writeStream
        .outputMode("append")
        .format("console")
        .option("truncate", false)
        .trigger(Trigger.ProcessingTime("30 seconds"))
        .start()
      
      // Write aggregations to files
      val aggregationQuery = windowedAggregations.writeStream
        .outputMode("append")
        .format("json")
        .option("path", s"$outputPath/aggregations")
        .option("checkpointLocation", s"$outputPath/checkpoint_agg")
        .trigger(Trigger.ProcessingTime("1 minute"))
        .start()
      
      // Write alerts to files
      val alertQuery = alerts.writeStream
        .outputMode("append")
        .format("json")
        .option("path", s"$outputPath/alerts")
        .option("checkpointLocation", s"$outputPath/checkpoint_alerts")
        .trigger(Trigger.ProcessingTime("10 seconds"))
        .start()
      
      println("Streaming queries started. Press Ctrl+C to stop...")
      
      // Wait for termination
      spark.streams.awaitAnyTermination()
      
    } catch {
      case e: Exception =>
        println(s"Error in streaming application: ${e.getMessage}")
        e.printStackTrace()
        System.exit(1)
    } finally {
      spark.stop()
    }
  }
  
  /**
   * Generate sample sensor data for testing
   */
  def generateSampleData(spark: SparkSession, outputPath: String): Unit = {
    import spark.implicits._
    
    val sampleData = Seq(
      SensorReading("sensor_001", System.currentTimeMillis(), 22.5, 45.0, "Office_A"),
      SensorReading("sensor_002", System.currentTimeMillis(), 28.3, 65.0, "Office_B"),
      SensorReading("sensor_003", System.currentTimeMillis(), 19.8, 55.0, "Warehouse"),
      SensorReading("sensor_004", System.currentTimeMillis(), 31.2, 75.0, "Server_Room"),
      SensorReading("sensor_005", System.currentTimeMillis(), 15.5, 35.0, "Storage")
    )
    
    sampleData.toDF()
      .coalesce(1)
      .write
      .mode("overwrite")
      .json(outputPath)
    
    println(s"Sample data generated at: $outputPath")
  }
}