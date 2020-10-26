%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [outD]=read_data_v4(sub,indx,subSample,nVox,doUnique,addMotionPredictors,useBetas)



fileNames=getFileInfo3(sub);  %% getFileInfo


zBetas=0;       % zscore betas after GLM voxelwise

zTimeSeries=1;      %% this is critical - if zTimeSeries==1, then betas should
% be comparable to those computed by BV with zNorm on
% (correct to 2 decimal places)
% otherwise betas are highly correlated but on diff scale


% load in BV toolbox
%addpath(genpath(''));


% sort file names from input
dirName=fileNames.dir_name;
locName=fileNames.loc_name;
dataName=fileNames.data_name; % mtc or vtc files
p=fileNames.pars;  %% nClass and nVols
subject=fileNames.subject;
prtNames=fileNames.prtNames;
mpNames=fileNames.mpName;


% some parameters
nRuns=length(dataName);
nVols=p(1);
nPreds=p(2)+1;
nTrials=p(3);
nPerRun=p(4);
nPredsSimple=p(5);
TR=p(6);

typeS=2;


% load in Voi file
voi=xff([dirName locName]);
nVoi=voi.NrOfVOIs;%-----------------


[outV,maskDims]=prepare_masks_G_v5_fws(subject,fileNames,subSample,nVox)
%   locsV=outV.voi_coords_lin{indx};

if(doUnique)
    locsV=outV.voi_coords_linU2{indx};  %% V1-V3 only, 100 top in each, unique voxels
else
    locsV=outV.voi_coords_lin{indx};% do one at a time
end

nV=length(locsV); % nVox or nVerts
Data=zeros(nVols,nV,nRuns);
DM=zeros(nVols,nPreds,nRuns);
if(addMotionPredictors)
    DM2=zeros(nVols,nPreds+6,nRuns);
end
%DMnew=zeros(nVols,nPreds,nRuns);
betas=zeros(nPreds-1,nV,nRuns);  %% minus one for mean confound
%betas=zeros(nPreds,nV,nRuns);  %% minus one for mean confound
tvals=zeros(size(betas));
snames{1}='mtc'; snames{2}='vtc';

% main loop
for r=1:nRuns
    
    fprintf('Processing Run: %d\n', r);
    
    main=xff([dirName dataName{r}]);

    for i=1:nVols   %% get timecourse from voxels vtc
        tmp=[];
        tmp=squeeze(main.VTCData(i,:,:,:));  %% one volume all voxels
        Data(i,:,r)=tmp(locsV);
    end
    
    
    % load in DESIGN MATRIX file
    prt1=xff([prtNames{r}]);
    
    prt1.ConvertToSingleTrial;
    params.nvol=nVols; % need to set both parameters nvol and prtr
    params.prtr=TR;
    params.rcond=[1:18]; % these are fixation periods
    
    
    sdm=bless(prt1.CreateSDM(params));
    
    DM(:,:,r)=sdm.SDMMatrix;
    
    if(addMotionPredictors)
        mp=xff([dirName mpNames{r}]);
        DM2(:,:,r)=[DM(:,:,r) mp.SDMMatrix]; % zscore(mp.SDMMatrix)
    end
    
    if(size(DM,1)~=size(Data,1))
        error(sprintf('Design Matrix and %s data volume number does not match',snames{typeS}));
    end
    
    
    
    % PERFORM GLM COMPUTATION - SINGLE TRIAL / BLOCK COMPUTATION
    %    ----- GLM   -----
    
    
    % glm performed single trial / block, not deconvolved (can't be)
    % importantly I am zscoring the timeseries here before running GLM
    % in order to obtain comparable values to BV output
    if(addMotionPredictors)
        [out,out2]=compute_glm2(Data(:,:,r), DM2(:,:,r), zTimeSeries,zBetas);
    else
        if(useBetas)
            [out,out2]=compute_glm2(Data(:,:,r), DM(:,:,r), zTimeSeries,zBetas);
        else
            [out]=computeBlockAverage(Data(:,:,r),prtNames{r});
        end
    end
    
    if(useBetas)
        betas(:,:,r)=out(1:nPreds-1,:);  %% remove last beta, mean confound
        tvals(:,:,r)=out2(1:nPreds-1,:);  %% t values
    else
        % just use raw BOLD data, normalized by the mean
        betas(:,:,r)=out;
    end
    
end   %% end loop across runs

% post processing
% added in (6/9/11) to remove any voxels where mean BOLD signal change is < 100
% for comparability to BVQX main program method (applies to VTC data only at present)
pz=[];
for r=1:size(Data,3)
    for j=1:size(Data,2)
        pz(j,r)=mean(Data(:,j,r));
    end
end

% find those under 100 and concatenate across runs
py=[]; list=[];
for r=1:size(Data,3)
    py{r}=find(pz(:,r)<=100);
    
    if(~isempty(py{r}))
        list=[list py{r}'];
    end
end
list=unique(list);

nVoxDat=[];
% remove those voxels
if(~isempty(list))
    betas(:,list,:)=[];
    tvals(:,list,:)=[];
    nV=size(betas,2);
    Data2=Data;
    Data(:,list,:)=[];
    
    % update locs
    locsV(list)=[];
    
    % write new updated mask  -for the purists- a few voxels out
    mask=zeros(main.BoundingBox.DimXYZ);
    mask(locsV)=1;
    outname=sprintf('%s_updated%i_%i.vmp',fileNames.subject,indx,nV);
    %    write_vmp_v2(fileNames,outname,mask,1,0);
    nVoxDat=nV;
end
%layerSize{i} = size(locsV(list),1)
end


% GET THE DESIGN SEQUENCE AND PARSE BETAS CONDITION-WISE
% FWS change this to the modern style which is easier to understand and run
% etc --- and then write a simple run classifier func

nMPreds=nPreds-1;
[nBetas,nVoxB,nRunsB]=size(betas);
stackD=zeros((nMPreds)*nRuns,nVoxB);
stackCM=zeros((nMPreds) *nRuns, 2);

seq=[1:16]';

k=1; l=nMPreds; av=[];
for r=1:nRunsB
    % stack data and condition codes
    stackD(k:l,:)=betas(1:nMPreds,:,r);
    stackCM(k:l,1:2)=[seq r*ones(nMPreds,1)];
    k=k+nMPreds; l=l+nMPreds;
end

%PUT IN NICE STRUCTURES for OUTPUTTING
p(1)=nTrials;
p(2)=length(fileNames.preds2corr);
p(3)=nPerRun;
p(4)=nV;
p(5)=nRuns;
p(6)=nVols;

s=cell(1,4);
s{1,1}=subject;
s{1,2}=dirName;         %% where to save any output files
s{1,3}=p;               %% useful parameters
s{1,4}=locsV;           %% all verts in POI / voxels in voi
s{1,5}=fileNames;


outD=[];
outD.stackB=stackD;     %% betas stacked -this way very easy to do classification
outD.stackCM=stackCM;   %% code matrix (conditions, runs) labelling

outD.DM=DM;             %% design matrices
outD.S=s;               %% useful parameters
outD.p=p;
outD.voi=outV;


