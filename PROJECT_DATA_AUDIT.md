# Project Data Audit: IDRiD and DeepDRiD

**Project Title**: Explainable AI-Based Diabetic Retinopathy Detection, Severity Classification and Retinal Analysis System  
**Date of Audit**: September 23, 2026  
**Auditor**: ML Engineering & AI Assistant  

---

## 1. Executive Summary

This audit rigorously inspects the existing retinal datasets inside `D:\Retinopathy detection\`:
1. **IDRiD (Indian Diabetic Retinopathy Image Dataset)**: Disease grading, multi-class lesion segmentation, and optic disc/fovea landmark localization.
2. **DeepDRiD (Deep Diabetic Retinopathy Image Dataset)**: Dual-view regular fundus images with 5-level DR severity grading, patient-level grading, and 4-aspect image quality assessments.

Both datasets have been verified on disk, with file hashes computed, cross-dataset leakage analyzed, image dimensions verified, and label schemas mapped.

---

## 2. Dataset Overview & Folder Locations

| Dataset | Subset / Task | Folder Location | Format | Count (Disk) | Annotations Available |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **IDRiD** | Disease Grading (Train) | `datasets/IDRiD/disease_grading/B. Disease Grading/1. Original Images/a. Training Set` | JPG (4288×2848) | 413 | 5-level DR Grade (0-4), DME Risk (0-2) |
| **IDRiD** | Disease Grading (Test) | `datasets/IDRiD/disease_grading/B. Disease Grading/1. Original Images/b. Testing Set` | JPG (4288×2848) | 103 | 5-level DR Grade (0-4), DME Risk (0-2) |
| **IDRiD** | Lesion Segmentation (Train) | `datasets/IDRiD/segmentation/A. Segmentation/1. Original Images/a. Training Set` | JPG (4288×2848) | 54 | Pixel masks (.tif) for MA, HE, EX, SE, OD |
| **IDRiD** | Lesion Segmentation (Test) | `datasets/IDRiD/segmentation/A. Segmentation/1. Original Images/b. Testing Set` | JPG (4288×2848) | 27 | Pixel masks (.tif) for MA, HE, EX, SE, OD |
| **IDRiD** | Landmark Localization (Train) | `datasets/IDRiD/localization/C. Localization/1. Original Images/a. Training Set` | JPG (4288×2848) | 413 | OD center (X, Y) & Fovea center (X, Y) |
| **IDRiD** | Landmark Localization (Test) | `datasets/IDRiD/localization/C. Localization/1. Original Images/b. Testing Set` | JPG (4288×2848) | 103 | OD center (X, Y) & Fovea center (X, Y) |
| **DeepDRiD** | Regular Fundus (Train) | `DeepDRiD/regular_fundus_images/regular-fundus-training/Images` | JPG (1736×1824) | 1,200 | DR Level (0-4), Overall Quality (0/1), Clarity, Field Def, Artifact |
| **DeepDRiD** | Regular Fundus (Val) | `DeepDRiD/regular_fundus_images/regular-fundus-validation/Images` | JPG (1736×1824) | 400 | DR Level (0-4), Overall Quality (0/1), Clarity, Field Def, Artifact |
| **DeepDRiD** | Regular Fundus (Eval) | `DeepDRiD/regular_fundus_images/Online-Challenge1&2-Evaluation/Images` | JPG (1736×1824) | 400 | Challenge 1 & 2 doctor ground truth (.xlsx) |

> **Note**: DeepDRiD's `ultra-widefield_images/` directory exists as an auxiliary challenge folder but, per project specification, is strictly excluded from our main pipeline.

---

## 3. Class Distributions & Label Counts

### 3.1 IDRiD Disease Grading

- **Training Set (N = 413)**:
  - Grade 0 (No DR): 134 images (32.4%)
  - Grade 1 (Mild DR): 20 images (4.8%)
  - Grade 2 (Moderate DR): 136 images (32.9%)
  - Grade 3 (Severe DR): 74 images (17.9%)
  - Grade 4 (Proliferative DR): 49 images (11.9%)
  - *DME Risk*: 0: 177, 1: 41, 2: 195

- **Testing Set (N = 103)**:
  - Grade 0 (No DR): 34 images (33.0%)
  - Grade 1 (Mild DR): 5 images (4.9%)
  - Grade 2 (Moderate DR): 32 images (31.1%)
  - Grade 3 (Severe DR): 19 images (18.4%)
  - Grade 4 (Proliferative DR): 13 images (12.6%)
  - *DME Risk*: 0: 45, 1: 10, 2: 48

### 3.2 DeepDRiD Disease Grading (Image-Level)

Each patient has 4 views: left eye center/superior (`_l1`, `_l2`) and right eye center/superior (`_r1`, `_r2`).
Labels are extracted using the non-null eye grade (`left_eye_DR_Level` for left views, `right_eye_DR_Level` for right views).

- **Training Set (N = 1,200 images, 300 patients)**:
  - Grade 0 (No DR): 540 images (45.0%)
  - Grade 1 (Mild DR): 140 images (11.7%)
  - Grade 2 (Moderate DR): 234 images (19.5%)
  - Grade 3 (Severe DR): 214 images (17.8%)
  - Grade 4 (Proliferative DR): 72 images (6.0%)

- **Validation Set (N = 400 images, 100 patients)**:
  - Grade 0 (No DR): 174 images (43.5%)
  - Grade 1 (Mild DR): 46 images (11.5%)
  - Grade 2 (Moderate DR): 92 images (23.0%)
  - Grade 3 (Severe DR): 68 images (17.0%)
  - Grade 4 (Proliferative DR): 20 images (5.0%)

### 3.3 DeepDRiD Image Quality Distributions

- **Training Set (N = 1,200)**:
  - Overall Quality = 0 (Good): 624 images (52.0%)
  - Overall Quality = 1 (Poor): 576 images (48.0%)
  - Sub-scores available:
    - *Clarity*: discrete scale [0 to 10]
    - *Field Definition*: discrete scale [0 to 10]
    - *Artifact*: discrete scale [0 to 10]

- **Validation Set (N = 400)**:
  - Overall Quality = 0 (Good): 218 images (54.5%)
  - Overall Quality = 1 (Poor): 182 images (45.5%)

### 3.4 IDRiD Segmentation Masks (Pixel-Level)

Total annotated images = 81 (54 train, 27 test).
- **Microaneurysms (MA)**: 54 train masks, 27 test masks
- **Haemorrhages (HE)**: 53 train masks, 27 test masks (1 train image had no hemorrhages)
- **Hard Exudates (EX)**: 54 train masks, 27 test masks
- **Soft Exudates (SE)**: 26 train masks, 14 test masks (only present in severe stages)
- **Optic Disc (OD)**: 54 train masks, 27 test masks

---

## 4. Duplicate Image & Leakage Analysis

1. **Cross-Dataset Duplication (IDRiD vs DeepDRiD)**:
   - MD5 hash cross-check performed across all 516 IDRiD images and 2,000 DeepDRiD images.
   - Result: **0 identical images**. IDRiD (Kowa camera, India) and DeepDRiD (China screening) are completely disjoint.

2. **Within-Dataset Split Duplication**:
   - **DeepDRiD**: 0 duplicate hashes between training (1,200) and validation (400).
   - **IDRiD**: Exactly 1 image pair was identified with identical hash between training and testing:
     - `IDRiD_118.jpg` (Training set) == `IDRiD_064.jpg` (Testing set).
     - **Resolution for model evaluation**: `IDRiD_064.jpg` will be flagged during test evaluation to prevent test contamination.

3. **Patient-Level Leakage Check**:
   - **DeepDRiD**: Patient IDs 1–300 are in training. Patient IDs 301–400 are in validation.
   - Result: **0 patient overlap** between training and validation. Patient-level split is perfectly preserved.

---

## 5. Train / Validation / Test Strategy

| Split Role | Source Dataset | Image Count | Purpose |
| :--- | :--- | :--- | :--- |
| **Training** | DeepDRiD Train (1,200) + IDRiD Train (413) | 1,613 images | DR Severity and Image Quality model training/fine-tuning |
| **Validation** | DeepDRiD Val | 400 images | Hyperparameter tuning, checkpoint selection, early stopping |
| **Independent Test** | IDRiD Test (held-out) | 103 images | Cross-domain generalization test (held-out external benchmark) |
| **Challenge Eval** | DeepDRiD Online-Eval | 400 images | Benchmark evaluation with doctor ground truth |
| **Segmentation Train** | IDRiD Seg Train | 54 images | Multi-channel lesion & optic disc segmentation model training |
| **Segmentation Test** | IDRiD Seg Test | 27 images | Lesion segmentation Dice / IoU evaluation |

---

## 6. Preprocessing Strategy

1. **Circular Mask / Black Border Cropping**: Retinal images have circular apertures surrounded by variable black borders; an automated threshold crop removes uninformative margins.
2. **Standardized Resolution**:
   - Training & Inference: Resized to 224×224 or 256×256 with aspect-ratio preservation.
3. **Normalization**: Standard ImageNet mean `[0.485, 0.456, 0.406]` and std `[0.229, 0.224, 0.225]`.
4. **Clinical Data Augmentations** (Train only): Random horizontal flip (retinal orientation valid), mild rotation (±15°), subtle brightness/contrast adjustment (±10%). No vertical flips or distortion that destroys retinal morphology.
5. **Class Imbalance Handling**: Weighted Cross-Entropy Loss / Balanced Sampler based on class frequencies.

---

## 7. Audit Conclusion

All files, labels, and ground truths are present, verified, and ready for model development. No further dataset downloading or unzipping is required.
