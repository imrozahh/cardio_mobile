# HeartCare Mobile

HeartCare Mobile merupakan aplikasi berbasis Flutter untuk membantu deteksi dini risiko penyakit cardiovascular menggunakan machine learning Random Forest. Sistem terintegrasi dengan backend Laravel, MongoDB, dan Flask API.

---

## Features

* Login & Register
* Dashboard Kesehatan
* Prediksi Risiko Penyakit Jantung
* Histori Prediksi
* Detail Hasil Prediksi
* Konsultasi AI
* Artikel Kesehatan

---

## Tech Stack

### Mobile

* Flutter
* Dart
* BLoC
* GoRouter
* Dio

### Backend

* Laravel
* PHP
* MongoDB

### Machine Learning

* Python
* Flask
* Scikit-learn
* Random Forest

---

## Installation

### Clone Repository

```bash id="n3g63r"
git clone https://github.com/imrozahh/cardio_mobile.git
```

Masuk ke folder project:

```bash id="kzq3k1"
cd cardio_mobile/mobile_fe
```

---

## Install Dependencies

```bash id="0fwc0s"
flutter pub get
```

---

## Run Application

### Chrome/Web

```bash id="1jy0ti"
flutter run -d chrome
```

### Android Emulator

```bash id="uqm75d"
flutter run
```

---

## Backend Setup

Jalankan Laravel:

```bash id="fd4w80"
php artisan serve
```

---

## Flask API

Masuk ke folder Flask:

```bash id="q5m6l7"
cd flask_ml
```

Install dependency:

```bash id="8s5x0o"
pip install -r requirements.txt
```

Jalankan Flask:

```bash id="6j9k5u"
python app.py
```

---

## Machine Learning Workflow

1. Collection Dataset
2. EDA
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

## Database Collections

* users
* predictions
* chats
* articles
* categories

---

