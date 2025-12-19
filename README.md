# JIST: Psychophysical Comparison of Distance Measures for Evaluating Color Constancy Algorithms

This repository contains the official MATLAB implementation for the paper **"Psychophysical Comparison of Distance Measures for Evaluating Color Constancy Algorithms"**.

The code provides a framework for:
1.  **Preprocessing** dataset images using Ground Truth (GT) or White Balance (WB) algorithms.
2.  **Calculating** various color constancy error metrics and their correlations with subjective psychophysical ratings.
3.  **Benchmarking** the computational runtime of different metrics.

## 📂 Repository Structure

* **`PreProcessing/`**: Contains scripts (`Main_Preprocessing.m`) to generate the visual datasets used in the experiment.
* **`metricsCal/`**: Includes helper functions for calculating error metrics (e.g., `calcuCCI`, `de2000`).
* **`results/`**: Stores data and intermediate calculation results.
    * `All_Illumination_RGB_Final.mat`: Ground Truth & Method Data.
    * `All_Mean_Ratings_Final.mat`: Subjective Rating Data.
    * Generated `.mat` files from metric calculations are saved here.
* **`Main.m`**: The primary script for computing objective metrics and correlating them with subjective scores.
* **`Main_Runtime.m`**: A standalone script to evaluate the time complexity of different metrics.
* **`Experiment results.xlsx`**: The final tabulated results of the study.

## 🚀 Usage

### 1. Image Preprocessing
Use `Main_Preprocessing.m` (inside the `PreProcessing` folder) to generate the image datasets required for subjective experiments. This script processes raw images by applying specific illuminant corrections and color space transformations.

**Workflow:**
* **Input:** Loads raw images (without MCC) and illuminant data (GT or Algorithm estimates).
* **Processing Steps:**
    1.  **White Balance Correction:** Normalizes R and B channels relative to G based on the illuminant vector.
    2.  **Color Space Transformation:** Converts images to target spaces (e.g., RGB, XYZ, LMS).
    3.  **Gamma Correction:** Applies $\gamma = 2.2$.
    4.  **Clipping:** Ensures pixel values remain in the $[0, 1]$ range.
* **Output:** Saves processed images to folders named `[Source]_image/`.

### 2. Metric Calculation & Correlation Analysis
Run `Main.m` to perform the core quantitative analysis. This script evaluates how well objective error metrics align with human perception.

**Key Functions:**
* **Metric Calculation:** Computes standard metrics (Recovery Error, Reproduction Error, Euclidean Distance) and Advanced metrics (CCI) across multiple color spaces (RGB, XYZ, LMS, LAB, Luv, JAB).
* **Correlation Analysis:** Loads subjective data from `results/All_Mean_Ratings_Final.mat` and calculates **Pearson** and **Spearman** correlation coefficients between the objective metrics and human ratings.
* **Output:**
    * Saves `Correlation_Results.mat` (Correlation coefficients) into the `results/` directory (or root, depending on configuration).
    * Saves `metrics_results.mat` (Comprehensive error data).

### 3. Runtime Analysis
Run `Main_Runtime.m` to examine the computational efficiency of the metrics.

**Features:**
* Simulates random illuminant data and test images ($512 \times 512$).
* Measures execution time for:
    * **Standard Metrics:** PED, DE2000, SSIM, PSNR.
    * **Color Space Conversions:** Time taken to convert RGB to XYZ, LMS, LAB, Luv, and CAM16.
* **Output:** Generates `CCI_timing_results.xlsx` summarizing the time costs.

## 📊 Results
The final calculated results, including statistical comparisons and performance rankings, can be found in **`Experiment results.xlsx`**.

## 📝 Citation
If you use this code or dataset in your research, please cite our paper (This will be updated after acceptance):

```bibtex
@article{LQCV2025JIST,
  title={Psychophysical Comparison of Distance Measures for Evaluating Color Constancy Algorithms},
  author={Zhiyu Chen†, Zheng Huang†, Chenyu Wang, Xiaoyun Liu, Hang Luo, and Qiang Liu},
  journal={Journal of Imaging Science and Technology},
  year={2025}
}