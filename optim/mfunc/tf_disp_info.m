function tf_disp_info(info, iter)
% 
% display optimization information
%

    switch info

     case 0
         fprintf('  Failure - maximum number of iterations exceeded.\n');
    
     case 1
         fprintf('  Success - algorithm terminated normally.\n');
    
     case -1
         fprintf('  Stopped by an output function or plot function.\n');
    
     case -2
         fprintf('  Failure - no feasible point was found.\n');
      
     case 101
         fprintf('  Success - algorithm terminated normally.\n');
    
     case 102
         fprintf('  Failure - BGFS update failed.\n');
 
     case 103
         fprintf('  Failure - maximum number of iterations reached.\n');
 
     case 104
         fprintf('  Warning - no convergence, step size is too small.\n');
         
    end

end
