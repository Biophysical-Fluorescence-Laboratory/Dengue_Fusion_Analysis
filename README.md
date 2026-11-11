# Dengue_Fusion_Analysis
Python and MATLAB codes for dengue fusion analysis.
## ------------------Dengue Fusion Analysis--------------------- #

This repository contains custom Python and MATLAB scripts developed for fluorescence-based dengue fusion studies. The scripts are used for fluorescence intensity analysis, fusion event detection, and particle quantification from microscopy images.

## --------- 1. Fusion Event Analysis (Python)

**File:** `fluorescence_fusion_event_analysis.ipynb`

A Jupyter Notebook for automated detection and analysis of fluorescence intensity transitions associated with membrane fusion.

**Main features:**
- Fluorescent spot identification and intensity trace extraction.
- Fusion event detection using derivative-based and intensity level-shift methods.
- Single-channel analysis for hemifusion event detection.
- Dual-channel analysis for identifying hemifusion and subsequent fusion pore formation.
- Calculation of the time delay (Δt) between hemifusion and pore formation.
- Visualization of intensity traces and event distributions.

**Input:** Time-series fluorescence images in TIFF format.

**Output:** Fluorescence intensity traces, detected event positions, matched events, and analysis plots.

## ---------- 2. Splat assay analysis (MATLAB)

**File:** `Splat_assay_analysis.m`

A MATLAB script for quantifying fluorescent particles in dual-channel microscopy images.

**Main features:**
- Independent particle segmentation in two fluorescence channels using adaptive local thresholding.
- Particle counting through connected-component analysis.
- Exclusion of particles exhibiting spatial overlap between channels to minimize potential spectral crosstalk.
- Calculation of the ratio of non-overlapping DV2 particles to liposomes.

**Input:** Dual-channel fluorescence images in TIFF format.

**Output:** Segmentation masks, particle counts, and particle number ratios.

-------------------------------------
## Code Availability

The source code is provided to support reproducibility of the image analysis methods described in the associated publication.

## Contact

Biophysical Fluorescence Laboratory  
National University of Singapore
