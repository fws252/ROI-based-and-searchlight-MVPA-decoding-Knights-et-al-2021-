%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [labelsN1,labelsN2]=matchLabels(labels1,labels2)

nC(1)=length(unique(labels1));  % number of classes
nC(2)=length(unique(labels2));
ulabel1=unique(labels1); %% the actual labels
ulabel2=unique(labels2);
labelsN1=zeros(size(labels1)); labelsN2=zeros(size(labels2));

    for i=1:3
        f=find(labels1==ulabel1(i));
        labelsN1(f)=i;

        f2=find(labels2==ulabel2(i));
        labelsN2(f2)=i;

    end

end

