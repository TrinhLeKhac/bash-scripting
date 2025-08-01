#!/usr/bin/env python3
"""
Data Analysis Demo Script
Demonstrates data processing capabilities using setuptools_demo package
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'setuptools_project', 'src'))

from setuptools_demo.data_processor import DataProcessor
from setuptools_demo.ml_utils import SimpleLinearRegression, KMeansClustering, DataSplitter
import json


def main():
    print("🔍 Data Analysis Demo")
    print("=" * 50)
    
    # Initialize data processor
    processor = DataProcessor()
    
    # Load sample data
    data_file = os.path.join(os.path.dirname(__file__), '..', 'demo_data', 'sample_sales.csv')
    
    try:
        processor.load_csv(data_file)
        print(f"✅ Loaded {len(processor.data)} records from {data_file}")
        
        # Display data summary
        summary = processor.get_summary()
        print(f"\n📊 Data Summary:")
        print(f"   Columns: {', '.join(summary['columns'])}")
        print(f"   Sample data:")
        for i, row in enumerate(summary['sample_data']):
            print(f"   {i+1}. {row}")
        
        # Category analysis
        print(f"\n📈 Revenue by Category:")
        category_revenue = processor.aggregate('category', 'price', 'sum')
        for category, revenue in sorted(category_revenue.items(), key=lambda x: x[1], reverse=True):
            print(f"   {category}: ${revenue:,.2f}")
        
        # Regional analysis
        print(f"\n🌍 Regional Analysis:")
        regional_stats = processor.group_by('region')
        for region, records in regional_stats.items():
            total_revenue = sum(float(r['price']) * int(r['quantity']) for r in records)
            avg_price = sum(float(r['price']) for r in records) / len(records)
            print(f"   {region}: {len(records)} products, ${total_revenue:,.2f} revenue, ${avg_price:.2f} avg price")
        
        # Price statistics
        print(f"\n💰 Price Statistics:")
        price_stats = processor.get_statistics('price')
        for stat, value in price_stats.items():
            print(f"   {stat.replace('_', ' ').title()}: ${value:,.2f}")
        
        # Filter high-value products
        print(f"\n💎 High-Value Products (>$500):")
        high_value = processor.filter_data({'category': 'Electronics'})
        high_value_filtered = [p for p in high_value if float(p['price']) > 500]
        for product in high_value_filtered:
            revenue = float(product['price']) * int(product['quantity'])
            print(f"   {product['product']}: ${float(product['price']):,.2f} x {product['quantity']} = ${revenue:,.2f}")
        
        # Export filtered data
        output_file = os.path.join(os.path.dirname(__file__), 'high_value_products.json')
        processor.export_json(output_file, high_value_filtered)
        print(f"\n💾 Exported {len(high_value_filtered)} high-value products to {output_file}")
        
        # Simple ML demo
        print(f"\n🤖 Machine Learning Demo:")
        demo_ml_analysis(processor.data)
        
    except FileNotFoundError:
        print(f"❌ Error: Could not find data file {data_file}")
        print("   Please ensure the demo data exists")
    except Exception as e:
        print(f"❌ Error during analysis: {e}")


def demo_ml_analysis(data):
    """Demonstrate simple ML capabilities"""
    
    # Prepare data for regression (price vs quantity)
    prices = [float(row['price']) for row in data]
    quantities = [float(row['quantity']) for row in data]
    
    # Simple linear regression
    lr = SimpleLinearRegression()
    lr.fit(quantities, prices)
    
    # Make predictions
    test_quantities = [1, 5, 10, 15, 20]
    predictions = lr.predict(test_quantities)
    
    print(f"   📊 Price vs Quantity Regression:")
    print(f"      Slope: {lr.slope:.2f}, Intercept: {lr.intercept:.2f}")
    print(f"      Predictions:")
    for qty, pred in zip(test_quantities, predictions):
        print(f"        Quantity {qty} → Price ${pred:.2f}")
    
    # Clustering demo (price and quantity)
    print(f"\n   🎯 K-Means Clustering (Price & Quantity):")
    clustering_data = [[float(row['price']), float(row['quantity'])] for row in data]
    
    kmeans = KMeansClustering(k=3)
    kmeans.fit(clustering_data)
    
    print(f"      Cluster Centers:")
    for i, center in enumerate(kmeans.centroids):
        print(f"        Cluster {i+1}: Price=${center[0]:.2f}, Quantity={center[1]:.1f}")
    
    # Show cluster assignments
    labels = kmeans.predict(clustering_data)
    cluster_counts = {}
    for label in labels:
        cluster_counts[label] = cluster_counts.get(label, 0) + 1
    
    print(f"      Cluster Distribution:")
    for cluster, count in cluster_counts.items():
        print(f"        Cluster {cluster+1}: {count} products")


if __name__ == "__main__":
    main()