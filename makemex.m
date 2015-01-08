%
% script to make .mex files
%

% don't run on Linux or unix with Octave
if isunix && (exist('OCTAVE_VERSION')==5)
    fprintf('\n>>>\n');
    fprintf('>>> Use makemex-octave shell script to compile mex functions in Linux\n');
    fprintf('>>>\n\n');
    return;
end


% check if we are running on MATLAB
if ~(exist('OCTAVE_VERSION')==5)

    % low level functions
    fprintf('\n\n>>>>>\n');
    fprintf('>>>>>  Compiling mex functions for MATLAB ...\n');
    fprintf('>>>>>\n');

    curdir = pwd;
    cd optim/b-splines/@fastBSpline/private
    mex -O evalBin.c
    mex -O evalBinTimesY.c
    mex -O evalBSpline.c
    eval(['cd ',curdir]);    

else % we are on Octave with gcc

    % low level functions
    fprintf('\n\n>>>>>\n');
    fprintf('>>>>>  Compiling mex functions for Octave/Windows ...\n');
    fprintf('>>>>>\n');

    setenv('CFLAGS', '-O3 -fomit-frame-pointer -march=native -mtune=native');
    setenv('CXXFLAGS', '-O3 -fomit-frame-pointer -march=native -mtune=native');

    curdir = pwd;
    cd optim/b-splines/@fastBSpline/private

    mex evalBin.c
    mex evalBinTimesY.c
    mex evalBSpline.c
    system('del *.o');

    eval(['cd ',curdir]);    

end
