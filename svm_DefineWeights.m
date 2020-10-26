%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

[weights]=svm_DefineWeights(model)

% a helper function to take an svm model from LIBSVM
% and define the weights for each pairwise classification pbm
% since LIBSVM is doing multiple classification by 1 VS 1 approach
% FWS 3/9/09 --- see email from Chih Jen Lin (LIBSVM)
% checked - see check svmDefineWeights.m - 7/9/09

% only works for three class problems right now

nLabels=3;  % only for 3 classes at the moment
contrasts=nchoosek(1:nLabels, 2);
% this has the correct order - 1 Vs 2, 1 Vs 3, 2 Vs 3
nContrasts=size(contrasts,1);
weights=zeros(size(model.SVs,2),nContrasts);


for i=1:nContrasts
    
    %tmp=model.nSV;  % find number of SVs for each class
    
    if(i==1) %% then contrast is 1 Vs 2
        
        coef=[model.sv_coef(1:model.nSV(1),1); model.sv_coef(model.nSV(1)+1:model.nSV(1)+model.nSV(2),1)];
        SVs=[model.SVs(1:model.nSV(1),:); model.SVs(model.nSV(1)+1:model.nSV(1)+model.nSV(2),:)];
   
    elseif(i==2)   %% contrast is 1 Vs 3
        
        coef=[model.sv_coef(1:model.nSV(1),2); model.sv_coef(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),1)];
        SVs=[model.SVs(1:model.nSV(1),:); model.SVs(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),:)];

    elseif(i==3)      %% contrast is 2 Vs 3
        
        coef=[model.sv_coef(model.nSV(1)+1:model.nSV(1)+model.nSV(2),2); model.sv_coef(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),2)];
        SVs=[model.SVs(model.nSV(1)+1:model.nSV(1)+model.nSV(2),:); model.SVs(model.nSV(1)+model.nSV(2)+1:sum(model.nSV),:)];

    end
    
    %sum(coef~=0)
    w = SVs'*coef;   %% the weights!!!;
    
    weights(:,i)=w;
    
    
end