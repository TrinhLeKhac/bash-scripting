package com.example

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._
import org.apache.spark.ml.Pipeline
import org.apache.spark.ml.feature._
import org.apache.spark.ml.classification.{LogisticRegression, RandomForestClassifier}
import org.apache.spark.ml.regression.{LinearRegression, RandomForestRegressor}
import org.apache.spark.ml.evaluation.{BinaryClassificationEvaluator, MulticlassClassificationEvaluator, RegressionEvaluator}
import org.apache.spark.ml.tuning.{CrossValidator, ParamGridBuilder}

/**
 * Machine Learning Pipeline with Spark MLlib
 * Demonstrates end-to-end ML workflow
 */
object MLPipeline {
  
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("MLPipeline")
      .config("spark.sql.adaptive.enabled", "true")
      .getOrCreate()
    
    try {
      val inputPath = if (args.length > 0) args(0) else "ml_data.csv"
      val outputPath = if (args.length > 1) args(1) else "ml_output"
      val taskType = if (args.length > 2) args(2) else "classification"
      
      println(s"Input data: $inputPath")
      println(s"Output path: $outputPath")
      println(s"Task type: $taskType")
      
      taskType.toLowerCase match {
        case "classification" => runClassificationPipeline(spark, inputPath, outputPath)
        case "regression" => runRegressionPipeline(spark, inputPath, outputPath)
        case "clustering" => runClusteringPipeline(spark, inputPath, outputPath)
        case _ => 
          println("Invalid task type. Use: classification, regression, or clustering")
          System.exit(1)
      }
      
    } catch {
      case e: Exception =>
        println(s"Error in ML pipeline: ${e.getMessage}")
        e.printStackTrace()
        System.exit(1)
    } finally {
      spark.stop()
    }
  }
  
  def runClassificationPipeline(spark: SparkSession, inputPath: String, outputPath: String): Unit = {
    println("Running Classification Pipeline...")
    
    // Read data
    val data = spark.read
      .option("header", "true")
      .option("inferSchema", "true")
      .csv(inputPath)
    
    println("Data Schema:")
    data.printSchema()
    
    // Feature engineering
    val featureCols = data.columns.filter(_ != "label")
    
    val assembler = new VectorAssembler()
      .setInputCols(featureCols)
      .setOutputCol("features")
    
    val scaler = new StandardScaler()
      .setInputCol("features")
      .setOutputCol("scaledFeatures")
      .setWithStd(true)
      .setWithMean(true)
    
    // Models to compare
    val lr = new LogisticRegression()
      .setFeaturesCol("scaledFeatures")
      .setLabelCol("label")
      .setMaxIter(100)
    
    val rf = new RandomForestClassifier()
      .setFeaturesCol("scaledFeatures")
      .setLabelCol("label")
      .setNumTrees(100)
    
    // Create pipelines
    val lrPipeline = new Pipeline().setStages(Array(assembler, scaler, lr))
    val rfPipeline = new Pipeline().setStages(Array(assembler, scaler, rf))
    
    // Split data
    val Array(trainData, testData) = data.randomSplit(Array(0.8, 0.2), seed = 42)
    
    println(s"Training data: ${trainData.count()} rows")
    println(s"Test data: ${testData.count()} rows")
    
    // Train models
    println("Training Logistic Regression...")
    val lrModel = lrPipeline.fit(trainData)
    val lrPredictions = lrModel.transform(testData)
    
    println("Training Random Forest...")
    val rfModel = rfPipeline.fit(trainData)
    val rfPredictions = rfModel.transform(testData)
    
    // Evaluate models
    val evaluator = new MulticlassClassificationEvaluator()
      .setLabelCol("label")
      .setPredictionCol("prediction")
    
    val lrAccuracy = evaluator.setMetricName("accuracy").evaluate(lrPredictions)
    val lrF1 = evaluator.setMetricName("f1").evaluate(lrPredictions)
    
    val rfAccuracy = evaluator.setMetricName("accuracy").evaluate(rfPredictions)
    val rfF1 = evaluator.setMetricName("f1").evaluate(rfPredictions)
    
    println(s"Logistic Regression - Accuracy: ${lrAccuracy:.4f}, F1: ${lrF1:.4f}")
    println(s"Random Forest - Accuracy: ${rfAccuracy:.4f}, F1: ${rfF1:.4f}")
    
    // Save best model predictions
    val bestPredictions = if (lrAccuracy > rfAccuracy) lrPredictions else rfPredictions
    val bestModelName = if (lrAccuracy > rfAccuracy) "LogisticRegression" else "RandomForest"
    
    bestPredictions
      .select("label", "prediction", "probability")
      .coalesce(1)
      .write
      .mode("overwrite")
      .option("header", "true")
      .csv(s"$outputPath/classification_results_$bestModelName")
    
    println(s"Best model ($bestModelName) results saved to: $outputPath")
  }
  
  def runRegressionPipeline(spark: SparkSession, inputPath: String, outputPath: String): Unit = {
    println("Running Regression Pipeline...")
    
    val data = spark.read
      .option("header", "true")
      .option("inferSchema", "true")
      .csv(inputPath)
    
    val featureCols = data.columns.filter(_ != "target")
    
    val assembler = new VectorAssembler()
      .setInputCols(featureCols)
      .setOutputCol("features")
    
    val scaler = new StandardScaler()
      .setInputCol("features")
      .setOutputCol("scaledFeatures")
      .setWithStd(true)
      .setWithMean(true)
    
    // Models
    val lr = new LinearRegression()
      .setFeaturesCol("scaledFeatures")
      .setLabelCol("target")
      .setMaxIter(100)
    
    val rf = new RandomForestRegressor()
      .setFeaturesCol("scaledFeatures")
      .setLabelCol("target")
      .setNumTrees(100)
    
    // Pipelines
    val lrPipeline = new Pipeline().setStages(Array(assembler, scaler, lr))
    val rfPipeline = new Pipeline().setStages(Array(assembler, scaler, rf))
    
    val Array(trainData, testData) = data.randomSplit(Array(0.8, 0.2), seed = 42)
    
    // Train and evaluate
    val lrModel = lrPipeline.fit(trainData)
    val lrPredictions = lrModel.transform(testData)
    
    val rfModel = rfPipeline.fit(trainData)
    val rfPredictions = rfModel.transform(testData)
    
    val evaluator = new RegressionEvaluator()
      .setLabelCol("target")
      .setPredictionCol("prediction")
    
    val lrRmse = evaluator.setMetricName("rmse").evaluate(lrPredictions)
    val lrR2 = evaluator.setMetricName("r2").evaluate(lrPredictions)
    
    val rfRmse = evaluator.setMetricName("rmse").evaluate(rfPredictions)
    val rfR2 = evaluator.setMetricName("r2").evaluate(rfPredictions)
    
    println(s"Linear Regression - RMSE: ${lrRmse:.4f}, R²: ${lrR2:.4f}")
    println(s"Random Forest - RMSE: ${rfRmse:.4f}, R²: ${rfR2:.4f}")
    
    // Save results
    val bestPredictions = if (lrR2 > rfR2) lrPredictions else rfPredictions
    val bestModelName = if (lrR2 > rfR2) "LinearRegression" else "RandomForest"
    
    bestPredictions
      .select("target", "prediction")
      .coalesce(1)
      .write
      .mode("overwrite")
      .option("header", "true")
      .csv(s"$outputPath/regression_results_$bestModelName")
  }
  
  def runClusteringPipeline(spark: SparkSession, inputPath: String, outputPath: String): Unit = {
    println("Running Clustering Pipeline...")
    
    val data = spark.read
      .option("header", "true")
      .option("inferSchema", "true")
      .csv(inputPath)
    
    val featureCols = data.columns
    
    val assembler = new VectorAssembler()
      .setInputCols(featureCols)
      .setOutputCol("features")
    
    val scaler = new StandardScaler()
      .setInputCol("features")
      .setOutputCol("scaledFeatures")
      .setWithStd(true)
      .setWithMean(true)
    
    val kmeans = new org.apache.spark.ml.clustering.KMeans()
      .setFeaturesCol("scaledFeatures")
      .setK(3)
      .setSeed(42)
    
    val pipeline = new Pipeline().setStages(Array(assembler, scaler, kmeans))
    
    val model = pipeline.fit(data)
    val predictions = model.transform(data)
    
    // Show cluster centers
    val kmeansModel = model.stages.last.asInstanceOf[org.apache.spark.ml.clustering.KMeansModel]
    println("Cluster Centers:")
    kmeansModel.clusterCenters.foreach(println)
    
    // Cluster summary
    predictions.groupBy("prediction").count().show()
    
    predictions
      .select("prediction", "scaledFeatures")
      .coalesce(1)
      .write
      .mode("overwrite")
      .option("header", "true")
      .csv(s"$outputPath/clustering_results")
  }
}