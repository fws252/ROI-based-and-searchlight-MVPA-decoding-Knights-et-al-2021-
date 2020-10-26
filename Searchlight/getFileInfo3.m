%The experiment code that was used in: Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020). 
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions. bioRxiv. doi: 10.1101/2020.10.14.339606
%The code was originally created by Fraser W. Smith (see Smith & Goodale 2015 Cerebral Cortex, eprint 2013) 
% and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [input_file_info]=getFileInfo3(subNo)

% if(strcmp(sname,'BM30'))
snames={'CR09','DT12','JM15','JR24','KH02','KL04','LB28','LP12','MC17','MK14','QP18','QR30','RE29','RL17','RS06','SC13','ST28','TS12','VB04'}; %,'','',''};
%sDIR={''};
% subNo=;
order=[6 1 4 3 1 5 5; 1 6 3 4 2 5 0; 1 2 6 3 4 5 0; 2 6 4 1 5 3 1; 1 3 5 6 4 0 0; 6 2 3 4 5 2 0; 3 2 6 1 5 4 3; 4 6 1 5 2 3 0; 5 1 3 6 4 2 1; 4 5 1 6 2 3 4; 1 4 2 5 3 6 0; 3 6 5 2 1 4 0; 2 6 1 4 3 5 4; 3 5 2 4 1 6 3; 2 4 1 6 5 3 5; 5 6 7 2 3 4 0; 6 5 4 3 2 1 3; 1 2 3 4 5 6 0; 4 5 6 1 2 0 0;];
nRuns=length(find(order(subNo,:)));

% the path to the files
dir_name=sprintf('/gpfs/home/wyq12enu/%s/',snames{subNo});

loc_name=sprintf('%s_voislocalizer.voi',snames{subNo});


%%% important parameters
nVols=178;
nPreds=16; % number of trials not inc any null events
nTrials=16;
nPerRun=1;   %% nReps per condition per run
TR = 2000;  % in msec so TR 1 = 1000msec, needed for xff functions to create SDMs (HRFs)
nPredsSimple=16; preds2corr=1:16;

% specify data file name
for r=1:nRuns
    %Filename Unknown vs. Neurological_Unknown
    if strcmp(snames{subNo},'CR09') || strcmp(snames{subNo},'ST28') || strcmp(snames{subNo},'RS06') || strcmp(snames{subNo},'RL17') || strcmp(snames{subNo},'DT12') || strcmp(snames{subNo},'LP12') || strcmp(snames{subNo}, 'QP18') || strcmp(snames{subNo},'TS12')
        data_name{r}=sprintf('%s_toolstudy1_Run%d_Order%d_SCCAI_3DMCS_THPGLMF2c_LOCAL_TAL_Neurological_Unknown.vtc',snames{subNo},r,order(subNo,r));
    else
        data_name{r}=sprintf('%s_toolstudy1_Run%d_Order%d_SCCAI_3DMCS_THPGLMF2c_LOCAL_TAL_Unknown.vtc',snames{subNo},r,order(subNo,r));
    end
    
    prtNames{r}=['/gpfs/home/wyq12enu/PRT/new_prts/' sprintf('toolstudy1_%s_Run%d_Order%d.prt',snames{subNo},r,order(subNo,r))];
    
    mp_name{r}=sprintf('%s_toolstudy1_Run%d_Order%d_3DMC.sdm',snames{subNo},r,order(subNo,r));
end
end


% put into structure for easy passing
input_file_info=[];
pars(1)=nVols;
pars(2)=nPreds;  %% remember to add 1 for the constant column
pars(3)=nTrials;
pars(4)=nPerRun;
pars(5)=nPredsSimple;
pars(6)=TR;

input_file_info.data_name=data_name;
input_file_info.dir_name=dir_name;
input_file_info.loc_name=loc_name;

input_file_info.pars=pars;
input_file_info.subject=snames{subNo};
input_file_info.prtNames=prtNames;
input_file_info.preds2corr=preds2corr;
input_file_info.mpName=mp_name;



input_file_info.testVMP=['Z:\fMRI_bial\ST28\ST28_pp\toolsBIGbars_t2.5.vmp'];


end

