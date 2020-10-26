%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [betas,t]=compute_glm2(data, dm, zTimeSeries,zBetas)


if(zTimeSeries==1)
    data=zscore(data);  %% zscore data, voxel-wise (column wise), crucial 
end

nVox=size(data,2);
nVols=size(data,1);
betas=zeros(size(dm,2),nVox);
t=zeros(size(betas));

% independently for each voxel, fit GLM
for vox=1:nVox
    [B,dev,stats]=glmfit(dm,data(:,vox),'normal','constant','off');
    % no adding of additional column of ones
    betas(:,vox)=B;
    t(:,vox)=stats.t;
end

% zscore betas within each voxel, across trials
if(zBetas)
    betas=zscore(betas);  %% zscore betas, voxel wise
end