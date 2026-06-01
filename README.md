# HeartCare Mobile

HeartCare Mobile merupakan aplikasi berbasis Flutter yang digunakan untuk membantu deteksi dini risiko penyakit cardiovascular menggunakan metode Random Forest. Sistem terintegrasi dengan backend Laravel, database MongoDB, dan Flask API sebagai layanan machine learning.

---

# Features

* Login & Register
* Dashboard Monitoring Kesehatan
* Prediksi Risiko Penyakit Jantung
* Histori Prediksi
* Detail Hasil Prediksi
* Konsultasi AI
* Role Authentication User

---

# Tech Stack

## Mobile

* Flutter
* Dart
* BLoC
* GoRouter
* Dio

## Backend

* Laravel
* PHP
* MongoDB

## Machine Learning

* Python
* Flask
* Scikit-learn
* Random Forest

---

# Related Repository

Backend Laravel dan Frontend Web berada pada repository terpisah:

* Mobile Flutter
  https://github.com/imrozahh/cardio_mobile

* Backend Laravel & Web
  https://github.com/2ndliandra/HeartCare

---

# Installation

## Clone Repository

```bash
git clone https://github.com/imrozahh/cardio_mobile.git
```

Masuk ke folder project:

```bash
cd cardio_mobile/mobile_fe
```

---

# Install Dependencies

```bash
flutter pub get
```

---

# Run Application

## Chrome/Web

```bash
flutter run -d chrome
```

## Android Emulator

```bash
flutter run
```

---

# Backend Setup

Pastikan backend Laravel sudah dijalankan dari repository backend:

```bash
php artisan serve
```

---

# MongoDB Setup

Pastikan MongoDB berjalan pada:

```bash
mongodb://127.0.0.1:27017
```

Database yang digunakan:

```bash
belajar_mongo
```

Collection utama yang digunakan:

* users
* predictions
* chats
* articles
* categories
* roles
* permissions

---

# Flask API Setup

Masuk ke folder Flask:

```bash
cd flask_ml
```

Install dependency:

```bash
pip install -r requirements.txt
```

Jalankan Flask API:

```bash
python app.py
```

---

# Machine Learning Workflow

1. Collection Dataset
2. Exploratory Data Analysis (EDA)
3. Data Cleaning
4. Feature Engineering
5. Data Split
6. Feature Scaling
7. Hyperparameter Tuning
8. Random Forest Training
9. Model Evaluation
10. Save Model
11. Deploy Model

---

# Model Evaluation

Evaluasi model dilakukan menggunakan:

* Accuracy Score
* ROC-AUC Score
* Classification Report
* Confusion Matrix

Metode Random Forest dipilih karena mampu menghasilkan performa klasifikasi yang baik, mengurangi overfitting, serta dapat menangani banyak parameter kesehatan secara bersamaan.

---

# License

This project uses the MIT License.
