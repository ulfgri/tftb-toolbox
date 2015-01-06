% A Thin Film Multilayer Toolbox for Octave and MATLAB
% ====================================================
% 
% Ulf Griesmann, 2013,2014,2015
% ulf.griesmann@nist.gov, ulfgri@gmail.com
%
% Most functions of this software are in the public domain.
% The function 'devec3.m' for differential evolution
% optimization are distributed under the  GNU Public License,
% the ASA library for adaptive simulated annealing is (c) Lester 
% Ingber.
%
% Stable versions can be downloaded from:
% https://sites.google.com/site/ulfgri/numerical/tftb
%
% Development versions are on:
% https://github.com/ulfgri/tftb-toolbox
%
%
% Functions
% =========
%
% Refractive index data:
% ----------------------
%    tf_readnk.m     - read a complex refractive index spectrum
%    tf_nk.m         - evaluate index spectrum at wavelength(s)
%    tf_plotnk.m     - plot complex refractive index spectra
%    tf_searchnk.m   - search materials with specific n, k
%    tf_listnk.m     - list materials in an index data collection
%    tf_maxgarn.m    - effective index of Maxwell Garnet model
%    tf_fitn.m       - fit Cauchy and Sellmeier models to data
%
%
% Film stack design:
% ------------------
%    tf_layer.m       - add a layer structure to a film stack
%    tf_repl.m        - design stack with layer repetitions
%    tf_insert.m      - insert a new material in a film stack
%    tf_prune.m       - remove layers with thickness outside range
%    tf_optimize.m    - optimize layer thicknesses using SQP
%    tf_optimize_se.m - optimize layer thicknesses with adaptive
%                       simulated annealing (ASA)
%    tf_optimize_de.m - layer thickness optimization using a 
%                       differential evolution algorithm
%    tf_optimize_lm.m - least squares optimization of layer
%                       thicknesses using a Levenberg-Marquardt
%                       algorithm
%    tf_needle.m      - synthesize new stack with needle method
%
%
% Film stack analysis and visualization:
% --------------------------------------
%    tf_stack.m      - display thin film stack data
%    tf_plot.m       - plot T, R, A, and etc.
%    tf_plotPD.m     - plot ellipsometric Psi,Delta, and rho
%    tf_plotN.m      - plot refractive index profiles
%    tf_plotrad.m    - plot reflectance amplitude diagrams
%    tf_plotY.m      - plot admittance diagrams
%    tf_plotE.m      - plot electric field strength in stack
%    tf_plotGD.m     - plot group delay (GD) and dispersion (GDD)
%    tf_plotrgb.m    - plot an array of RGB color swatches
%
%
% Light reflection and transmission:
% ----------------------------------
%    tf_charmat.m    - calculate characteristic matrices
%    tf_bc.m         - calculate B, C
%    tf_bcinc.m      - incremental B, C for a material stack
%    tf_ampl.m       - calculate reflected and transmitted 
%                      amplitudes
%    tf_phase.m      - phase of reflected and transmitted amplitudes
%    tf_amplinc.m    - incremental reflected and transmitted
%                      amplitudes for material stacks
%    tf_admit.m      - calculate admittance
%    tf_admitinc.m   - incremental admittance for a material stack
%    tf_int.m        - calculate reflectance and transmittance
%    tf_int_sub.m    - reflectance and transmittance including substrate
%    tf_efield.m     - calculate electric field strength in film stack
%    tf_gd.m         - group delay (GD) and group delay dispersion (GDD)
%    tf_int_sub.m    - reflectance and transmittance for multilayers
%                      on a substrate.
%
%
% Film stack optical properties:
% ------------------------------
%    tf_spectrum.m     - spectral response of film stack
%    tf_spectrum_sub.m - spectral response including substrate 
%    tf_swingcurve.m   - T and R as function of film thickness
%    tf_rayfan.m       - T and R as function of angle of incidence
%    tf_rayfan_sub.m   - T and R as function of AOI including substrate
%    tf_color.m        - calculate reflected and transmitted color
%                        of a thin film stack for CIE illuminants.
%
%
% Ellipsometry:
% -------------
%    tf_psi.m        - calculate ellipsometric Psi and Delta
%    tf_ellip.m      - Ellipsometric spectra Psi(lambda) &
%                      Delta(lambda) for a thin film stack
%
%    In directory 'ellipsometry':
%    tf_ellip_match  - Visually compare measured ellipsometry data
%                      with calculated data as function of 
%                      layer thickness (rms of difference) e.g. to
%                      estimate a layer thickness.
%    tf_ellip_d      - calculate layer thicknesses from spectroscopic
%                      ellipsometry data for materials with known
%                      optical constants.
%    tf_ellip_sub    - calculate the complex refractive index of a
%                      material from spectroscopic ellipsometry
%                      data of a substrate, i.e. a single material 
%                      interface.
%    tf_ellip_nk     - calculate Kramers-Kroning consistent optical
%                      constants n(lambda), k(lambda) from
%                      spectroscopic ellipsometry data using
%                      B-Spline models.
%    tf_ellip_data   - read ellipsometry data
%
%
% Film properties:
% ----------------------
%    tf_stoney       - Stoney's formula for film stress
%                      measurements 
%
%
% Miscellaneous:
% --------------
%    tf_write        - write thin film stack data to a file as a table
%                      in HTML or plain text, or as Octave/MATLAB
%                      code.
%    nk_to_eps       - convert refractive index to dielectric function
%    eps_to_nk       - convert dielectric function to refractive
%                      index
%    lambda_to_omega - convert wavelength to angular frequency
%    omega_to_lambda - convert angular frequency to wavelength
%
%
% Units
% =====
% The thin film toolbox uses the micrometer as unit of length for
% thicknesses and wavelengths throughout.
%
%
% Installation
% ============
% Unzip the file tftb-<n>.zip into a directory and include the 'tftb'
% directory and its subdirectories in the Octave or MATLAB search path.
% The refractive index collections must be installed in tftb/nk
% before the toolbox can be used.
