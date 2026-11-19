This repository contains the files required to reproduce the second-level flexible factorial analysis described in the protocol by Cinca-Tomás et al.

The deposited dataset includes:

- Four first-level fMRI contrast images per participant (con_0010.nii, con_0011.nii, con_0012.nii and con_0013.nii).
- A manifest linking every contrast image to its participant and AM × CS condition.
- Definitions of the four first-level contrasts.
- Participant-level left and right fiber-density values.
- MATLAB code for specifying and estimating the second-level model.
- Modified SPM12 source files required to generate the AM-first condition-specific covariate regressors used in the example application.

The deposit is intended to reproduce the second-level workflow. It does not contain the raw or preprocessed diffusion MRI and fMRI data required to repeat diffusion preprocessing, tractography, fMRI preprocessing, or first-level model estimation.
