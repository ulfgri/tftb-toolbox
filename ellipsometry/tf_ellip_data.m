function [data, meta] = tf_ellip_data(fname)
%function [data, meta] = tf_ellip_data(fname)
%
% tf_ellip_data: reads ellipsometry data. Currently only 
%                has support for .mse files from SOPRA
%                spectroscopic ellipsometers
%
% INPUT
% fname :  string with name of data file
%
% OUTPUT
% data :   a structure with measurement data
%            data.lambda :   a vector with wavelengths
%            data.tanpsi :   tan(psi) at the measurement wavelengths
%            data.cosdel :   cos(delta) at the measurement wavelengths
%            data.alpha :    ellipsometric alpha
%            data.beta :     ellipsometric beta
%            data.aangle :   analyzer angle in degrees
%            data.power :    Power in counts/sec
%            data.intens :   Intensity in counts
%            data.itime :    Integration time in sec
% meta :     a structure with meta-data in the file header

% Ulf Griesmann, NIST, December 2014

    % open file
    fh = fopen(fname, 'rt');
    
    % skip header if not needed
    if nargout > 1
        meta = read_header(fh);
    else
        skip_header(fh);
    end

    % pre-allocate arrays
    data.lambda = zeros(1024,1);
    data.tanpsi = zeros(1024,1);
    data.cosdel = zeros(1024,1);
    data.alpha  = zeros(1024,1);
    data.beta   = zeros(1024,1);
    data.aangle = zeros(1024,1);
    data.power  = zeros(1024,1);
    data.intens = zeros(1024,1);
    data.itime  = zeros(1024,1);
    
    % start reading data
    lc = 0; % line counter
    while 1
        
        % read text line
        str = fgetl(fh);
        if strcmp(str(1:13), '********* End')
            break
        end
        
        % increment counter
        lc = lc + 1;
    
        % convert to vector of numbers
        vdat = sscanf(str,'%f');
        data.lambda(lc) = vdat(1);
        data.tanpsi(lc) = vdat(2);
        data.cosdel(lc) = vdat(3);
        data.alpha(lc)  = vdat(4);
        data.beta(lc)   = vdat(5);
        data.aangle(lc) = vdat(6);
        data.power(lc)  = vdat(7);
        data.intens(lc) = vdat(8);
        data.itime(lc)  = vdat(9);
        
    end
    
    % truncate data vectors
    data.lambda = data.lambda(1:lc);
    data.tanpsi = data.tanpsi(1:lc);
    data.cosdel = data.cosdel(1:lc);
    data.alpha  = data.alpha(1:lc);
    data.beta   = data.beta(1:lc);
    data.aangle = data.aangle(1:lc);
    data.power  = data.power(1:lc);
    data.intens = data.intens(1:lc);
    data.itime  = data.itime(1:lc);
    
    % close file
    fclose(fh);
end


function skip_header(fh)
% 
% read and discard lines up to the data section
%
    while 1
        str = fgetl(fh);
        if length(str)>13 && strcmp(str(1:14), '********* Data')
            break
        end
    end
    
    str = fgetl(fh);  % skip empty line
    str = fgetl(fh);  % data column headers
    
end


function [meta] = read_header(fh)
%
% read the header lines
%
    str = fgetl(fh);  % skip parameter file name
    
    % GESP version
    tok = str_flds(fgetl(fh));
    meta.gesp_ver = str2num(tok{4});
    
    % skip two lines
    str = fgetl(fh);
    str = fgetl(fh);
    
    % comments
    tok = str_flds(fgetl(fh));
    if length(tok) > 2
        meta.comment =  tok{3};
    end
    
    % analyzer parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.analyzer_mode = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.analyzer_pos = str2num(tok{1});
    
    % incidence parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.incidence_mode = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_angle = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_angle = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_angle_meas = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_from = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_to = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_Nb = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_valnum = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_valnum_meas = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.incidence_angle_saved = str2num(tok{1});
    
    % mapping parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.mapping_x = str2num(tok{1});
    meta.mapping_y = str2num(tok{2});
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.mapping_mode = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_numsites = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_geometry = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_width = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_height = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_diameter = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_type = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_rho_step = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_theta_step = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_square_step = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_x1 = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_y1 = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_x2 = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_y2 = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mapping_num_of_pts = str2num(tok{1});
    
    % scanned position
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.scanpos_x = str2num(tok{1});
    meta.scanpos_y = str2num(tok{2});
    tok = str_flds(fgetl(fh));
    meta.scanpos_adjusted = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.scanpos_goto_home = str2num(tok{1});
    
    % integration parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.integration_mode = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_time = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_step = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_duration = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_maxtime = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_shot_target = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_snr_target = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_rsd_target = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.integration_rsd_maxiter = str2num(tok{1});
    
    % noise parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.noise_mode = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.noise_background = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.noise_repetition = str2num(tok{1});
    
    % spectrometer parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.spectro_mode = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_unit = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_position = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_from = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_to = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_step = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_numscan = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_type1 = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_type2 = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_type3 = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.spectro_type4 = str2num(tok{1});
    
    % other parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.correction_type = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.mirror_analyzer = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.attenuator_used = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.compensator_used = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.uv_filter_used = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.auto_switch = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.microspots_used = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.must_spectro_init = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.must_gonio_init = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.window_used = str2num(tok{1});
    
    % anisotropic parameters
    str = fgetl(fh);
    tok = str_flds(fgetl(fh));
    meta.aniso_from = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.aniso_to = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.aniso_Nb = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.adjust_z_axis = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.adjust_z_axis_type = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.adjust_z_axis_value = str2num(tok{1});
    tok = str_flds(fgetl(fh));
    meta.z_start_wavelen = str2num(tok{1});
    
    skip_header(fh);
    
end
