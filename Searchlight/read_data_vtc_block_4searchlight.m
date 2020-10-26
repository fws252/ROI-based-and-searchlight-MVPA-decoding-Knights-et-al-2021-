%The experiment code that was used in: Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020). 
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions. bioRxiv. doi: 10.1101/2020.10.14.339606
%The code was originally created by Fraser W. Smith (see Smith & Goodale 2015 Cerebral Cortex, eprint 2013) 
% and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [outD]=read_data_vtc_block_4searchlight(subNo,addMotionPredictors)

% function to read a series of VTCs and corresponding SDMs
% and extract average of relevant volumes for classification
% VTCs are masked with GLM .001 mask to delineate brain tissue
% also finds associated trial information (labels)

% modified from read_data_mtc_poi.m
% FWS 9/7/10
fileNames=getFileInfo3(subNo);  %% getFileInfo


zBetas=0;           %% z score betas AFTER GLM prior to classifier analyses

zTimeSeries=1;      %% this is critical - if zTimeSeries==1, then betas should
% be comparable to those computed by BV with zNorm on,
% otherwise betas are highly correlated but on diff scale

% load in BV toolbox

addpath(genpath('/gpfs/home/wyq12enu/NeuroElf_v10_5153/NeuroElf_v10_5153'));


% sort file names from input
dirName=fileNames.dir_name;
%mskName=fileNames.msk_name{1};
vtcName=fileNames.data_name;
%dmName=fileNames.dm_name;
p=fileNames.pars;  %% nClass and nVols
subject=fileNames.subject;
%condLocs=fileNames.cond_locs;
prtNames=fileNames.prtNames;
mpNames=fileNames.mpName;


% some parameters
nRuns=length(vtcName);
nVols=p(1);
nPreds=p(2)+1;
nTrials=p(3);
nPerRun=p(4);
nPredsSimple=p(5);
TR=p(6);

% load in msk FILE
msk=load('toolstudy1_19subs_commonMaskFile.mat');
%% find common across all subject
locsV=find(msk.sMask2); %% location of brain voxels

nVox=length(locsV);

% define matrices
vtcData=zeros(nVols,nVox,nRuns);
DM=[];
cCodes=[];
betas2=zeros(nPreds-1,nVox,nRuns);  %% minus one for mean confound
tvals2=zeros(size(betas2));


% main loop
for r=1:nRuns
    
    % load in VTC DATA
    
    main=xff([dirName vtcName{r}]);
    
    for i=1:nVols
        tmp=[];
        tmp=squeeze(main.VTCData(i,:,:,:));  %% one volume all voxels
        vtcData(i,:,r)=tmp(locsV);
    end
    
    main.ClearObject;
    
    if(length(find(vtcData(:,:,r)==0))>0)
        error('Zeros in vtc data: requires further thought!');
    end
    prtNames=fileNames.prtNames;
    
    
    prt1=xff([prtNames{r}]);
    
    
    prt1.ConvertToSingleTrial;
    params.nvol=nVols;
    params.prtr=TR;
    params.rcond=[1:18];
    
    
    sdm=bless(prt1.CreateSDM(params));
    
    DM(:,:,r)=sdm.SDMMatrix;
    
    if(addMotionPredictors)
        mp=xff([dirName mpNames{r}]);
        DM2(:,:,r)=[DM(:,:,r) mp.SDMMatrix]; % zscore(mp.SDMMatrix)
    end
    
    if(size(DM,1)~=size(vtcData,1))
        error(sprintf('Design Matrix and %s data volume number does not match',snames{typeS}));
    end
    
    % PERFORM GLM COMPUTATION - SINGLE TRIAL / BLOCK COMPUTATION
    % glm performed single trial / block, not deconvolved (can't be)
    % importantly I am zscoring the timeseries here before running GLM
    % in order to obtain comparable values to BV output
    if(addMotionPredictors)
        [out,out2]=compute_glm2(vtcData(:,:,r), DM2(:,:,r), zTimeSeries,zBetas);
    else
        % if(useBetas)
        [out,out2]=compute_glm2(vtcData(:,:,r), DM(:,:,r), zTimeSeries,zBetas);
        %else
        %   [out]=computeBlockAverage(Data(:,:,r),prtNames{r});
        %end
    end
    
    
    betas(:,:,r)=out(1:nPreds-1,:);  %% remove last beta, mean confound
    tvals(:,:,r)=out2(1:nPreds-1,:);  %% t values
    
    
    
    fprintf('Computed Run %d\n', r);
    
end   %% end loop across runs


nMPreds=nPreds-1;
[nBetas,nVoxB,nRunsB]=size(betas);
stackD=zeros((nMPreds)*nRuns,nVoxB);
stackCM=zeros((nMPreds) *nRuns, 2);

seq=[1:16]';


k=1; l=nMPreds; av=[];
for r=1:nRunsB
    
    % stack data and condition codes
    stackB(k:l,:)=betas(1:nMPreds,:,r);
    stackCM(k:l,1:2)=[seq r*ones(nMPreds,1)];
    k=k+nMPreds; l=l+nMPreds;
end


% % %PUT IN NICE STRUCTURES for OUTPUTTING
p(1)=nTrials;
p(2)=length(fileNames.preds2corr);
p(3)=nPerRun;
p(4)=nVox;
p(5)=nRuns;
p(6)=nVols;

s=cell(1,4);
s{1,1}=subject;
s{1,2}=dirName;         %% where to save any output files
s{1,3}=p;               %% useful parameters
s{1,4}=locsV;           %% all verts in POI
s{1,5}=fileNames;

outD=[];
outD.stackB=stackB;
outD.stackCM=stackCM;
outD.S=s;


save(sprintf('%s_toolstudy1_SingleBlockRespEstBetas_Searchlight.mat',subject),'outD');


