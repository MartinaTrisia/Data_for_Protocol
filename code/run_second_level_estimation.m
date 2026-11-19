%-----------------------------------------------------------------------
% Script by Martina Trisia Cinca-Tomás on 20-Feb-2025
%-----------------------------------------------------------------------
clear all; close all; clc
opengl software
spm('defaults','fmri'); %Open spm for fMRI analyses
spm_jobman('initcfg'); %Initialize batch system


Type_Test = 'Flexible_Factorial';


% Which FD
% FD (defining the pathway):
Options_group = {'BLA','PAC'};
path = listdlg('PromptString','Which path? BLA/PAC',...
    'SelectionMode','single',...
    'ListString',Options_group,...
    'InitialValue', 1, ...
    'ListSize', [300 70]);
path = Options_group{path};

fol_path = path;

% Centering options
Options_group = {'Overall Mean','No Centering'};
Cen = listdlg('PromptString','Should we center?',...
    'SelectionMode','single',...
    'ListString',Options_group,...
    'InitialValue', 2, ...
    'ListSize', [300 70]);
Cen = Options_group{Cen};
if strcmp(Cen,'Overall Mean')
    center = 1;
elseif strcmp(Cen,'No Centering')
    center = 5;
end

%% Paths
if exist('E:','dir')
    port = 'E:';
elseif exist('D:','dir')
    port = 'D:';
elseif exist('F:','dir')
    port = 'F:';
else
    error('None of the expected data drives were found.');
end

if strcmp(path,'BLA')
    DWI_path = fullfile(port,'Results','DWI','MGB_path',filesep);
elseif strcmp(path,'PAC')
    DWI_path = fullfile(port,'Results','DWI','Cortical_path',filesep);
end
main_path = fullfile(port,'Results','MRI', filesep);
%% Subjects & conditions
Subjects = [4,6:29,31,33:37];
ncond = 4;
%% Results path
Results_path = [main_path '2ndLevel' filesep fol_path filesep Type_Test filesep];
%% Log file
% Name logfile
anal_logfile = [Results_path 'analysis_log_second_level_estimation.txt'];
% Initialize analysis logfile
anal_logfile = fopen(anal_logfile,'a');
fprintf(anal_logfile,'\r\n%s','******************************************');
fprintf(anal_logfile,'\r\n%s',datestr(now)); % write date and time
fprintf(anal_logfile,'\r\n%s','run_second_level_estimation'); % Indicate which script is generating the output to the log

fprintf(anal_logfile,'\r\n%s',['********************** RUNNING 2ND LEVEL ESTIMATION **********************']);
%% Model estimation
matlabbatch{1}.spm.stats.fmri_est.spmmat = {Results_path};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;


fprintf(anal_logfile,'\r\n%s',['********************** MODEL ESTIMATION DONE **********************']);
save([Results_path 'matlabbatch_second_level_estimation' date],'matlabbatch');
fprintf(anal_logfile,'\r\n%s',['********************** Saving matlabbatch.mat **********************']);

spm_jobman('run',matlabbatch);
fprintf(anal_logfile,'\r\n%s',['********************** jobman running matlabbatch done **********************']);
clear matlabbatch % clear matlabbatch

fprintf(anal_logfile,'\r\n%s','******************************************');
fclose(anal_logfile);