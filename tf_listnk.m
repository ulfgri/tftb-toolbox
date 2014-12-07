function tf_listnk(coll)
%
% tf_listnk :  lists all materials in a refractive
%              index collection
%
% Input:
% coll :  string with the name of a collection

% Initial version, Ulf Griesmann, December 2014

    % store current directory
    cdir = pwd();

    % go to collection
    nk_dir = [tf_rootdir(), 'nk/', coll];
    cd(nk_dir);
    
    % list of material names
    nk_nam = dir('*.nk');
    nk_nam = {nk_nam.name};
    nk_nam = cellfun(@(x)x(1:end-3), nk_nam, 'UniformOutput',0);
     
    % restore current directory
    cd(cdir);
    
    % print out names in 4 columns
    fprintf('\n');
    fprintf('  %-25s  %-20s  %-20s  %-20s\n', nk_nam{:});
    fprintf('\n\n');
    fprintf('  %d materials\n\n', length(nk_nam));
    
end
