package com.example

import org.scalatest.funsuite.AnyFunSuite
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

/**
 * Test suite for DataAnalytics application
 */
class DataAnalyticsTest extends AnyFunSuite {
  
  test("DataAnalytics should calculate revenue correctly") {
    val spark = SparkSession.builder()
      .appName("DataAnalyticsTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      // Create test sales data
      val testData = Seq(
        ("2023-01-01", "Product A", "Electronics", 2, 100.0, "North"),
        ("2023-01-02", "Product B", "Electronics", 1, 200.0, "South"),
        ("2023-01-03", "Product C", "Books", 3, 50.0, "North"),
        ("2023-01-04", "Product A", "Electronics", 1, 100.0, "East")
      ).toDF("date", "product", "category", "quantity", "price", "region")
      
      // Calculate revenue
      val dataWithRevenue = testData.withColumn("revenue", col("quantity") * col("price"))
      
      // Test revenue calculation
      val revenues = dataWithRevenue.select("revenue").collect().map(_.getDouble(0))
      val expectedRevenues = Array(200.0, 200.0, 150.0, 100.0)
      
      assert(revenues.sameElements(expectedRevenues))
      
      // Test category revenue aggregation
      val categoryRevenue = dataWithRevenue
        .groupBy("category")
        .agg(sum("revenue").as("total_revenue"))
        .collect()
        .map(row => row.getString(0) -> row.getDouble(1))
        .toMap
      
      assert(categoryRevenue("Electronics") == 500.0)
      assert(categoryRevenue("Books") == 150.0)
      
    } finally {
      spark.stop()
    }
  }
  
  test("DataAnalytics should handle regional analysis") {
    val spark = SparkSession.builder()
      .appName("RegionalAnalysisTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val testData = Seq(
        ("2023-01-01", "Product A", "Electronics", 2, 100.0, "North"),
        ("2023-01-02", "Product B", "Electronics", 1, 200.0, "North"),
        ("2023-01-03", "Product C", "Books", 3, 50.0, "South"),
        ("2023-01-04", "Product D", "Books", 1, 75.0, "South")
      ).toDF("date", "product", "category", "quantity", "price", "region")
      
      val dataWithRevenue = testData.withColumn("revenue", col("quantity") * col("price"))
      
      val regionalAnalysis = dataWithRevenue
        .groupBy("region")
        .agg(
          sum("revenue").as("total_revenue"),
          countDistinct("product").as("unique_products"),
          avg("price").as("avg_price")
        )
        .collect()
        .map(row => row.getString(0) -> (row.getDouble(1), row.getLong(2), row.getDouble(3)))
        .toMap
      
      // North region: (2*100) + (1*200) = 400
      assert(regionalAnalysis("North")._1 == 400.0)
      assert(regionalAnalysis("North")._2 == 2) // 2 unique products
      assert(regionalAnalysis("North")._3 == 150.0) // avg price (100+200)/2
      
      // South region: (3*50) + (1*75) = 225
      assert(regionalAnalysis("South")._1 == 225.0)
      assert(regionalAnalysis("South")._2 == 2) // 2 unique products
      assert(regionalAnalysis("South")._3 == 62.5) // avg price (50+75)/2
      
    } finally {
      spark.stop()
    }
  }
  
  test("DataAnalytics should filter invalid data") {
    val spark = SparkSession.builder()
      .appName("DataFilterTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val testData = Seq(
        ("2023-01-01", "Product A", "Electronics", 2, 100.0, "North"),   // Valid
        ("2023-01-02", "Product B", "Electronics", 0, 200.0, "South"),   // Invalid quantity
        ("2023-01-03", "Product C", "Books", 3, 0.0, "North"),          // Invalid price
        ("2023-01-04", "Product D", "Books", -1, 50.0, "East"),         // Invalid quantity
        ("2023-01-05", "Product E", "Electronics", 1, 150.0, "West")    // Valid
      ).toDF("date", "product", "category", "quantity", "price", "region")
      
      // Apply data validation filter
      val cleanData = testData.filter(col("quantity") > 0 && col("price") > 0)
      
      assert(cleanData.count() == 2) // Only 2 valid records
      
      val validProducts = cleanData.select("product").collect().map(_.getString(0)).toSet
      assert(validProducts == Set("Product A", "Product E"))
      
    } finally {
      spark.stop()
    }
  }
  
  test("DataAnalytics should calculate monthly trends") {
    val spark = SparkSession.builder()
      .appName("MonthlyTrendsTest")
      .master("local[*]")
      .getOrCreate()
    
    import spark.implicits._
    
    try {
      val testData = Seq(
        ("2023-01-15", "Product A", "Electronics", 2, 100.0, "North"),
        ("2023-01-20", "Product B", "Electronics", 1, 200.0, "South"),
        ("2023-02-10", "Product C", "Books", 3, 50.0, "North"),
        ("2023-02-25", "Product D", "Books", 1, 75.0, "South"),
        ("2023-03-05", "Product E", "Electronics", 2, 125.0, "East")
      ).toDF("date", "product", "category", "quantity", "price", "region")
      
      val dataWithRevenue = testData
        .withColumn("revenue", col("quantity") * col("price"))
        .withColumn("date", to_date(col("date"), "yyyy-MM-dd"))
      
      val monthlyTrends = dataWithRevenue
        .withColumn("month", date_format(col("date"), "yyyy-MM"))
        .groupBy("month")
        .agg(
          sum("revenue").as("monthly_revenue"),
          sum("quantity").as("monthly_quantity")
        )
        .orderBy("month")
        .collect()
      
      // January: (2*100) + (1*200) = 400
      assert(monthlyTrends(0).getString(0) == "2023-01")
      assert(monthlyTrends(0).getDouble(1) == 400.0)
      assert(monthlyTrends(0).getLong(2) == 3)
      
      // February: (3*50) + (1*75) = 225
      assert(monthlyTrends(1).getString(0) == "2023-02")
      assert(monthlyTrends(1).getDouble(1) == 225.0)
      assert(monthlyTrends(1).getLong(2) == 4)
      
      // March: (2*125) = 250
      assert(monthlyTrends(2).getString(0) == "2023-03")
      assert(monthlyTrends(2).getDouble(1) == 250.0)
      assert(monthlyTrends(2).getLong(2) == 2)
      
    } finally {
      spark.stop()
    }
  }
  
  test("DataAnalytics should handle empty dataset") {
    val spark = SparkSession.builder()
      .appName("EmptyDataTest")
      .master("local[*]")
      .getOrCreate()
    
    try {
      val schema = StructType(Array(
        StructField("date", StringType, true),
        StructField("product", StringType, true),
        StructField("category", StringType, true),
        StructField("quantity", IntegerType, true),
        StructField("price", DoubleType, true),
        StructField("region", StringType, true)
      ))
      
      val emptyData = spark.createDataFrame(spark.sparkContext.emptyRDD[org.apache.spark.sql.Row], schema)
      
      // Should handle empty data gracefully
      val categoryRevenue = emptyData
        .withColumn("revenue", col("quantity") * col("price"))
        .groupBy("category")
        .agg(sum("revenue").as("total_revenue"))
        .collect()
      
      assert(categoryRevenue.length == 0)
      
    } finally {
      spark.stop()
    }
  }
}