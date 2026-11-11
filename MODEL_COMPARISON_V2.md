# Model Comparison (V2 Improved): Diabetic Retinopathy Severity Grading

**Date of Evaluation**: September 24, 2026  
**Evaluation Cohorts**:
- **Validation Cohort**: DeepDRiD Validation Set ($N = 400$ images, 100 patients, patient-level split)
- **Independent Held-Out Test Cohort**: Full IDRiD Testing Set ($N = 103$ images, external eye clinic, India)

---

## 1. Comparative Performance Summary (V2 Improved)

| Architecture | Validation Acc | Validation QWK | Validation Macro-F1 | Test Acc (N=103) | Test QWK | Test Macro-F1 | Test ROC-AUC |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **MOBILENETV3 (V2)** | 0.6225 | 0.8076 | 0.5452 | **0.5534** | **0.6480** | **0.4864** | **0.7931** |
| **RESNET18 (V2)** | 0.6300 | 0.7851 | 0.5740 | **0.4175** | **0.6207** | **0.3284** | **0.7878** |

---

## 2. Detailed Per-Model Metrics & Confusion Matrices

### MOBILENETV3 (V2)
- **Checkpoint Path**: `D:\Retinopathy detection\models\dr_mobilenetv3_v2.pth`
- **Test Accuracy (N=103)**: **55.34%**
- **Test Quadratic Weighted Kappa (QWK)**: **0.6480**
- **Test Macro Precision**: 0.5257
- **Test Macro Recall**: 0.4700
- **Test Macro F1-Score**: **0.4864**
- **Test Multi-Class ROC-AUC**: **0.7931**

#### Per-Class Breakdown (IDRiD Held-Out Test Set):

| Class | Severity Stage | Precision | Recall | F1-Score | Support |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Grade 0** | No DR | 0.6765 | 0.6765 | 0.6765 | 34 |
| **Grade 1** | Mild DR | 0.2500 | 0.2000 | 0.2222 | 5 |
| **Grade 2** | Moderate DR | 0.4615 | 0.5625 | 0.5070 | 32 |
| **Grade 3** | Severe DR | 0.5263 | 0.5263 | 0.5263 | 19 |
| **Grade 4** | Proliferative DR | 0.7143 | 0.3846 | 0.5000 | 13 |

#### Confusion Matrix (Rows = Ground Truth, Columns = Predicted):

| True \ Pred | Grade 0 | Grade 1 | Grade 2 | Grade 3 | Grade 4 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Grade 0** | 23 | 3 | 6 | 2 | 0 |
| **Grade 1** | 3 | 1 | 1 | 0 | 0 |
| **Grade 2** | 7 | 0 | 18 | 5 | 2 |
| **Grade 3** | 1 | 0 | 8 | 10 | 0 |
| **Grade 4** | 0 | 0 | 6 | 2 | 5 |

### RESNET18 (V2)
- **Checkpoint Path**: `D:\Retinopathy detection\models\dr_resnet18_v2.pth`
- **Test Accuracy (N=103)**: **41.75%**
- **Test Quadratic Weighted Kappa (QWK)**: **0.6207**
- **Test Macro Precision**: 0.3875
- **Test Macro Recall**: 0.3176
- **Test Macro F1-Score**: **0.3284**
- **Test Multi-Class ROC-AUC**: **0.7878**

#### Per-Class Breakdown (IDRiD Held-Out Test Set):

| Class | Severity Stage | Precision | Recall | F1-Score | Support |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Grade 0** | No DR | 0.7222 | 0.3824 | 0.5000 | 34 |
| **Grade 1** | Mild DR | 0.0000 | 0.0000 | 0.0000 | 5 |
| **Grade 2** | Moderate DR | 0.4074 | 0.6875 | 0.5116 | 32 |
| **Grade 3** | Severe DR | 0.3636 | 0.2105 | 0.2667 | 19 |
| **Grade 4** | Proliferative DR | 0.4444 | 0.3077 | 0.3636 | 13 |

#### Confusion Matrix (Rows = Ground Truth, Columns = Predicted):

| True \ Pred | Grade 0 | Grade 1 | Grade 2 | Grade 3 | Grade 4 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Grade 0** | 13 | 9 | 12 | 0 | 0 |
| **Grade 1** | 2 | 0 | 3 | 0 | 0 |
| **Grade 2** | 3 | 2 | 22 | 3 | 2 |
| **Grade 3** | 0 | 0 | 12 | 4 | 3 |
| **Grade 4** | 0 | 0 | 5 | 4 | 4 |
