function tf_listnk(coll)
%
% tf_listnk :  lists all materials in a refractive
%              index collection
%
% Input:
% coll :  (Optional) string with the name of a collection.
%         When the function is called without argument, the
%         available refractive index collections are displayed.

% Initial version, Ulf Griesmann, December 2014

    % store current directory
    cdir = pwd();

    % check argument
    if nargin < 1

        % go to nk root dir
        nk_dir = [tf_rootdir(), 'nk/'];
        cd(nk_dir);
        
        % directory list
        D = dir;
        
        % get names of collections
        colnam = {};
        for k = 1:length(D)
            if ~strcmp(D(k).name,'.') && ...
               ~strcmp(D(k).name,'..') && ...
               D(k).isdir
                  colnam{end+1} = D(k).name;
            end
        end
        
        % print collection names
        fprintf('\n');
        fprintf('  %-s\n', colnam{:});
        fprintf('\n  %d collections\n\n', length(colnam));
    
    else
    
        % go to collection
        nk_dir = [tf_rootdir(), 'nk/', coll];
        cd(nk_dir);
    
        % list of material names
        nk_nam = dir('*.nk');
        nk_nam = {nk_nam.name};
        nk_nam = cellfun(@(x)x(1:end-3), nk_nam, 'UniformOutput',0);
        
        m_nam = dir('*.m');
        m_nam = {m_nam.name};
        m_nam = cellfun(@(x)[x(1:end-2),'<F>'], m_nam, 'UniformOutput',0);
        
        nk_nam = [nk_nam, m_nam];
        
        % restore current directory
        cd(cdir);
        
        % print out names in 4 columns
        fprintf('\n');
        fprintf('  %-25s  %-20s  %-20s  %-20s\n', nk_nam{:});
        fprintf('\n\n');
        fprintf('  %d materials\n\n', length(nk_nam));
    end
end
