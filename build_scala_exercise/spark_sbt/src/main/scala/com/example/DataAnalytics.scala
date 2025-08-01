package com.example

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

/**
 * Spark Data Analytics application demonstrating advanced data processing
 */
object DataAnalytics {
  
  case class SalesRecord(
    date: String,
    product: String,
    category: String,
    quantity: Int,
    price: Double,
    region: String
  )
  
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("DataAnalytics")
      .config("spark.sql.adaptive.enabled", "true")
      .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val inputPath = if (args.length > 0) args(0) else "sales_data.csv"
      val outputPath = if (args.length > 1) args(1) else "analytics_output"
      
      println(s"Analyzing data from: $inputPath")
      
      // Define schema for better performance
      val schema = StructType(Array(
        StructField("date", StringType, true),
        StructField("product", StringType, true),
        StructField("category", StringType, true),
        StructField("quantity", IntegerType, true),
        StructField("price", DoubleType, true),
        StructField("region", StringType, true)
      ))
      
      // Read CSV data
      val salesDF = spark.read
        .option("header", "true")
        .schema(schema)
        .csv(inputPath)
      
      // Data validation and cleaning
      val cleanDF = salesDF
        .filter(col("quantity") > 0 && col("price") > 0)
        .withColumn("revenue", col("quantity") * col("price"))
        .withColumn("date", to_date(col("date"), "yyyy-MM-dd"))
      
      // Cache for multiple operations
      cleanDF.cache()
      
      println(s"Total records: ${cleanDF.count()}")
      
      // 1. Revenue by category
      val categoryRevenue = cleanDF
        .groupBy("category")
        .agg(
          sum("revenue").as("total_revenue"),
          avg("revenue").as("avg_revenue"),
          count("*").as("transaction_count")
        )
        .orderBy(desc("total_revenue"))
      
      println("Revenue by Category:")
      categoryRevenue.show()
      
      // 2. Top products by revenue
      val topProducts = cleanDF
        .groupBy("product", "category")
        .agg(sum("revenue").as("total_revenue"))
        .orderBy(desc("total_revenue"))
        .limit(10)
      
      println("Top 10 Products by Revenue:")
      topProducts.show()
      
      // 3. Regional analysis
      val regionalAnalysis = cleanDF
        .groupBy("region")
        .agg(
          sum("revenue").as("total_revenue"),
          countDistinct("product").as("unique_products"),
          avg("price").as("avg_price")
        )
        .orderBy(desc("total_revenue"))
      
      println("Regional Analysis:")
      regionalAnalysis.show()
      
      // 4. Monthly trends
      val monthlyTrends = cleanDF
        .withColumn("month", date_format(col("date"), "yyyy-MM"))
        .groupBy("month")
        .agg(
          sum("revenue").as("monthly_revenue"),
          sum("quantity").as("monthly_quantity")
        )
        .orderBy("month")
      
      println("Monthly Trends:")
      monthlyTrends.show()
      
      // Save results
      categoryRevenue.write.mode("overwrite").parquet(s"$outputPath/category_revenue")
      topProducts.write.mode("overwrite").parquet(s"$outputPath/top_products")
      regionalAnalysis.write.mode("overwrite").parquet(s"$outputPath/regional_analysis")
      monthlyTrends.write.mode("overwrite").parquet(s"$outputPath/monthly_trends")
      
      // Summary statistics
      val totalRevenue = cleanDF.agg(sum("revenue")).collect()(0).getDouble(0)
      val avgOrderValue = cleanDF.agg(avg("revenue")).collect()(0).getDouble(0)
      val totalTransactions = cleanDF.count()
      
      println(s"Summary Statistics:")
      println(s"Total Revenue: $$${totalRevenue}")
      println(s"Average Order Value: $$${avgOrderValue}")
      println(s"Total Transactions: ${totalTransactions}")
      
      println(s"Analysis results saved to: $outputPath")
      
    } catch {
      case e: Exception =>
        println(s"Error during analysis: ${e.getMessage}")
        e.printStackTrace()
        System.exit(1)
    } finally {
      spark.stop()
    }
  }
}