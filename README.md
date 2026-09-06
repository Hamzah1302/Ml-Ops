
# MLOps - Customer Churn Prediction

Project ini merupakan implementasi **MLOps Pipeline** untuk melakukan training, serving, deployment, dan monitoring model **Customer Churn Prediction**.

Model machine learning yang telah dilatih dikemas menggunakan **TensorFlow Serving**, kemudian di-deploy ke **Railway** dan dimonitor menggunakan **Prometheus**.

---

##  Project Overview

Project ini mencakup beberapa tahapan utama:

1. Data preprocessing menggunakan TensorFlow Transform
2. Training model menggunakan TensorFlow/Keras
3. Penyimpanan model dalam format SavedModel
4. Model serving menggunakan TensorFlow Serving
5. Containerization menggunakan Docker
6. Deployment ke Railway
7. Monitoring menggunakan Prometheus
8. Pengujian REST API untuk melakukan prediksi

Arsitektur sederhana project:

```text
Dataset
   │
   ▼
Data Preprocessing
   │
   ▼
TensorFlow Transform
   │
   ▼
Model Training
   │
   ▼
SavedModel
   │
   ▼
Docker + TensorFlow Serving
   │
   ▼
Railway
   │
   ├── REST API
   │
   └── Prometheus Metrics
           │
           ▼
       Prometheus
```

---

##  Model

Model menggunakan neural network dengan arsitektur:

```text
Input Features
      │
      ▼
Concatenate
      │
      ▼
Dense 256 (ReLU)
      │
      ▼
Dense 64 (ReLU)
      │
      ▼
Dense 16 (ReLU)
      │
      ▼
Dense 1 (Sigmoid)
      │
      ▼
Churn Prediction
```

Model digunakan untuk melakukan klasifikasi apakah seorang pelanggan berpotensi mengalami **churn** atau tidak.

### Fitur yang digunakan

#### Categorical Features

* `InternetService`
* `SeniorCitizen`
* `PaperlessBilling`
* `Partner`
* `PhoneService`
* `StreamingTV`
* `gender`

#### Numerical Features

* `MonthlyCharges`
* `TotalCharges`
* `tenure`

Target:

```text
Churn
```

---

##  Tech Stack

| Teknologi                 | Penggunaan               |
| ------------------------- | ------------------------ |
| Python                    | Bahasa pemrograman       |
| TensorFlow                | Machine Learning         |
| Keras                     | Pembuatan neural network |
| TensorFlow Transform      | Data preprocessing       |
| TensorFlow Extended (TFX) | MLOps pipeline           |
| TensorFlow Serving        | Model serving            |
| Docker                    | Containerization         |
| Railway                   | Deployment               |
| Prometheus                | Monitoring               |
| Git & GitHub              | Version control          |

---

## 📁 Project Structure

```text
a443-cc-pipeline/
│
├── modules/
│   ├── components.py
│   ├── customer_churn_trainer.py
│   └── customer_churn_transform.py
│
├── output/
│   └── serving_model/
│       └── 1788628710/
│           └── saved_model.pb
│
├── config/
│   └── prometheus.config
│
├── monitoring/
│   ├── Dockerfile
│   └── prometheus.yml
│
├── Dockerfile
├── requirements.txt
├── .gitignore
└── README.md
```

> Folder `output/serving_model` berisi model SavedModel yang digunakan oleh TensorFlow Serving.

---

#  Model Training

Model dibuat menggunakan TensorFlow/Keras.

Contoh arsitektur model:

```python
deep = tf.keras.layers.Dense(256, activation="relu")(concatenate)
deep = tf.keras.layers.Dense(64, activation="relu")(deep)
deep = tf.keras.layers.Dense(16, activation="relu")(deep)

outputs = tf.keras.layers.Dense(
    1,
    activation="sigmoid"
)(deep)
```

Model menggunakan:

```text
Optimizer : Adam
Learning Rate : 0.001
Loss : Binary Crossentropy
Metric : Binary Accuracy
Epochs : 10
```

---

#  Docker

Model dikemas menggunakan Docker dengan base image TensorFlow Serving.

Dockerfile menggunakan:

```dockerfile
FROM tensorflow/serving:latest
```

Model kemudian ditempatkan pada:

```text
/models/cc-model
```

Nama model:

```text
cc-model
```

TensorFlow Serving menjalankan:

```text
gRPC : 8500
REST : Railway PORT
```

---

#  Deployment

Model di-deploy menggunakan **Railway**.

Public endpoint:

```text
https://ml-ops-production-7a49.up.railway.app/
```

Model name:

```text
cc-model
```

Model version:

```text
1788628710
```

### Prediction Endpoint

```text
POST /v1/models/cc-model:predict
```

Contoh:

```text
https://ml-ops-production-7a49.up.railway.app/v1/models/cc-model:predict
```

---

#  Model Metadata

Metadata model dapat diperiksa menggunakan:

```powershell
curl.exe https://ml-ops-production-7a49.up.railway.app/v1/models/cc-model/metadata
```

Model menggunakan signature:

```text
serving_default
```

Input:

```text
examples
```

dengan tipe:

```text
DT_STRING
```

Output:

```text
outputs
```

dengan tipe:

```text
DT_FLOAT
```

---

#  Testing Prediction

Prediction dilakukan menggunakan TensorFlow `tf.train.Example`.

Contoh proses serialisasi:

```python
example = tf.train.Example(
    features=tf.train.Features(
        feature=features
    )
)

serialized_example = example.SerializeToString()
```

Kemudian data dikonversi menjadi Base64:

```python
encoded_example = base64.b64encode(
    serialized_example
).decode("utf-8")
```

Request dikirim ke TensorFlow Serving:

```python
data = {
    "signature_name": "serving_default",
    "instances": [
        {
            "b64": encoded_example
        }
    ]
}
```

Request kemudian dikirim menggunakan:

```python
requests.post(
    URL,
    json=data
)
```

---

#  Monitoring

Monitoring menggunakan **Prometheus**.

TensorFlow Serving menyediakan metrics endpoint:

```text
/monitoring/prometheus/metrics
```

Public metrics endpoint:

```text
https://ml-ops-production-7a49.up.railway.app/monitoring/prometheus/metrics
```

Prometheus dijalankan menggunakan Docker.

### Prometheus Configuration

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: "tf-serving-monitor"

scrape_configs:
  - job_name: "prometheus"
    scrape_interval: 5s
    metrics_path: /monitoring/prometheus/metrics
    scheme: https
    static_configs:
      - targets: ["ml-ops-production-7a49.up.railway.app"]
```

---

#  Monitoring Request

Salah satu metric yang digunakan untuk mengetahui jumlah request adalah:

```text
:tensorflow:serving:request_count
```

Query Prometheus:

```promql
{__name__=~".*request_count.*"}
```

Contoh hasil:

```text
:tensorflow:serving:request_count{
    model_name="cc-model",
    status="OK"
} 2
```

Nilai tersebut menunjukkan jumlah request yang berhasil diproses oleh TensorFlow Serving.

---

#  Menjalankan Prometheus secara Local

Build image:

```powershell
docker build -t cc-monitoring .\monitoring\
```

Jalankan container:

```powershell
docker run -p 9090:9090 cc-monitoring
```

Prometheus dapat diakses melalui:

```text
http://localhost:9090
```

Target monitoring dapat diperiksa melalui:

```text
http://localhost:9090/targets
```

Target yang berhasil akan memiliki status:

```text
UP
```

---

#  Git Workflow

Project menggunakan Git untuk version control.

Contoh workflow:

```powershell
git status

git add .

git commit -m "Update deployment"

git push origin main
```

Repository:

```text
https://github.com/Hamzah1302/Ml-Ops
```

---

#  Deployment Flow

Secara keseluruhan proses deployment:

```text
1. Prepare Dataset
       ↓
2. Data Preprocessing
       ↓
3. Train Model
       ↓
4. Export SavedModel
       ↓
5. Build Docker Image
       ↓
6. Push Source Code to GitHub
       ↓
7. Deploy to Railway
       ↓
8. TensorFlow Serving Loads Model
       ↓
9. Test Prediction API
       ↓
10. Expose Prometheus Metrics
       ↓
11. Prometheus Scrapes Metrics
       ↓
12. Monitor Model Requests
```

---

#  Deployment Verification

Beberapa komponen yang telah berhasil diverifikasi:

* [x] Model berhasil di-export sebagai SavedModel
* [x] TensorFlow Serving berhasil menjalankan model
* [x] Model `cc-model` berhasil di-load
* [x] REST API TensorFlow Serving aktif
* [x] Railway deployment berhasil
* [x] Public endpoint dapat diakses
* [x] Metadata endpoint dapat diakses
* [x] Prometheus metrics aktif
* [x] Prometheus berhasil melakukan scraping
* [x] Target Prometheus berstatus `UP`
* [x] Request metrics dapat dibaca
* [x] Model dapat menerima request prediction

---

# Tujuan Project

Project ini dibuat sebagai implementasi konsep **Machine Learning Operations (MLOps)**, khususnya dalam proses:

**Training → Serving → Deployment → Monitoring**

Dengan pendekatan ini, model machine learning tidak hanya berhenti pada tahap training, tetapi dapat digunakan melalui API dan dipantau setelah di-deploy ke environment production.

---

## 👨‍💻 Author

**Muhamad Hamzah**

AI Engineer | Machine Learning | NLP | Generative AI

Project untuk pembelajaran **MLOps - Dicoding Academy**.
