# Explainable AI-Based Diabetic Retinopathy Detection, Severity Classification and Retinal Analysis System

An end-to-end, multi-modal deep learning and computer vision system for automated Diabetic Retinopathy (DR) grading, image quality estimation, Explainable AI (Grad-CAM), 5-class lesion segmentation, anatomical landmark localization, and clinical PDF report generation.

Built and evaluated on real clinical cohorts from **DeepDRiD** (1,200 training / 400 validation / 400 evaluation images) and **IDRiD** (413 disease grading / 102 held-out test / 81 lesion segmentation / 516 localization images).

---

## 🌟 Key System Features

1. **Retinal Image Ingestion & Preprocessing**:
   - Automated circular fundus aperture boundary detection and black-border cropping.
   - Standardized aspect-ratio resizing to $224 \times 224$ pixels and ImageNet normalization.
   - Contrast Limited Adaptive Histogram Equalization (CLAHE) for fine vascular and lesion contrast.
   - Multithreaded image caching layer enabling $>30\times$ acceleration on CPU.

2. **Image Gradability & Quality Assessment**:
   - Evaluates fundus readability before disease prediction using DeepDRiD multi-task annotations.
   - Reports overall quality (Good / Poor) along with continuous scores ($0–10$) for **Clarity**, **Field Definition**, and **Artifact Interference**.
   - Explicit clinical warning banner prevents automated diagnostic conclusions on ungradable scans.

3. **Diabetic Retinopathy Severity Grading (Main ML Task)**:
   - Evaluates the 5 International Clinical Diabetic Retinopathy severity stages:
     - **Grade 0**: No DR (Healthy retina)
     - **Grade 1**: Mild NPDR (Microaneurysms only)
     - **Grade 2**: Moderate NPDR (Microaneurysms, hemorrhages, hard exudates)
     - **Grade 3**: Severe NPDR (4-2-1 rule: hemorrhages, venous beading, IRMA)
     - **Grade 4**: Proliferative DR (Neovascularization, vitreous/preretinal hemorrhage)
   - Evaluated using **Quadratic Weighted Kappa (QWK)**, Macro-F1, Precision, Recall, and Multi-Class ROC-AUC.
   - Trained using inverse frequency class weighting to handle minority classes (Grade 1 and Grade 4).

4. **Multi-Model Comparison**:
   - Comparative benchmark between **MobileNetV3-Large** and **ResNet-18** saved in `MODEL_COMPARISON.md`.
   - **MobileNetV3-Large**: Validation QWK `0.7921`, ROC-AUC `0.8469`, CPU latency ~35ms.
   - **ResNet-18**: Validation QWK `0.7774`, ROC-AUC `0.8643`, CPU latency ~82ms.

5. **Explainable AI (Grad-CAM)**:
   - Hooks into the deepest convolutional representation layer (`features[-1]` in MobileNetV3 / `layer4` in ResNet-18).
   - Generates 2D heatmaps highlighting retinal zones driving the classification score.
   - Interactive UI slider allows smooth alpha blending between fundus photographs and Jet attention overlays.

6. **5-Class Retinal Lesion Segmentation**:
   - Lightweight U-Net trained on the IDRiD pixel-level ground truth masks.
   - Segments and quantifies area percentages for:
     - Microaneurysms (MA)
     - Haemorrhages (HE)
     - Hard Exudates (EX)
     - Soft Exudates / Cotton-wool spots (SE)
     - Optic Disc (OD)

7. **Optic Disc & Fovea Localization**:
   - Detects coordinates of the Optic Disc and Fovea Centralis.
   - Maps ground-truth annotations from IDRiD and automated computer vision heuristics for arbitrary scans.

8. **Automated Clinical PDF Report Generation**:
   - Generates printable diagnostic summary reports via ReportLab including patient metadata, DR grade, confidence, image quality, Grad-CAM attention maps, lesion quantification tables, and disclaimers.

9. **Case History Archive & Search**:
   - SQLite database storing every screening event.
   - Real-time search and filtering by patient ID, DR grade, and image quality status.

10. **Side-by-Side Scan Comparison**:
    - Compares two past screenings side by side to evaluate prediction differences, confidence variations, and visual attention changes.

11. **Interactive Analytics Dashboard**:
    - Chart.js visualizations showing overall scan volumes, severity grade distributions, and quality pass rates.

---

## 📁 Repository Structure

```
D:\Retinopathy detection\
├── datasets/
│   └── IDRiD/                       # Indian Diabetic Retinopathy Image Dataset
│       ├── disease_grading/         # 413 train, 103 test
│       ├── localization/            # OD & Fovea coordinates (516 images)
│       └── segmentation/            # 54 train, 27 test (5 lesion classes)
│
├── DeepDRiD/                        # Deep DR Dataset (ISBI 2020)
│   └── regular_fundus_images/       # 1,200 train, 400 val, 400 eval
│
├── core/
│   ├── config.py                    # Paths, class maps, device settings
│   ├── preprocessing.py             # Fundus circle crop, CLAHE, transforms, caching
│   ├── dataset.py                   # PyTorch dataset loaders & class weights
│   ├── models/
│   │   ├── dr_classifier.py         # ResNet18 & MobileNetV3 architectures
│   │   ├── quality_classifier.py    # Multi-task MobileNetV3-Small quality model
│   │   └── unet_segmenter.py        # Lightweight U-Net lesion segmenter
│   ├── explainability/
│   │   └── gradcam.py               # Grad-CAM forward/backward hooks & colormap
│   ├── localization/
│   │   └── landmark_detector.py     # Optic disc & fovea detector & overlays
│   ├── database/
│   │   └── db.py                    # SQLite database schema, CRUD, search
│   └── reports/
│       └── pdf_generator.py         # Clinical PDF report builder via ReportLab
│
├── training/
│   ├── train_severity.py            # DR severity training & comparison pipeline
│   ├── train_quality.py             # Image quality model training pipeline
│   └── train_segmentation.py        # Lesion segmentation training pipeline
│
├── backend/
│   ├── app.py                       # FastAPI REST API server
│   └── schemas.py                   # Pydantic request/response schemas
│
├── frontend/
│   ├── index.html                   # 11-page glassmorphic single-app UI
│   ├── css/style.css                # Dark-mode responsive design system
│   └── js/app.js                    # Client controller, state, Chart.js
│
├── models/
│   ├── dr_mobilenetv3.pth           # Trained MobileNetV3 checkpoint (13.1 MB)
│   ├── dr_resnet18.pth              # Trained ResNet-18 checkpoint (45.1 MB)
│   ├── quality_model.pth            # Trained Quality checkpoint (4.1 MB)
│   └── lesion_unet.pth              # Trained Lesion U-Net checkpoint (4.4 MB)
│
├── reports/                         # Confusion matrices, curves & PDF exports
├── static/                          # Cache, uploads, and processed outputs
├── tests/                           # 17 automated unit and integration tests
├── PROJECT_DATA_AUDIT.md            # Comprehensive dataset audit documentation
├── MODEL_COMPARISON.md              # Empirical model comparison & metrics
├── MODEL_REGISTRY.md                # Full model registry and specifications
├── requirements.txt                 # Pinned project dependencies
└── README.md                        # Project documentation
```

---

## 🚀 Getting Started

### 1. Prerequisites
- Python 3.10+ (Tested on Python 3.14 64-bit on Windows)
- Intel Core i5 / AMD Ryzen (or discrete GPU if available)
- Dependencies installed via pip:

```bash
pip install -r requirements.txt
```

### 2. Running Automated Tests
Run the complete automated test suite across all 17 tests:

```bash
python -m unittest discover -s tests -p "test_*.py" -v
```

### 3. Launching the Web Application

#### Option A: One-Click Windows Launch (Recommended)
Double-click `start.bat` in the project root folder.
- Automatically verifies the virtual environment (`.venv`).
- Checks network port 8000 and prevents duplicate or orphaned processes.
- Starts the FastAPI/Uvicorn server and automatically opens your web browser to **`http://127.0.0.1:8000`**.
- Displays real-time terminal prediction logs and keeps the window open if an error occurs.

To safely stop the server at any time, close the terminal window, press `Ctrl+C`, or run `stop.bat`.

#### Option B: PowerShell
```powershell
.\run.ps1
```

#### Option C: Manual Command Line
```bash
.\.venv\Scripts\activate
uvicorn backend.app:app --host 127.0.0.1 --port 8000
```

### 4. Running Model Training Scripts
To retrain any model from scratch on the existing datasets:

- **DR Severity Models (MobileNetV3 & ResNet-18)**:
  ```bash
  python training/train_severity.py --epochs 3 --batch_size 32 --models mobilenetv3 resnet18
  ```
- **Image Quality Model**:
  ```bash
  python training/train_quality.py --epochs 3 --batch_size 32
  ```
- **Lesion Segmentation U-Net**:
  ```bash
  python training/train_segmentation.py --epochs 5 --batch_size 8
  ```

---

## 📊 Evaluation & Comparative Performance

| Architecture | Cohort / Split | Accuracy | QWK Kappa | Macro-F1 | ROC-AUC | Inference Time (CPU) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **MobileNetV3-Large** | DeepDRiD Val (400) | 60.0% | **0.7921** | 0.5322 | 0.8469 | **~35 ms** |
| **MobileNetV3-Large** | IDRiD Held-Out Test (102) | 37.3% | 0.3035 | 0.2955 | 0.6592 | **~35 ms** |
| **ResNet-18** | DeepDRiD Val (400) | **65.3%** | 0.7774 | **0.5957** | **0.8643** | ~82 ms |
| **ResNet-18** | IDRiD Held-Out Test (102) | 32.4% | **0.3645** | 0.2524 | 0.6767 | ~82 ms |

---

## ⚕️ Academic & Medical Disclaimer

> **IMPORTANT CLINICAL NOTICE**:  
> This application is an **academic research and screening decision-support prototype**. It is **not** an autonomous medical device, has not been cleared for clinical diagnosis, and cannot replace a comprehensive dilated eye examination by a certified ophthalmologist or optometrist. Predictions, Grad-CAM heatmaps, and lesion segmentations are probabilistic AI outputs intended to assist in triage and research. Do not use this system for autonomous self-medication, prescription, or clinical treatment.
