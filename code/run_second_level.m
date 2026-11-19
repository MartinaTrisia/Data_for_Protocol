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
%% Load files
files = dir([DWI_path, '*' path '*.mat']);
for lo = 1:size(files,1)
    load([files(lo).folder filesep files(lo).name]);
end

if strcmp(path,'BLA')
    left_path = lMGB_BLA;
    right_path = rMGB_BLA;
elseif strcmp(path,'PAC')
    left_path = lMGB_PAC;
    right_path = rMGB_PAC;
end

fol_path = path;

left  = repelem(left_path,ncond);
right = repelem(right_path,ncond);

%%%%%%%%%%%%%%%%%%%%%

%% Results path
Results_path = [main_path '2ndLevel' filesep fol_path filesep Type_Test filesep];
if ~exist(Results_path,'dir') %Create path if doesn't exist yet
    mkdir(Results_path);
end
%% Log file
% Name logfile
anal_logfile = [Results_path 'analysis_log_second_level.txt'];
% Initialize analysis logfile
anal_logfile = fopen(anal_logfile,'a');
fprintf(anal_logfile,'\r\n%s','******************************************');
fprintf(anal_logfile,'\r\n%s',datestr(now)); % write date and time
fprintf(anal_logfile,'\r\n%s','run_second_level'); % Indicate which script is generating the output to the log

fprintf(anal_logfile,'\r\n%s',['********************** RUNNING 2ND LEVEL ANALYSIS **********************']);
fprintf(anal_logfile,'\r\n%s',['********************** SUBJECTs: ' num2str(Subjects,'%3d') ' **********************']);
fprintf(anal_logfile,'\r\n%s',['*********************** Design: ' Type_Test ' **********************']);
fprintf(anal_logfile,'\r\n%s',['*********************** Path: ' path ' **********************']);
fprintf(anal_logfile,'\r\n%s',['*********************** Centering: ' Cen ' **********************']);

cd(Results_path)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FLEXIBLE FACTORIAL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ii = 1;

% Contrast paths
for isub = 1:size(Subjects,2)
    cont_path = [main_path '1stLevel' filesep 'sub-' num2str(Subjects(isub),'%02d') filesep];
    
    contrst_path{ii,1} = [cont_path 'con_' num2str(0010,'%04d') '.nii,1'];   % High Emo
    contrst_path{ii+1,1} = [cont_path 'con_' num2str(0011,'%04d') '.nii,1']; % High Neu
    contrst_path{ii+2,1} = [cont_path 'con_' num2str(0012,'%04d') '.nii,1']; % Low Emo
    contrst_path{ii+3,1} = [cont_path 'con_' num2str(0013,'%04d') '.nii,1']; % Low Neu
    
    ii = ii + ncond;
end %Subjects loop

% Create the Matrix defining the flexible factorial structure
Matrix(:,1) = ones(1,ncond*size(Subjects,2));
Matrix(:,2) = sort(repmat(1:size(Subjects,2),1,ncond));
[a, b] = ndgrid(1:2, 1:2);
combinations = [b(:), a(:)];
Matrix(:,3:size(combinations,2)+2) = repmat(combinations,size(Subjects,2),1);

% Define the factors
matlabbatch{1}.spm.stats.factorial_design.dir = {Results_path};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'AM';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'CS';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;


matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.scans = contrst_path; % Contrast paths
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.specall.imatrix = Matrix; % Flexible Factorial Structure Matrix
%             matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1; F1 = Subject
%             matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 2; F2
%             matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{3}.fmain.fnum = 3; F3
%             matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{4}.inter.fnums = [2 3]; Interaction F2xF3
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [2 3]; %Interaction F2xF3

matlabbatch{1}.spm.stats.factorial_design.cov(1).c = left; % Vector
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = ['left_' path '_F2xF3']; % Name
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 8; % Interactions
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = center; % Centering

matlabbatch{1}.spm.stats.factorial_design.cov(2).c = right; % Vector
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = ['right_' path '_F2xF3']; % Name
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 8; % Interactions
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = center; % Centering

matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


fprintf(anal_logfile,'\r\n%s',['********************** FLEXIBLE FACTORIAL DONE **********************']);
save([Results_path 'matlabbatch_second_level_' date],'matlabbatch');
fprintf(anal_logfile,'\r\n%s',['********************** Saving matlabbatch.mat **********************']);

spm_jobman('run',matlabbatch);
fprintf(anal_logfile,'\r\n%s',['********************** jobman running matlabbatch done **********************']);
clear matlabbatch % clear matlabbatch

fprintf(anal_logfile,'\r\n%s','******************************************');
fclose(anal_logfile);