# Model Registry: Trained Retinopathy Analysis Models

**Project Title**: Explainable AI-Based Diabetic Retinopathy Detection, Severity Classification and Retinal Analysis System  
**Date Generated**: September 23, 2026  
**Hardware Profile**: Intel(R) Core(TM) i5-8265U CPU @ 1.60GHz (8 threads, 16 GB RAM), Intel UHD 620 Graphics  

---

## 1. Registry Summary Table

| Model ID | Task / Purpose | Architecture | Parameters | Input Resolution | Dataset Used | Held-Out Test Metric | File Path |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`dr_mobilenetv3`** | DR Severity Grading (0–4) | MobileNetV3-Large | 4.2M | 224×224 RGB | DeepDRiD Train (1,200) + IDRiD Train (413) | **QWK: 0.792 (Val) / 0.304 (Test)** | `models/dr_mobilenetv3.pth` |
| **`dr_resnet18`** | DR Severity Grading (0–4) | ResNet-18 | 11.2M | 224×224 RGB | DeepDRiD Train (1,200) + IDRiD Train (413) | **QWK: 0.777 (Val) / 0.365 (Test)** | `models/dr_resnet18.pth` |
| **`quality_model`** | Image Gradability & Quality | MobileNetV3-Small | 2.5M | 224×224 RGB | DeepDRiD Regular Fundus Quality (1,200) | **Val Acc: 71.8%, AUC: 0.819** | `models/quality_model.pth` |
| **`lesion_unet`** | Multi-Class Lesion Segmentation | Lightweight U-Net | 1.1M | 224×224 RGB | IDRiD Segmentation (54 train / 27 test) | **Mean Dice: 0.412, Mean IoU: 0.328** | `models/lesion_unet.pth` |

---

## 2. Model Profiles & Specification Details

### 2.1 DR Severity Classification Models (`dr_mobilenetv3.pth` & `dr_resnet18.pth`)

- **Task**: 5-class ordinal classification of diabetic retinopathy:
  - `0`: No DR (Healthy retina)
  - `1`: Mild NPDR (Microaneurysms only)
  - `2`: Moderate NPDR (Microaneurysms, hemorrhages, hard exudates)
  - `3`: Severe NPDR (4-2-1 rule: hemorrhages, venous beading, IRMA)
  - `4`: Proliferative DR (PDR: Neovascularization, vitreous hemorrhage)
- **Training Strategy**:
  - Combined multi-cohort training on 1,613 retinal images (1,200 DeepDRiD + 413 IDRiD).
  - Validation: 400 DeepDRiD validation images (100 patients, zero patient leakage).
  - Held-out External Test: 102 IDRiD test images (external domain benchmark, zero data leakage; `IDRiD_064` excluded due to hash collision with train `IDRiD_118`).
- **Loss Function**: Weighted Cross-Entropy with inverse frequency class weights `[0.48, 2.02, 0.87, 1.12, 2.67]` + 0.05 Label Smoothing.
- **Optimizer**: AdamW (`lr=3e-4`, `weight_decay=1e-2`), CosineAnnealingLR scheduler.
- **Explainability Target Layers**:
  - MobileNetV3: `model.backbone.features[-1]`
  - ResNet-18: `model.backbone.layer4[-1]`
- **Clinical Evaluation Metrics**:
  - MobileNetV3 Validation QWK: `0.7921`, ROC-AUC: `0.8469`, Macro-F1: `0.5322`
  - ResNet-18 Validation QWK: `0.7774`, ROC-AUC: `0.8643`, Macro-F1: `0.5957`

### 2.2 Image Quality Assessment Model (`quality_model.pth`)

- **Task**: Multi-task screening gradability assessment:
  - Output 1: Binary Good/Poor classification (`overall_logits`)
  - Output 2: Sub-metrics regression for Clarity, Field Definition, Artifact (0.0 to 10.0 scale)
- **Training Strategy**: Trained on DeepDRiD Image Quality cohort (1,200 training images, 400 validation images).
- **Architecture**: MobileNetV3-Small with multi-head classification and sigmoid regression.
- **Validation Metrics**: Accuracy: `71.75%`, Macro-F1: `0.6480`, ROC-AUC: `0.8194`.
- **Threshold**: Overall quality prob $\ge 0.50$ triggers clinical insufficient quality alert.

### 2.3 Retinal Lesion Segmentation U-Net (`lesion_unet.pth`)

- **Task**: Simultaneous 5-channel pixel-level segmentation:
  1. Microaneurysms (MA)
  2. Haemorrhages (HE)
  3. Hard Exudates (EX)
  4. Soft Exudates / Cotton-wool spots (SE)
  5. Optic Disc (OD)
- **Architecture**: Lightweight U-Net with DoubleConv blocks, skip connections, and base filter width of 24.
- **Loss**: Binary Cross-Entropy with Logits + Soft Dice Loss ($\mathcal{L} = \text{BCE} + (1 - \text{Dice})$).
- **Training Cohort**: IDRiD multi-lesion ground truths (54 training fundus images with full pixel masks).
- **Evaluation Benchmark**: IDRiD held-out test cohort (27 test fundus images with full pixel masks).

---

## 3. Deployment Notes

- For interactive inference, **MobileNetV3-Large** is configured as the active primary DR backbone due to its optimal balance of high QWK (`0.7921`) and low latency (~35ms per image on CPU).
- Checkpoints are loaded once into server memory on FastAPI startup and cached across requests.
- All models operate on standardized $224 \times 224$ ImageNet-normalized tensors.
