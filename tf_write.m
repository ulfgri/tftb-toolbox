function tf_write(fname, stack, cmnt, snm)
%function tf_write(fname, stack, cmnt, snm)
%
% tf_write:  writes the design data of a thin film material stack 
%            as a table in either html or flat text format or as a 
%            MATLAB/Octave function that can be used to load a
%            film stack into a new MATLAB session.
%
% INPUT
%    fname :  name of output file. The output file format is derived
%             from the file extension:
%               .m :    Octave/MATLAB file format
%               .txt :  flat text file
%               .html : HTML format table
%    stack :  a structure array with a material stack definition
%                stack(k).d :  layer thickness in um
%                stack(k).n :  refractive index table, function
%                              handle, or directly specified constant
%                              index
%    cmnt :   a string or cell array of strings with a comment at
%             the beginning of the file.
%    snm  :   if equal to 'nm', the layer thickness is written in nm (only
%             for .txt and .html formats !)
    

% initial version, Ulf Griesmann, December 2013

    % check arguments
    if nargin < 4, snm = []; end
    if nargin < 3, cmnt = {}; end
    if nargin < 2
        error('tf_write: Too few arguments.');
    end
    if isempty(snm),  snm = 'um'; end
    if isempty(cmnt), cmnt = {'TFTB thin film stack'}; end
    if ~iscell(cmnt), cmnt = {cmnt}; end

    if strcmp(snm, 'nm')
        tustr = 'nm';
        hustr = 'nm';
        ufac  = 1000;
    else
        tustr = 'um';
        hustr = '&micro;m';
        ufac  = 1;
    end

    % layer thicknesses
    d = [stack.d];

    % determine output format
    if strcmp(fname(end-1:end), '.m')
        outf = 'octave';
    elseif strcmp(fname(end-3:end), '.txt')
        outf = 'text';
    elseif strcmp(fname(end-4:end), '.html')
        outf = 'html';
    else
        error('unsupported output format.');
    end 
    
    % open file
    fh = fopen(fname, 'wt');
    if fh == -1
        error( sprintf('tf_write: error opening file %s .\n', fname) );
    end

    % select the output format
    switch outf
    
      case 'html' % HTML format

         fprintf(fh, '<html>\n');
         fprintf(fh, '<head>\n');
         fprintf(fh, '<title>TFTB thin film stack</title>\n');
         fprintf(fh, '<style>\n');
         fprintf(fh, ['table, th, td {\n' ...
                      'border: 1px solid black;\n' ... 
                      'border-collapse: collapse; }\n']);
         fprintf(fh, ['th, td {\n' ...
                      'padding: 5px; }\n']);
         fprintf(fh, ['th {\n' ...
                      'text-align: left; }\n']);
         fprintf(fh, ['table.tftb th {\n' ...
                      'color: white;\n' ...
                      'background-color: #333333; }']);
         fprintf(fh, '</style>\n');
         fprintf(fh, '</head>\n');
         fprintf(fh, '<h2>TFTB Thin Film Stack</h2>\n');
         fprintf(fh, '<b>File name: </b> %s<br><br>\n', fname);
         fprintf(fh, '<b>Comment:</b><br>\n');
         for k=1:length(cmnt)
             fprintf(fh, '%s<br>\n', cmnt{k});
         end
         fprintf(fh, '<br>\n');
         fprintf(fh, '<table border=\"1\" class=\"tftb\"\n');
         fprintf(fh, '<tr>\n');
         fprintf(fh, ['<th>Layer</th>\n', ...
                      '<th>Thickness / %s</th>\n' ...
                      '<th>Material (Collection)</th>\n'], hustr); ...
         fprintf(fh, '</tr>\n');
         for k=1:length(stack)
             if isa(stack(k).n, 'function_handle')
                 mn = sprintf('@%s', func2str(stack(k).n) );
             elseif isstruct(stack(k).n)
                 mn = sprintf('%s', stack(k).n.name);
             else
                 mn = sprintf('constant (%.5f%gi)', real(stack(k).n), imag(stack(k).n));
             end
             fprintf(fh, '<tr>\n');
             if k==1   
                  fprintf(fh, '<td><b>Entrance medium</b></td>\n');
                  fprintf(fh, '<td>infinite</td>\n');
             elseif k==length(stack)
                  fprintf(fh, '<td><b>Substrate</b></td>\n');
                  fprintf(fh, '<td>infinite</td>\n');
             else
                  fprintf(fh, '<td><b>%d</b></td>\n', k-1);
                  if ufac==1
                      fprintf(fh, '<td>%.4f</td>\n', d(k));
                  else
                      fprintf(fh, '<td>%.1f</td>\n', ufac*d(k));
                  end
             end
             fprintf(fh, '<td>%s</td>\n', mn);
             fprintf(fh, '</tr>\n');
         end
         fprintf(fh, '</table>\n');
         fprintf(fh, '</html>\n');

        
      case 'text' % flat table format

         fprintf(fh, 'File name: %s\n\n', fname);
         for k=1:length(cmnt)
             fprintf(fh, '%s\n', cmnt{k});
         end
         fprintf(fh,'\n');
         fprintf(fh, 'Layer #     d / %s        Material (Coll)\n', tustr);
         fprintf(fh, '----------  ----------    ---------------\n');
         for k = 1:length(stack)
             if isa(stack(k).n, 'function_handle')
                 mn = sprintf('@%s', func2str(stack(k).n) );
             elseif isstruct(stack(k).n)
                 mn = sprintf('%s', stack(k).n.name);
             else
                 mn = sprintf('constant (%.5f%gi)', real(stack(k).n), imag(stack(k).n));
             end
             if k==1
                 fprintf(fh, '%-10s  %10s    %s\n', 'Entrance', 'Inf', mn);
             elseif k==length(stack)
                 fprintf(fh, '%-10s  %10s    %s\n', 'Substrate', 'Inf', mn);
             else
                 fprintf(fh, '%-10d  %10.4f    %s\n', k-1, ufac*d(k), mn);
             end
         end

         
      case 'octave' % MATLAB function

         fprintf(fh, 'function [S] = %s();\n', fname(1:end-2));
         fprintf(fh, '%%\n%% %s\n%%\n', fname);
         for k=1:length(cmnt)
             fprintf(fh, '%% %s\n', cmnt{k});
         end
         fprintf(fh, '%%\n');
         for k = 1:length(stack)     
             if isa(stack(k).n, 'function_handle')
                 fprintf(fh, '   S(%d) = tf_layer(@%s, %.6f);\n', k, func2str(stack(k).n), d(k)); 
             elseif isstruct(stack(k).n)
                 fprintf(fh, '   S(%d) = tf_layer(tf_readnk(''%s'',''%s''), %.6f);\n', k, ...
                         get_material(stack(k).n.name), get_collection(stack(k).n.name), d(k));
             else
                 fprintf(fh, '   S(%d) = tf_layer(%.5f - %gi, %.6f;\n', k, ...
                         real(stack(k).n), imag(stack(k).n), d(k));
             end
         end
         fprintf(fh, '\nend\n');
         
      otherwise
         error('unrecognized output file type.');
    end

    % close file
    fclose(fh);

end

%
% auxiliary functions
%
function mat = get_material(str)
% return name of material
    mat = strtok(str, ' (');
end

function col = get_collection(str)
% return name of collection
    [~,rem] = strtok(str, '(');
    col = deblank(strtok(rem, ')'));
    col = col(2:end);
end
