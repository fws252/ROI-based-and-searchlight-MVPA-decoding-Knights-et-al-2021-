%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.
%
%Purpose:
%Top script to run ROI MVPA

clear;
nSubs=1;
%voiNo=1;  %% for the first region
decodeVersion=1;  %% Which classifications recode (1=Typicality, 2=Size)

voxSize=zeros(nSubs,1);
subSample=0; nVox=0; % subsample V1 vox, e.g. top100 (from ret map corr values)
perm=0; % randomization analyses (good to check empirical chance levels correct)
addMotionPredictors=1; %% include motion predictors in GLM or not (1=include, 0=do not include)
useBetas=1; % if adding motion predictors this must be 1, if not adding motion predictors can be 1 (as our original code), or can be 0 in which
% case it just uses the raw data suitably normalized (as in Smith &
% Goodale, 2015, CC) - NB this not working yet

doUnique=0; %% set to 1 for top100 unique voxels V1-V3 only (won't work for EVC 1000 or V1 1000 as is, for them use doUnique=0 - old style)

addpath(genpath('Z:\fMRI_bial\Toolboxes\NeuroElf_v09c\NeuroElf_v09c'));

pc_sb=[];
pc_av=[];
cm=[];
rdm=[];

for sub=1:19
    
    flag=1; % svm data normalization    
    
    [x]=getFileInfo3(sub);
    voi=xff([x.dir_name x.loc_name]);
    nVoi=voi.NrOfVOIs;
    
    
    for voi_indx=1:nVoi
        
        % just call this function once per VOI now
        clear outD; % from previous iteration
        [outD]=read_data_v4(sub,voi_indx,subSample,nVox,doUnique,addMotionPredictors,useBetas);
        
        if decodeVersion == 1;
            stackCM=assignLabels_Typicality(outD.stackCM);
            nToDecode = 2;
        elseif decodeVersion == 2;
            stackCM=assignLabels_Size(outD.stackCM);
            nToDecode = 3;
        end
        
        outD.stackCM=stackCM;
        
        
        for decode= 1:nToDecode
            
            nPairs=1; %2 AF
            
            voxSize(sub,1)=size(outD.stackB,2);
            
            for i=1:nPairs
                
                
                locs=outD.stackCM(:,decode)==1 | outD.stackCM(:,decode)==2;
                
                data=outD.stackB(locs,:);
                
                labels=stackCM(locs,decode);
                
                [svmOut]=run_classifier_v2(data, labels, XVlabels,flag,perm);
                
                cN=size(svmOut.pc,1);
                pc_sb(voi_indx,decode,sub)=mean(svmOut.pc(:,2));  %% single trials
                pc_av(voi_indx,decode,sub)=mean(svmOut.pc(:,3));  %% average
                
                fN=max(labels);
                
                pc_sb2(i,1:cN,voi_indx,decode,sub)=svmOut.pc(:,2)';  %% single trials
                pc_av2(i,1:cN,voi_indx,decode,sub)=svmOut.pc(:,3)';  %% average
                
                
                
                chanceLev=[];
                
                
            end  % end npairs to decode
            
        end % decode
    end  %% voi_indx
    
    names=outD.voi.voi_names';
    outname=sprintf('3D_ToolStudy_sub%d_MVPA_addMotion%d_useBetas%d_decodeVersion%d_LOCALISERONLY.mat',sub,addMotionPredictors,useBetas, decodeVersion);
    
    save(outname,'pc_sb2','pc_av2','pc_sb','pc_av','cm','rdms','names');
    
end
