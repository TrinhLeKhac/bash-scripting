# Python & PySpark Data Processing Examples

## Tổng quan
Bộ sưu tập các ví dụ xử lý dữ liệu với Python và PySpark, bao gồm WordCount, phân tích dữ liệu, ETL pipeline và visualization.

## Cấu trúc thư mục
```
build_python_exercise/
├── pyspark_examples/          # Ví dụ PySpark
│   ├── wordcount.py          # WordCount cơ bản
│   ├── data_analysis.py      # Phân tích dữ liệu CSV
│   └── etl_pipeline.py       # ETL Pipeline
├── python_examples/           # Ví dụ Python
│   ├── pandas_analysis.py    # Phân tích với pandas
│   └── data_generator.py     # Tạo dữ liệu mẫu
├── data/                     # Dữ liệu mẫu
├── output/                   # Kết quả đầu ra
├── requirements.txt          # Dependencies
├── run_examples.sh          # Script chạy ví dụ
└── README.md               # Hướng dẫn này
```

## Cài đặt nhanh

### 1. Thiết lập môi trường
```bash
# Chạy tất cả ví dụ
./run_examples.sh all

# Hoặc từng bước
./run_examples.sh setup    # Thiết lập môi trường
./run_examples.sh data     # Tạo dữ liệu mẫu
./run_examples.sh python   # Chạy ví dụ Python
./run_examples.sh pyspark  # Chạy ví dụ PySpark
```

## Ví dụ PySpark

### 1. WordCount (wordcount.py)
Đếm tần suất xuất hiện của từng từ trong text file.

```bash
# Chạy với file mặc định
python pyspark_examples/wordcount.py

# Chạy với file tùy chọn
python pyspark_examples/wordcount.py data/sample_text.txt
```

**Tính năng:**
- Xử lý text: lowercase, loại bỏ ký tự đặc biệt
- Tách từ và đếm tần suất
- Sắp xếp theo tần suất giảm dần
- Lưu kết quả ra CSV

### 2. Data Analysis (data_analysis.py)
Phân tích dữ liệu CSV với các thao tác cơ bản.

```bash
python pyspark_examples/data_analysis.py data/sample_data.csv
```

**Tính năng:**
- Hiển thị thông tin cơ bản (schema, count, describe)
- Kiểm tra dữ liệu thiếu
- Lọc dữ liệu theo điều kiện
- Group by và aggregation
- Thống kê mô tả

### 3. ETL Pipeline (etl_pipeline.py)
Pipeline ETL hoàn chỉnh với Extract, Transform, Load.

```bash
python pyspark_examples/etl_pipeline.py data/sample_data.csv output/etl_result
```

**Tính năng:**
- **Extract**: Đọc dữ liệu từ CSV
- **Transform**: Làm sạch, chuẩn hóa, tạo cột mới
- **Load**: Lưu ra CSV và Parquet
- Xử lý lỗi và logging

## Ví dụ Python

### 1. Pandas Analysis (pandas_analysis.py)
Phân tích dữ liệu chi tiết với pandas và visualization.

```bash
python python_examples/pandas_analysis.py data/sample_data.csv
```

**Tính năng:**
- Khám phá dữ liệu cơ bản
- Làm sạch dữ liệu (duplicates, missing values)
- Ma trận tương quan
- Tạo biểu đồ (histogram, bar chart, heatmap)
- Lưu kết quả và visualization

### 2. Data Generator (data_generator.py)
Tạo dữ liệu mẫu cho các ví dụ khác.

```bash
# Tạo 1000 dòng dữ liệu
python python_examples/data_generator.py 1000

# Tạo 5000 dòng dữ liệu
python python_examples/data_generator.py 5000
```

**Tạo ra:**
- `sample_data.csv`: Dữ liệu nhân viên với các trường age, salary, department, etc.
- `sample_text.txt`: Text data cho WordCount

## Chạy từng ví dụ

### PySpark Examples
```bash
# Activate virtual environment
source venv/bin/activate

# WordCount
cd pyspark_examples
python wordcount.py ../data/sample_text.txt

# Data Analysis
python data_analysis.py ../data/sample_data.csv

# ETL Pipeline
python etl_pipeline.py ../data/sample_data.csv ../output/etl_result
```

### Python Examples
```bash
# Pandas Analysis
cd python_examples
python pandas_analysis.py ../data/sample_data.csv

# Generate new data
python data_generator.py 2000
```

## Kết quả đầu ra

### WordCount
- `output/wordcount_result/`: CSV file với word counts
- Console: Top 20 từ xuất hiện nhiều nhất

### Data Analysis (PySpark)
- Console: Thống kê mô tả, thông tin schema
- Phân tích missing data và grouping

### ETL Pipeline
- `output/etl_result/csv/`: Dữ liệu đã transform (CSV)
- `output/etl_result/parquet/`: Dữ liệu đã transform (Parquet)

### Pandas Analysis
- `output/cleaned_data.csv`: Dữ liệu đã làm sạch
- `output/correlation_heatmap.png`: Ma trận tương quan
- `output/distributions.png`: Phân phối các biến số
- `output/categorical_distribution.png`: Phân phối biến categorical

## Concepts và Patterns

### PySpark Concepts
```python
# SparkSession
spark = SparkSession.builder.appName("MyApp").master("local[*]").getOrCreate()

# DataFrame operations
df.select(), df.filter(), df.groupBy(), df.agg()

# SQL functions
from pyspark.sql.functions import col, when, avg, count, explode, split

# Data types
from pyspark.sql.types import StringType, IntegerType, DoubleType
```

### Pandas Patterns
```python
# Data exploration
df.info(), df.describe(), df.head()

# Data cleaning
df.drop_duplicates(), df.fillna(), df.dropna()

# Analysis
df.groupby().agg(), df.corr(), df.value_counts()

# Visualization
plt.figure(), sns.heatmap(), df.plot()
```

### Error Handling
```python
try:
    # Data processing
    result = process_data(df)
except Exception as e:
    print(f"Error: {e}")
finally:
    spark.stop()  # Cleanup resources
```

## Troubleshooting

### Common Issues
1. **Java not found**: Cài đặt Java 8 hoặc 11
2. **Memory issues**: Tăng Spark driver memory
3. **Permission denied**: `chmod +x run_examples.sh`
4. **Module not found**: Chạy `pip install -r requirements.txt`

### Debug Commands
```bash
# Check Java
java -version

# Check Python packages
pip list | grep -E "(pyspark|pandas)"

# Test Spark
python -c "from pyspark.sql import SparkSession; print('Spark OK')"

# Verbose output
python -v script.py
```

## Performance Tips

### PySpark Optimization
- Sử dụng `coalesce()` để giảm số partitions
- Cache DataFrame khi sử dụng nhiều lần: `df.cache()`
- Sử dụng `broadcast()` cho small tables
- Enable adaptive query execution

### Memory Management
```python
# Spark configuration
spark = SparkSession.builder \
    .config("spark.driver.memory", "4g") \
    .config("spark.executor.memory", "4g") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()
```

## Mở rộng

### Thêm ví dụ mới
1. Tạo file Python trong thư mục tương ứng
2. Thêm vào `run_examples.sh`
3. Cập nhật README.md

### Integration với các tools khác
- **Jupyter Notebook**: Chuyển đổi scripts thành notebooks
- **Apache Airflow**: Tạo DAGs cho ETL pipelines
- **Docker**: Containerize các ví dụ
- **CI/CD**: Automated testing và deployment

Bộ ví dụ này cung cấp foundation vững chắc để học và thực hành xử lý dữ liệu với Python và PySpark.