%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function stats=deriveCM_pvals(svm_class,teLabels,nC)

% function stats=deriveCM_pvals(svm_class,test_lbs,nClass)
% FWS 13/9/2011 Centre for Brain & Mind, UWO
% if you use this code for analysis - please cite Smith & Muckli 2010 PNAS
% Non-stimulated early visual areas carry information about surrounding context
% PNAS, 107 (46) 20099-20103. 

nRuns=size(svm_class,2);
nTrialsPerRun=size(svm_class,1);
nObs=numel(svm_class);
uL=unique(teLabels(:));

% build confusion matrix
cm=zeros(nC,nC,nRuns);
nCorrR=zeros(nRuns,1);
for r=1:nRuns
    
    for i=1:nC
        
        f=find(teLabels(:,r)==uL(i));  %% find index
        
        for j=1:nC
            
            cm(i,j,r)=length(find(svm_class(f,r)==uL(j)));
        end
        
    end
    
    nCorrR(r)=length(find(teLabels(:,r)==svm_class(:,r)));
end

nCorrR=nCorrR./nTrialsPerRun;  %% by run, accuracy

cmS=sum(cm,3);
nCorr=trace(cmS);  %% diagonal

% check
ch=length(find(teLabels==svm_class)) ./ (nObs);
if(ch~=nCorr/nObs)
    error('Result computation error');
end

% one-sided binomial test
pBi(1)=1 - binocdf(nCorr-1,nObs,1/nC); % cdf gives prob of gettin val = to X or less
pBi(2)=1 - (binocdf(nCorr,nObs,1/nC)-binopdf(nCorr, nObs, 1/nC));  %% as in Pereira code

% one-sided t-test - across runs
[H,pT,ci,Tstats]=ttest(nCorrR,1/nC,.05,'right');

stats=[];
stats.cm=cm; % confusion matrix per XV fold
stats.cmS=cmS;  % confusion matrix summed across XV folds
stats.CorrRun=nCorrR;  % correct perf per run
stats.bi=[nCorr nObs 1/nC pBi];  %% binomial test
stats.t=[Tstats.tstat Tstats.df pT Tstats.sd];  %% t test across runs


