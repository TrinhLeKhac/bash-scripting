#!/usr/bin/env python3
"""
Pandas Data Analysis Example
Analyze data with pandas and visualization
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import os

def load_and_explore(file_path):
    """Load and explore basic data"""
    print("=== LOAD AND EXPLORE DATA ===")
    
    df = pd.read_csv(file_path)
    
    print(f"Data shape: {df.shape}")
    print(f"\nBasic information:")
    print(df.info())
    
    print(f"\nDescriptive statistics:")
    print(df.describe())
    
    print(f"\nMissing data:")
    print(df.isnull().sum())
    
    return df

def clean_data(df):
    """Clean data"""
    print("\n=== DATA CLEANING ===")
    
    # Remove duplicates
    initial_rows = len(df)
    df = df.drop_duplicates()
    print(f"Removed {initial_rows - len(df)} duplicate rows")
    
    # Handle missing values
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    categorical_cols = df.select_dtypes(include=['object']).columns
    
    # Fill numeric with median
    for col in numeric_cols:
        if df[col].isnull().sum() > 0:
            df[col].fillna(df[col].median(), inplace=True)
    
    # Fill categorical with mode
    for col in categorical_cols:
        if df[col].isnull().sum() > 0:
            df[col].fillna(df[col].mode()[0], inplace=True)
    
    print("Missing values handled")
    return df

def analyze_data(df):
    """Analyze data in detail"""
    print("\n=== DATA ANALYSIS ===")
    
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    categorical_cols = df.select_dtypes(include=['object']).columns
    
    # Correlation matrix
    if len(numeric_cols) > 1:
        print("\nCorrelation matrix:")
        corr_matrix = df[numeric_cols].corr()
        print(corr_matrix)
        
        # Create heatmap
        plt.figure(figsize=(10, 8))
        sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0)
        plt.title('Correlation Matrix')
        plt.tight_layout()
        plt.savefig('output/correlation_heatmap.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    # Analyze categorical columns
    if len(categorical_cols) > 0:
        print(f"\nCategorical columns analysis:")
        for col in categorical_cols[:3]:  # Only first 3 columns
            print(f"\n{col}:")
            print(df[col].value_counts().head())
    
    return df

def create_visualizations(df):
    """Create visualizations"""
    print("\n=== CREATE VISUALIZATIONS ===")
    
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    categorical_cols = df.select_dtypes(include=['object']).columns
    
    os.makedirs('output', exist_ok=True)
    
    # Histograms for numeric columns
    if len(numeric_cols) > 0:
        fig, axes = plt.subplots(2, 2, figsize=(12, 10))
        axes = axes.ravel()
        
        for i, col in enumerate(numeric_cols[:4]):
            df[col].hist(bins=30, ax=axes[i])
            axes[i].set_title(f'Distribution of {col}')
            axes[i].set_xlabel(col)
            axes[i].set_ylabel('Frequency')
        
        plt.tight_layout()
        plt.savefig('output/distributions.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    # Bar chart for categorical
    if len(categorical_cols) > 0 and len(categorical_cols[0]) > 0:
        plt.figure(figsize=(10, 6))
        df[categorical_cols[0]].value_counts().head(10).plot(kind='bar')
        plt.title(f'Top 10 values in {categorical_cols[0]}')
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig('output/categorical_distribution.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    print("Visualizations created in output/ directory")

def main():
    input_file = sys.argv[1] if len(sys.argv) > 1 else "../data/sample_data.csv"
    
    try:
        # Analysis pipeline
        df = load_and_explore(input_file)
        df_clean = clean_data(df)
        df_analyzed = analyze_data(df_clean)
        create_visualizations(df_analyzed)
        
        # Save results
        os.makedirs('output', exist_ok=True)
        df_clean.to_csv('output/cleaned_data.csv', index=False)
        
        print(f"\n=== COMPLETED ===")
        print("Data has been cleaned and analyzed")
        print("Results saved in output/ directory")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()