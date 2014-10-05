%
% Octave & MATLAB script to make .mex file
%

% check for Octave 
if exist('OCTAVE_VERSION')==5

    % assume we have gcc
    setenv('CFLAGS', '-O3 -march=native -mtune=native -fomit-frame-pointer');
    mex asamin.c asa.c -DUSER_ACCEPTANCE_TEST#TRUE -DUSER_ASA_OUT#TRUE

else
  
    mex -O asamin.c asa.c -DUSER_ACCEPTANCE_TEST#TRUE -DUSER_ASA_OUT#TRUE
  
end
