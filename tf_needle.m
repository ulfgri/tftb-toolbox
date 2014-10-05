function [stackwn, qmin, qidx] = tf_needle(stack, lambda, theta, pol, mfun, mfpar, ri, nic)
%function [stackwn, qmin, qidx] = tf_needle(stack, lambda, theta, pol, mfun, mfpar, ri, nic)
% 
% tf_needle :  determines optimal positions of a needle layer
%              in a multi-layer film stack and returns a new
%              film stack containing the needle layer. 
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified constant index.
% lambda :  a vector with wavelengths in um.
% theta :   a vector with angles of incidence on the first interface 
%           in degrees. Default is 0;
% pol :     polarization, either 's', 'p', or 'u'
% mfun :    a function handle with a merit function
%
%              merit = mfun(d,nk,lambda,theta,pol,mfpar)
%
%           where
%                 d :      thicknesses of all layers in um
%                 nk :     complex refractive index of all layers.
%                 lambda : vector with wavelengths in um
%                 theta :  vector with angles in degree
%                 pol :    polarization 's', 'p', or 'u'
%                 mfpar :  structure with additional parameters
% mfpar :   a structure with additional parameters for the merit function
%           that is passed to the merit function.
% ri :      complex refractive index of the needle material. Either a
%           function handle, a refractive index structure (ri.lambda, 
%           ri.nk - see function 'tf_readnk.m'), or a constant.
% nic :     (Optional) a structure with parameters controlling the
%           needle insertion.
%              nic.plot :  if == 1, plot the merit function change as
%                          function of needle position. Default is 0.
%              nic.nwid :  width of the needle in micrometer.
%                          Default is 1e-7.
%              nic.npos :  number of needle positions per layer. 
%                          Default is 50.
%              nic.swid :  width of the inserted layer in the new
%                          thin film stack. Default it 1e-4.
%
% Output:
% stackwn : structure array with the modified  material stack 
%           containing a needle.
% qmin :    minimum of the merit function change.
% qidx :    layer index of the needle in the output layer stack. 
%
% References:
% [1] B. T. Sullivan and J. A. Dobrowolski, "Implementation of a
%     numerical needle method for thin-film design", Appl. Opt. 35,
%     5485-5492 (1996)
% [2] S. Larouche and L. Martinu, "OpenFilters: open-source software
%     for the design, optimization, and synthesis of optical
%     filters", Appl. Opt. 47(13), C219-C230 (2008)
%
% NOTE: The change in the merit function is typically calculated by
% first calculating the change in the characteristic matrix, dM/dd_i,
% that results from inserting a "needle" in the thin film stack. The
% change in the merit function is then calculated using dM/dd. The
% approach taken here is more direct: a very thin layer is inserted in
% a layer and the resulting change in the merit function is
% calculated. This approach is equivalent to the method described
% in Refs. [1,2] and requires no more computation.

% Initial version, Ulf Griesmann, November 2013

% constants
lwidth = 2;   % plot line width
lfsize = 14;  % label/legend font size

% check arguments
if nargin < 8, nic = []; end
if nargin < 7
   error('tf_needle :  missing arguments.');
end
if ~isa(mfun, 'function_handle')
   error('tf_needle :  argument mfun must be a function handle.');
end
if isempty(nic)
   nic = struct('plot',0, 'nwid',1e-7, 'npos',50, 'swid',1e-4);
else
   if ~isfield(nic, 'plot'), nic.plot = 0; end
   if ~isfield(nic, 'nwid'), nic.nwid = 1e-7; end
   if ~isfield(nic, 'npos'), nic.npos = 50; end
   if ~isfield(nic, 'swid'), nic.swid = 1e-4; end
end

% get layer thicknesses and calculate nk for all lambda
d   = [stack.d];             % layer thicknesses
nk  = evalnk(stack, lambda); % nk for all layers
nkn = tf_nk(ri, lambda);     % nk for needle material

% calculate the merit function for the unperturbed stack
q0 = mfun(d, nk, lambda, theta, pol, mfpar);

% loop over layers and calculate dQ/dd in each one
DQ = zeros(nic.npos*(length(stack)-2),1); % max. possible size
X  = zeros(nic.npos*(length(stack)-2),1);
iq = 0;
x0 = 0;
qmin = 1e99;

for k = 2:length(d)-1

   % check if needle material is different
   if any(nkn ~= nk(k,:))
   
      % needle position increment
      Dd = d(k) / nic.npos;
   
      % insert needles and calculate merit function change
      for pos = Dd*[0:nic.npos]
         [dwn, nkwn] = add_needle(d, nk, k, pos, nic.nwid, nkn);
         dq = (mfun(dwn, nkwn, lambda, theta, pol, mfpar) - q0) / nic.nwid;
         if dq < qmin
            qmin = dq;
            qidx = k;
            qpos = pos - 0.5*Dd;  % needle position in layer k
            spos = x0 + qpos;     % needle position in stack
         end
         iq = iq + 1;
         X(iq) = x0 + pos;
         DQ(iq) = dq;
      end
      
      iq = iq + 1;
      X(iq) = x0 + d(k);
      DQ(iq) = 0;
      
   else % material is the same
     
      iq = iq + 1;
      X(iq) = x0 + d(k);
      DQ(iq) = 0;
      
   end

   x0 = x0 + d(k);
   
end

% truncate DQ,X to actual length
DQ = DQ(1:iq);
X  = X(1:iq);

% insert needle in stack
[stackwn,qidx] = tf_insert(stack, qidx, qpos, nic.swid, ri);

% plot DQ
if nic.plot

   figure
   
   % plot DQ
   plot(X, DQ, 'k', 'Linewidth',lwidth);
   hold on
   
   % plot layer boundaries
   dqmin = min(DQ);
   dqmax = max(DQ);
   for dsum = cumsum(d(2:end-1))
      plot([dsum,dsum], [dqmin,dqmax], 'b', 'Linewidth',lwidth);
   end
   
   % mark location of minimum
   plot([spos,spos], [dqmin,dqmax], 'r', 'Linewidth',lwidth);
   
   % decoration
   xlabel('Needle position / um', 'Fontsize',lfsize);
   ylabel('Merit function change', 'Fontsize',lfsize);
   
end

return


function [dwn, nkwn] = add_needle(d, nk, k, pos, nwid, nkn)
%
% add a needle with refractive index 'nkn' and width 'nwid' 
% at position 'pos' in the k-th layer of a material stack.
%

% check arguments
if abs(d(k)-pos) < 10*eps
   pos = d(k); % make it numerically stable
elseif pos > d(k) + 10*eps
   error(sprintf('tf_needle: pos is larger than thickness of layer %d\n', k));
end

% pre-allocate outputs
dwn = zeros(1,length(d)+2);
[nr,nc] = size(nk);
nkwn = zeros(nr+2,nc);

% thickness
dwn(1:k-1) = d(1:k-1);
dwn(k) = pos;
dwn(k+1) = nwid;
dwn(k+2) = d(k) - pos;
dwn(k+3:end) = d(k+1:end);

% refractive index
nkwn(1:k,:) = nk(1:k,:);
nkwn(k+1,:) = nkn;
nkwn(k+2,:) = nk(k,:);
nkwn(k+3:end,:) = nk(k+1:end,:);

return
