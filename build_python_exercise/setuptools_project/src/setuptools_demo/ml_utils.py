"""
Machine Learning utilities
Demonstrates ML workflows without heavy dependencies
"""

import math
import random
from typing import List, Tuple, Dict, Any


class SimpleLinearRegression:
    """Simple linear regression implementation"""
    
    def __init__(self):
        self.slope = 0
        self.intercept = 0
        self.trained = False
    
    def fit(self, x_data: List[float], y_data: List[float]) -> None:
        """Train the linear regression model"""
        if len(x_data) != len(y_data) or len(x_data) < 2:
            raise ValueError("Invalid data for training")
        
        n = len(x_data)
        sum_x = sum(x_data)
        sum_y = sum(y_data)
        sum_xy = sum(x * y for x, y in zip(x_data, y_data))
        sum_x2 = sum(x * x for x in x_data)
        
        # Calculate slope and intercept
        self.slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
        self.intercept = (sum_y - self.slope * sum_x) / n
        self.trained = True
    
    def predict(self, x_values: List[float]) -> List[float]:
        """Make predictions"""
        if not self.trained:
            raise ValueError("Model not trained yet")
        
        return [self.slope * x + self.intercept for x in x_values]
    
    def score(self, x_test: List[float], y_test: List[float]) -> float:
        """Calculate R-squared score"""
        if not self.trained:
            raise ValueError("Model not trained yet")
        
        predictions = self.predict(x_test)
        y_mean = sum(y_test) / len(y_test)
        
        ss_res = sum((y_true - y_pred) ** 2 for y_true, y_pred in zip(y_test, predictions))
        ss_tot = sum((y_true - y_mean) ** 2 for y_true in y_test)
        
        return 1 - (ss_res / ss_tot) if ss_tot != 0 else 0


class KMeansClustering:
    """Simple K-means clustering implementation"""
    
    def __init__(self, k: int = 3, max_iters: int = 100):
        self.k = k
        self.max_iters = max_iters
        self.centroids = []
        self.labels = []
    
    def fit(self, data: List[List[float]]) -> None:
        """Fit K-means clustering"""
        if len(data) < self.k:
            raise ValueError("Not enough data points for clustering")
        
        # Initialize centroids randomly
        self.centroids = random.sample(data, self.k)
        
        for _ in range(self.max_iters):
            # Assign points to closest centroid
            new_labels = []
            for point in data:
                distances = [self._euclidean_distance(point, centroid) 
                           for centroid in self.centroids]
                new_labels.append(distances.index(min(distances)))
            
            # Check for convergence
            if new_labels == self.labels:
                break
            
            self.labels = new_labels
            
            # Update centroids
            new_centroids = []
            for i in range(self.k):
                cluster_points = [data[j] for j, label in enumerate(self.labels) if label == i]
                if cluster_points:
                    centroid = [sum(dim) / len(cluster_points) 
                              for dim in zip(*cluster_points)]
                    new_centroids.append(centroid)
                else:
                    new_centroids.append(self.centroids[i])
            
            self.centroids = new_centroids
    
    def predict(self, data: List[List[float]]) -> List[int]:
        """Predict cluster labels for new data"""
        labels = []
        for point in data:
            distances = [self._euclidean_distance(point, centroid) 
                        for centroid in self.centroids]
            labels.append(distances.index(min(distances)))
        return labels
    
    def _euclidean_distance(self, point1: List[float], point2: List[float]) -> float:
        """Calculate Euclidean distance between two points"""
        return math.sqrt(sum((a - b) ** 2 for a, b in zip(point1, point2)))


class DataSplitter:
    """Utility for splitting data into train/test sets"""
    
    @staticmethod
    def train_test_split(data: List[Any], test_size: float = 0.2, 
                        random_state: int = None) -> Tuple[List[Any], List[Any]]:
        """Split data into training and testing sets"""
        if random_state:
            random.seed(random_state)
        
        data_copy = data.copy()
        random.shuffle(data_copy)
        
        split_index = int(len(data_copy) * (1 - test_size))
        train_data = data_copy[:split_index]
        test_data = data_copy[split_index:]
        
        return train_data, test_data
    
    @staticmethod
    def cross_validation_split(data: List[Any], k_folds: int = 5) -> List[Tuple[List[Any], List[Any]]]:
        """Create k-fold cross-validation splits"""
        data_copy = data.copy()
        random.shuffle(data_copy)
        
        fold_size = len(data_copy) // k_folds
        folds = []
        
        for i in range(k_folds):
            start_idx = i * fold_size
            end_idx = start_idx + fold_size if i < k_folds - 1 else len(data_copy)
            
            test_fold = data_copy[start_idx:end_idx]
            train_fold = data_copy[:start_idx] + data_copy[end_idx:]
            
            folds.append((train_fold, test_fold))
        
        return folds


class ModelEvaluator:
    """Model evaluation utilities"""
    
    @staticmethod
    def mean_squared_error(y_true: List[float], y_pred: List[float]) -> float:
        """Calculate Mean Squared Error"""
        return sum((true - pred) ** 2 for true, pred in zip(y_true, y_pred)) / len(y_true)
    
    @staticmethod
    def mean_absolute_error(y_true: List[float], y_pred: List[float]) -> float:
        """Calculate Mean Absolute Error"""
        return sum(abs(true - pred) for true, pred in zip(y_true, y_pred)) / len(y_true)
    
    @staticmethod
    def accuracy_score(y_true: List[int], y_pred: List[int]) -> float:
        """Calculate accuracy for classification"""
        correct = sum(1 for true, pred in zip(y_true, y_pred) if true == pred)
        return correct / len(y_true)
    
    @staticmethod
    def confusion_matrix(y_true: List[int], y_pred: List[int]) -> Dict[str, Dict[str, int]]:
        """Generate confusion matrix"""
        classes = sorted(set(y_true + y_pred))
        matrix = {str(true_class): {str(pred_class): 0 for pred_class in classes} 
                 for true_class in classes}
        
        for true, pred in zip(y_true, y_pred):
            matrix[str(true)][str(pred)] += 1
        
        return matrix