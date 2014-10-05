function [rgbr,rgbt] = tf_color(stack, type, theta, pol, fname, illum, obs, swsize)
%function [rgbr, rgbt] = tf_color(stack, type, theta, pol, fname, illum, obs, swsize)
%
% tf_color : calculate a color swatch for a thin film stack in 
%            reflection and/or transmission and display it or 
%            save it in a file. 
%
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified constant
%                            index
% type :    (Optional) Either 'r' ('R') for the color in
%           reflection, or 't' ('T') for the color in
%           transmission, or 'b' ('B') for both. Both are
%           calculated by default if isempty(type).
% theta :   (Optional) Angle of incidence on first interface in
%           degrees. Default is 0.
% pol :     (Optional) polarization; either 's', 'p', or 'u'. 
%           Default is 'u' - unpolarized.
% fname :   (Optional) a structure with file name and extension:
%               fname.base :  file name base
%               fname.ext :   file name extension
%           The file name extension determines the output file
%           type, e.g. .png or .eps.
% illum :   (Optional) Selects the CIE standard illuminant. Must be one of 
%           'A', 'F1' ... 'F4', 'D50', 'ID50', 'D65', 'ID65'.
%           Default is D65.
% obs :     (Optional) Selects the CIE standard observer functions. 
%           Either 'Obs1931' or 'Obs1964'. Default is Obs1931.
% swsize :  (Optional) a 1x2 vector with color swatch size in pixels. 
%           Default is [400,400].
%
% Output:
% rgbr, :   (Optional) 3x1 vectors with RGB triples for
% rgbt      reflection color and transmission color. When an
%           output argument is present, the color swatch is not
%           displayed. 

% Initial version, Ulf Griesmann, October 2013

persistent XYZbar     % we don't want to re-load these every time
persistent ILL
persistent lambda_ill 
persistent lambda_xyz
persistent lnm
persistent last_obs
persistent last_illum

% check function input
if nargin < 8, swsize = []; end
if nargin < 7, obs = []; end
if nargin < 6, illum = []; end
if nargin < 5, fname = []; end
if nargin < 4, pol = []; end
if nargin < 3, theta = []; end
if nargin < 2, type = []; end;

if isempty(swsize), swsize = [400,400]; end
if isempty(obs), obs = 'Obs1931'; end
if isempty(illum), illum = 'D65'; end
if isempty(pol), pol = 'u'; end
if isempty(theta), theta = 0; end
if isempty(type), type = 'b'; end

% load the CIE illuminant if new
if isempty(ILL) || ~strcmp(last_illum, illum)
   [lambda_ill, ILL] = read_illuminant(illum);
   last_illum = illum;
end

% load the CIE standard observer functions xbar, ybar, zbar
if isempty(XYZbar) || ~strcmp(last_obs, obs)
   [lambda_xyz, XYZbar] = read_observer(obs);
   last_obs = obs;
end

% common wavelength range for observer and illuminant
if lambda_ill(1) ~= lambda_xyz(1) | lambda_ill(end) ~= lambda_xyz(end)
   lambda_min = max(lambda_ill(1), lambda_xyz(1));
   lambda_max = min(lambda_ill(end), lambda_xyz(end));
   ILL = ILL(lambda_ill>=lambda_min & lambda_ill<=lambda_max,:);
   XYZbar = XYZbar(lambda_xyz>=lambda_min & lambda_xyz<=lambda_max,:);
   lambda_ill = lambda_ill(lambda_ill>=lambda_min & lambda_ill<=lambda_max);
   lambda_xyz = lambda_ill;
end
lnm = lambda_ill;

% calculate reflectance & transmittance for stack
lum = 0.001 * lnm; % wavelength in micrometer
[R, T] = tf_spectrum(stack, lum, theta, pol);

% calculate CIE XYZ tristimulus and color in RGB space
RGBR = []; RGBT = [];
if ~any(strcmp(type, {'r','R','t','T','b','B'}))
   error('tf_color: unknown color swatch type.');
end
if any(strcmp(type, {'r','R','b','B'}))
   XYZR = 100 * trapz(lnm, repmat(R'.*ILL,1,3) .* XYZbar) / ...
                trapz(lnm, ILL.*XYZbar(:,2));
   RGBR = cie_to_rgb(XYZR);
end
if any(strcmp(type, {'t','T','b','B'}))
   XYZT = 100 * trapz(lnm, repmat(T'.*ILL,1,3) .* XYZbar) / ...
                trapz(lnm, ILL.*XYZbar(:,2));
   RGBT = cie_to_rgb(XYZT);
end

% return results if output arguments present
if nargout > 0
   rgbr = RGBR;
   rgbt = RGBT;
   return
end

% create the color swatch
if ~isempty(RGBR)
   swr(1,1,:) = uint16(65535*RGBR);
   swr = repmat(swr, swsize);
end
if ~isempty(RGBT)
   swt(1,1,:) = uint16(65535*RGBT);
   swt = repmat(swt, swsize);
end


% write or display swatch
if isempty(fname)

   if ~isempty(RGBR)
      figure;
      imshow(swr);
      title('Reflection', 'Fontsize',16);
   end
   if ~isempty(RGBT)
      figure;
      imshow(swt);
      title('Transmission', 'Fontsize',16);
   end
     
else % write swatch to a file
  
   if ~isempty(RGBR)
      imwrite(swr, [fname.base, '_r.', fname.ext]);
   end
   if ~isempty(RGBT)
      imwrite(swt, [fname.base, '_t.', fname.ext]);
   end
   
end

return


function RGB = cie_to_rgb(XYZ)
%
% Transform from CIE chromaticity (tristimulus) to sRGB color space.
% Primary color weights are normalized such that the largest 
% non-zero weight is equal to 1.
%

% transform into RGB space
if isrow(XYZ), XYZ = XYZ'; end

RGB =  [1.96253, -0.61068, -0.34137; ...
       -0.97876,  1.91615,  0.03342; ...
        0.02869, -0.14067,  1.34926] * XYZ;

% add white if the color is outside the RGB gamut
if min(RGB) < 0
   RGB = RGB - min(RGB);
end

% map into [0,1]
RGB = RGB / max(RGB);

% transform to sRGB
RGB(RGB <=0.0031308) = 12.92 * RGB(RGB <=0.0031308);
RGB(RGB > 0.0031308) = 1.055 * RGB(RGB > 0.0031308).^0.41667 - 0.055;

return


function [lambda, ILL] = read_illuminant(illum)
%
% read the CIE illuminant
% 1st column is wavelength, 2nd column is illuminant power
%

% read file with illuminant data
T = read_table( [tf_rootdir(),'cie/',illum,'.dat'] );
lambda = T(:,1);
ILL = T(:,2);

return


function [lambda, XYZbar] = read_observer(obs)
%
% read the CIE observer; 
% 1st column is wavelength, then 3 columns with xbar, ybar, zbar
%

% read file with observer data
T = read_table( [tf_rootdir(),'cie/',obs,'.dat'] );
lambda = T(:,1);
XYZbar = T(:,2:4);

return
