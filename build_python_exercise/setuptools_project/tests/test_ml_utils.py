"""
Tests for ml_utils module
"""

import pytest
from setuptools_demo.ml_utils import (
    SimpleLinearRegression,
    KMeansClustering,
    DataSplitter,
    ModelEvaluator
)


class TestSimpleLinearRegression:
    """Test SimpleLinearRegression class"""
    
    def test_fit_and_predict(self):
        """Test basic fit and predict functionality"""
        model = SimpleLinearRegression()
        x_data = [1, 2, 3, 4, 5]
        y_data = [2, 4, 6, 8, 10]  # y = 2x
        
        model.fit(x_data, y_data)
        
        assert model.trained is True
        assert abs(model.slope - 2.0) < 0.01
        assert abs(model.intercept - 0.0) < 0.01
        
        predictions = model.predict([6, 7])
        assert abs(predictions[0] - 12.0) < 0.01
        assert abs(predictions[1] - 14.0) < 0.01
    
    def test_fit_invalid_data(self):
        """Test fit with invalid data"""
        model = SimpleLinearRegression()
        
        with pytest.raises(ValueError):
            model.fit([1], [2, 3])  # Mismatched lengths
        
        with pytest.raises(ValueError):
            model.fit([1], [2])  # Too few data points
    
    def test_predict_untrained(self):
        """Test predict on untrained model"""
        model = SimpleLinearRegression()
        
        with pytest.raises(ValueError):
            model.predict([1, 2, 3])
    
    def test_score(self):
        """Test R-squared score calculation"""
        model = SimpleLinearRegression()
        x_data = [1, 2, 3, 4, 5]
        y_data = [2, 4, 6, 8, 10]
        
        model.fit(x_data, y_data)
        score = model.score(x_data, y_data)
        
        assert score > 0.99  # Perfect fit should have high R²


class TestKMeansClustering:
    """Test KMeansClustering class"""
    
    def test_fit_and_predict(self):
        """Test basic clustering functionality"""
        data = [[1, 1], [1, 2], [2, 1], [8, 8], [8, 9], [9, 8]]
        kmeans = KMeansClustering(k=2, max_iters=10)
        
        kmeans.fit(data)
        
        assert len(kmeans.centroids) == 2
        assert len(kmeans.labels) == len(data)
        
        # Test prediction
        new_data = [[1.5, 1.5], [8.5, 8.5]]
        labels = kmeans.predict(new_data)
        assert len(labels) == 2
    
    def test_fit_insufficient_data(self):
        """Test clustering with insufficient data"""
        data = [[1, 1], [2, 2]]
        kmeans = KMeansClustering(k=3)
        
        with pytest.raises(ValueError):
            kmeans.fit(data)
    
    def test_euclidean_distance(self):
        """Test distance calculation"""
        kmeans = KMeansClustering()
        distance = kmeans._euclidean_distance([0, 0], [3, 4])
        assert abs(distance - 5.0) < 0.01


class TestDataSplitter:
    """Test DataSplitter class"""
    
    def test_train_test_split(self):
        """Test train/test split functionality"""
        data = list(range(100))
        train, test = DataSplitter.train_test_split(data, test_size=0.2, random_state=42)
        
        assert len(train) == 80
        assert len(test) == 20
        assert len(set(train) & set(test)) == 0  # No overlap
        assert set(train) | set(test) == set(data)  # All data included
    
    def test_cross_validation_split(self):
        """Test k-fold cross-validation split"""
        data = list(range(50))
        folds = DataSplitter.cross_validation_split(data, k_folds=5)
        
        assert len(folds) == 5
        
        for train_fold, test_fold in folds:
            assert len(test_fold) == 10
            assert len(train_fold) == 40
            assert len(set(train_fold) & set(test_fold)) == 0


class TestModelEvaluator:
    """Test ModelEvaluator class"""
    
    def test_mean_squared_error(self):
        """Test MSE calculation"""
        y_true = [1, 2, 3, 4, 5]
        y_pred = [1.1, 2.1, 2.9, 4.1, 4.9]
        
        mse = ModelEvaluator.mean_squared_error(y_true, y_pred)
        assert abs(mse - 0.01) < 0.001  # Expected MSE is 0.01, not 0.02
    
    def test_mean_absolute_error(self):
        """Test MAE calculation"""
        y_true = [1, 2, 3, 4, 5]
        y_pred = [1.1, 2.1, 2.9, 4.1, 4.9]
        
        mae = ModelEvaluator.mean_absolute_error(y_true, y_pred)
        assert abs(mae - 0.1) < 0.01
    
    def test_accuracy_score(self):
        """Test accuracy calculation"""
        y_true = [0, 1, 1, 0, 1]
        y_pred = [0, 1, 0, 0, 1]
        
        accuracy = ModelEvaluator.accuracy_score(y_true, y_pred)
        assert accuracy == 0.8  # 4 out of 5 correct
    
    def test_confusion_matrix(self):
        """Test confusion matrix generation"""
        y_true = [0, 1, 1, 0, 1, 2, 2, 0]
        y_pred = [0, 1, 0, 0, 1, 2, 1, 0]
        
        cm = ModelEvaluator.confusion_matrix(y_true, y_pred)
        
        assert cm['0']['0'] == 3  # True 0, Pred 0
        assert cm['1']['1'] == 2  # True 1, Pred 1
        assert cm['1']['0'] == 1  # True 1, Pred 0
        assert cm['2']['2'] == 1  # True 2, Pred 2
        assert cm['2']['1'] == 1  # True 2, Pred 1


class TestMLIntegration:
    """Integration tests for ML workflow"""
    
    def test_complete_ml_workflow(self):
        """Test complete ML workflow"""
        # Generate sample data
        import random
        random.seed(42)
        
        # Create linear data with noise
        x_data = [i for i in range(1, 21)]
        y_data = [2 * x + random.uniform(-1, 1) for x in x_data]
        
        # Split data
        combined_data = list(zip(x_data, y_data))
        train_data, test_data = DataSplitter.train_test_split(
            combined_data, test_size=0.3, random_state=42
        )
        
        x_train, y_train = zip(*train_data)
        x_test, y_test = zip(*test_data)
        
        # Train model
        model = SimpleLinearRegression()
        model.fit(list(x_train), list(y_train))
        
        # Make predictions
        predictions = model.predict(list(x_test))
        
        # Evaluate
        mse = ModelEvaluator.mean_squared_error(list(y_test), predictions)
        mae = ModelEvaluator.mean_absolute_error(list(y_test), predictions)
        
        assert mse < 2.0  # Should be reasonably low for linear data
        assert mae < 1.5
        assert model.trained is True
    
    def test_clustering_workflow(self):
        """Test clustering workflow"""
        # Create clustered data
        cluster1 = [[1 + i*0.1, 1 + i*0.1] for i in range(10)]
        cluster2 = [[5 + i*0.1, 5 + i*0.1] for i in range(10)]
        data = cluster1 + cluster2
        
        # Apply clustering
        kmeans = KMeansClustering(k=2, max_iters=50)
        kmeans.fit(data)
        
        # Check that clusters are reasonable
        assert len(set(kmeans.labels)) <= 2  # Should have at most 2 clusters
        
        # Test prediction on new data
        new_points = [[1.5, 1.5], [5.5, 5.5]]
        labels = kmeans.predict(new_points)
        
        assert len(labels) == 2
        assert all(0 <= label < 2 for label in labels)