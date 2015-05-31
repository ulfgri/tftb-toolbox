function tf_plotPD(L, P, D, topt, mode, bnew)
%function tf_plotPD(L, P, D, topt, mode, bnew)
%
% tf_plotPD :  plot ellipsometric functions Psi(lambda), Delta(lambda),
%              and rho in different graphical representations.
%
% Input:
% L :       a vector with wavelengths
% P :       Psi(L)
% D :       Delta(L)
% topt :    (Optional) a structure of strings with label text 
%           options:
%              topt.xlabel :  x-axis label; default: 'Lambda / um'
%              topt.title :   plot title; default: []
%              topt.grid :    turn on grid if > 0; default: 1
% mode :    (Optional) a string with the plot mode:
%              'std' :  plot Psi(L) and Delta(L)
%              'mag' :  plot tan(Psi(L)) and cos(Delta(L))
%              'rho' :  plot rho (NOTE: use unwrapped Psi, Delta)
%           Default is 'std'.
% bnew :    (Optional) create a new figure if > 0. Default is 0.

% Ulf Griesmann, December 2014

    % constants
    lwidth = 2;   % plot line width
    tfsize = 16;  % title font size
    lfsize = 14;  % label/legend font size
    if is_octave
       msize = 12;% marker size for plotting
    else
       msize = 24;
    end
    
    % check arguments
    if nargin < 6, bnew = []; end
    if nargin < 5, mode = []; end
    if nargin < 4, topt = []; end
    if nargin < 3
        error('tf_plotPD :  at least three arguments required.');
    end
    if ischar(topt) % for backward compatibility
        topt = struct('xlabel',topt);
    end
    if isempty(topt) 
        topt = struct('xlabel','Lambda / um', 'title',[]);
    end
    if ~isfield(topt, 'xlabel')
        topt = setfield(topt, 'xlabel','Lambda / um');
    end
    if ~isfield(topt, 'title')
        topt = setfield(topt, 'title',[]);
    end
    if ~isfield(topt,'grid') 
        topt = setfield(topt, 'grid',1);
    end
    if isempty(mode), mode = 'std'; end
    if isempty(bnew), bnew = 0; end

    % make new plot window
    if bnew
       figure
    end

    switch mode
  
     case 'std'
         % plot Psi
         subplot(1,2,1);
         plot(L, P, 'r', 'Linewidth',lwidth);
         xlabel(topt.xlabel, 'Fontsize',lfsize);
         ylabel('Psi (deg)', 'Fontsize',lfsize);
         if ~isempty(topt.title)
             title(topt.title);
         end
         if topt.grid  
             grid on
         end
         
         % plot Delta
         subplot(1,2,2);
         plot(L, D, 'b', 'Linewidth',lwidth);
         xlabel(topt.xlabel, 'Fontsize',lfsize);
         ylabel('Delta (deg)', 'Fontsize',lfsize);
         if topt.grid  
             grid on
         end

     case 'mag'
         % plot tan(Psi) = |rho|
         subplot(1,2,1);
         plot(L, tand(P), 'r', 'Linewidth',lwidth);
         xlabel(topt.xlabel, 'Fontsize',lfsize);
         ylabel('tan(Psi)', 'Fontsize',lfsize);
         if ~isempty(topt.title)
             title(topt.title);
         end
         if topt.grid  
             grid on
         end
         
         % plot cos(Delta) = cos(arg(rho))
         subplot(1,2,2);
         plot(L, cosd(D), 'b', 'Linewidth',lwidth);
         xlabel(topt.xlabel, 'Fontsize',lfsize);
         ylabel('cos(Delta)', 'Fontsize',lfsize);
         if topt.grid
             grid on
         end

     case 'rho'
         % plot ellipsometric rho in complex plane
         X = tand(P) .* cosd(D);
         Y = tand(P) .* sind(D);
         if length(X) > 20
             psty = 'b';
         else
             psty = 'b.';
         end
         plot(X, Y, psty, 'Linewidth',lwidth, 'MarkerSize',msize);
         grid on
         hold on
         plot(X(1),Y(1),'g.', 'MarkerSize',msize);
         plot(X(end),Y(end),'r.', 'MarkerSize',msize);
         xlabel('Re(rho)', 'Fontsize',lfsize);
         ylabel('Im(rho)', 'Fontsize',lfsize);
         if ~isempty(topt.title)
             title(topt.title);
         end
         if topt.grid  
             grid on
         end
      
     otherwise
         error(sprintf('tf_plotpd: unknown mode argument ''%s''',  mode));
    end
end
