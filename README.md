
A Thin Film Multilayer Toolbox for Octave and MATLAB
====================================================

Ulf Griesmann, 2013,2014
ulf.griesmann@nist.gov, ulfgri@gmail.com

Most of this software is in the public domain; some parts, e.g. 
the 'devec3' function for differential evolution minimization is
distributed under the GNU Public License.

New releases, additional documentation, and example scripts
can be downloaded from: 
https://sites.google.com/site/ulfgri/numerical/tftb


Motivation 
========== 
Functional surfaces consisting of multiple thin layers of different
materials are used in numerous applications to modify the surface
properties. Multilayers are very important in optics where they are
used to modify the response of a surface to light. An example are
anti-reflection coatings, which attenuate the reflection of light at
an air-glass interface. In optics the spectral response of multilayer
coatings is often of the greatest interest. Another area in which
multilayers are important is photo-lithography. In photo-lithography a
substrate is coated with a stack of resist materials. The quality of a
lithographic exposure strongly depends on the optical properties of
the resist stack and on its careful optimization. The spectral
dependence of the film stack properties are less important in
photo-lithography, because the wavelength is nearly monochromatic.
Optimization of the layer thicknesses is usually more important.


Other Free Software
===================

OpenFilters: http://larfis.polymtl.ca/index.php/en/links/openfilters
--------------------------------------------------------------------
A thin film modeling program from the Functional Coating and Surface
Engeineering Laboratory a the Ecole Polytecnique de Montreal, Quebec,
Canada. Written in Python and C++ by "thin film professionals". 
Unfortunately, very limited database of refractive indices. 


FreeSnell : http://people.csail.mit.edu/jaffer/FreeSnell/
---------------------------------------------------------
FreeSnell is a software package for analyzing thin film multi-layers
multi-layers written in Scheme. No design functionality.


tmm: https://pypi.python.org/pypi/tmm
-------------------------------------
TMM is a group of programs written in Python / NumPy for simulating light
propagation in planar multilayer thin films, including the effects of
multiple internal reflections and interference, using the "Transfer
Matrix Method".


Units
=====
The thin film toolbox uses the micrometer as length unit for
thicknesses and wavelengths throughout.


Installation
============
Unzip the file tftb-<n>.zip into a directory and include the 'tftb'
directory and its subdirectories in the Octave or MATLAB search path.
The refractive index spectra collections in file
'nk_collections_<date>.zip' must also be installed before the toolbox
can be used.


Please report inconsistencies, problems, and errors. Requests for
improvements are welcome !

---

