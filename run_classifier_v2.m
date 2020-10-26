%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [out]=run_classifier_v2(stackD, labelV, runV,normFlag, perm)

% function [stats_svm, stats_svmAv, pc]=run_classifier(data, labels, runLabels)
% FWS 08/06/2012 CCNI GLASGOW UNIVERSITY
% if you use this code for analysis - please cite Smith & Muckli 2010 PNAS
% Non-stimulated early visual areas carry information about surrounding context
% PNAS, 107 (46) 20099-20103.

% data should be nTrials OR nBlocks (rows) by nVoxels (cols)
% labels should be nTrials OR nBlocks by 1
% XV labels should be same as labels (coding cross-validation sets, usually
% RUNS or leave one trial of each set out)

% further developed -v2 - 30/11/12 CCNi Glasgow --- to re-incorportate
% permutation test option (takes around 23 secs to do 1000 iterations)
% code will then estimate observed performance, and a permutation distribution
% for both single trials and average decoding, as well as p values
% and corresponding empirical chance levels

% use tie correction procedure - better confusion matrix estimation
% useTieCorr=1;
% if(useTieCorr)
%    [labelV,runV,stackD]=sortL(labelV,runV,stackD); % reorder labels 1:nClasses for tie correction
% end

% add svm to path
%addpath(genpath('')); % SVM toolbox

% find number of trials / voxels
[nT,nV]=size(stackD);

% find number of classes / trials per class
nC=length(unique(labelV));  % number of classes
ulabel=unique(labelV); %% the actual labels
tCount=histc(labelV,ulabel(1:nC));

% find nRuns
nR=length(unique(runV));
runs=unique(runV);  % look into here, one run seems missing - independent selection of features (voxels)
rCount=histc(runV, 1:nR); 


nIts=1;


for xx=1:nIts  %% permutation loop

    gnb_class=[]; svm_class=[];
    % which XV to use - leave one run out
    for i=1:nR


        r=runs(i);  % a little switch
        % r is run to be held out for testing this cycle

        % define XV indices
        teIndx=find(runV==r); % test index
        trIndx=find(runV~=r); % train index


        % define train/test data
        train=stackD(trIndx,:);
        test=stackD(teIndx,:);

        % define train / test labels
        teLabels(:,i)=labelV(teIndx);
        trLabels=labelV(trIndx);

        %---------------% run gnb classifier -- don't need explicit
        %normalization here - it is implicit in the definition
        [gnb_class(:,i),err,post,logp,coef]=classify(test,train,trLabels,'diagLinear');

        %---------------% run SVM classifier 
        [train,test]=svm_scale_data_mvpaC(train, test, normFlag);  % put each voxel in 1 to -1 range

        % train SVM
        svm_model=svmtrain(trLabels, train,'-t 0 -c 1');    % -t 0 = linear SVM, -c 1 = cost value of 1

        % test SVM
        [svm_class(:,i),accuracy,dec]=svmpredict(teLabels(:,i),test,svm_model);
        
        % test SVM on average patterns in independent test data
        for ii=1:nC
            avL=find(teLabels(:,i)==ulabel(ii));
            avT(ii,:)=mean(test(avL,:));  %% mean across test trials per condition
        end
        [svm_classAv(:,i),acc2,dec2]=svmpredict(ulabel,avT,svm_model);
        

    %     %---------------% compute performance
         pc(i,1)=length(find(gnb_class(:,i)==teLabels(:,i))) / length(teLabels(:,i));
         pc(i,2)=length(find(svm_class(:,i)==teLabels(:,i))) / length(teLabels(:,i));
         pc(i,3)=length(find(svm_classAv(:,i)==ulabel)) / length(ulabel);
         

    end

    % make nice stats structure
    stats_svm=deriveCM_pvals(svm_class,teLabels,nC); % this is the important one
    stats_svmAv=deriveCM_pvals(svm_classAv, repmat(ulabel,1, nR), nC);

end  


out.stats_svm=stats_svm;
out.stats_svmAv=stats_svmAv;
out.pc=pc;

