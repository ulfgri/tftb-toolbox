function tf_disp_d(d, didx, S)
% 
% display optimized film thicknesses
%
    fprintf('\n');
    fprintf('  layer #    thickness / um    material\n');
    fprintf('  -------    ----------------  --------\n');
    for k = 1:length(d)
        if isa(S(didx(k)).n, 'function_handle')
            mname = func2str(S(didx(k)).n);
        elseif isstruct(S(didx(k)).n)
            mname = S(didx(k)).n.name;
        else
            mname = 'undefined';
        end
        fprintf('  %-7d    %.4f            %s\n', didx(k), d(k), mname);
    end
    fprintf('\n');

end
