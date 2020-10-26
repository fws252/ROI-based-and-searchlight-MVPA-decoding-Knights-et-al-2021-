%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [train,test]=svm_scale_data_mvpaC(train, test, flag)

% FWS 13/9/2011 Centre for Brain & Mind, UWO
% if you use this code for analysis - please cite Smith & Muckli 2010 PNAS
% Non-stimulated early visual areas carry information about surrounding context
% PNAS, 107 (46) 20099-20103. 

% to take in data and normalize it for SVM classification

% flag = 1, then normalize voxels (colums) of training, use same pars for
%           to normalize test data (-1 to 1)
% flag = 2, then normalize each pattern itself (mean zero, sd =1)
% flag = 3, normalize voxels (mean zero, sd 1) on train, use same pars for
% test

% FWS UWO 12/9/11

[a,b]=size(train);


if(flag==1)
%     [train, pars]=stretch_cols_ind(train, -1,1); % put training data on -1 to 1 scale
%     [test]=stretchWithGivenPars(test,[-1 1],pars);  %% put test data on the same scale
%     % see libSVM guide for SVM
%     
%     % check
%     if(length(find(max(train)==1))==b && length(find(min(train)==-1))==b)
%         % ok
%     else
%         error('SVM -1 +1 normalization error');
%     end
    outTr=zeros(size(train));
    outTe=zeros(size(test));
    
    for i=1:size(train,2)
        
        tmp=train(:,i);
        p(i,1)=min(tmp);
        p(i,2)=max(tmp);
        h=(tmp-p(i,1))./(p(i,2)-p(i,1)); % put 0 -1
        h=h.*2 - 1; %% put on -1 to 1 scale
        
        outTr(:,i)=h;    % tr data -1 to 1

        tmp2=test(:,i);  
        h2=(tmp2-p(i,1))./(p(i,2)-p(i,1)); % put 0 -1
        h2=h2.*2 - 1;
        
        outTe(:,i)=h2;   % te data -1 to 1

    end

    train=outTr;
    test=outTe;
    

        
elseif(flag==2)
    % zscore across features. ie per example (to have mean zero, sd 1)
    % ie remove any univariate effects
    %train=zscore(train,[],2);
    %test=zscore(test,[],2); 
    train=zscore(train')';
    test=zscore(test')';
elseif(flag==3)
    % z score by features
    m=mean(train);  %% feature means
    s=std(train);  %% feature SDs
    m2=repmat(m,size(train,1),1);
    s2=repmat(s,size(train,1),1);
    m3=repmat(m,size(test,1),1);
    s3=repmat(s,size(test,1),1);
    
    train=(train-m2)./s2;   %% z score training matrix
    test=(test-m3)./s3;  %% z scored by train parameters
    
end

