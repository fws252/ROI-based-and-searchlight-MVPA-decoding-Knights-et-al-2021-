%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function  [out]=computeBlockAverage(data, prtName)

% this function will compute simple average of on blocks as pattern
% estimates for comparison with Beta weight method

% assumes a TR of 2s at present...


prt=bless(xff(prtName));

nCond=prt.NrOfConditions; %minus baseline/fixation


data2=data-repmat(mean(data),size(data,1),1); %% remove voxelwise mean
% see Smith & Goodale 2015; Kamitani & Tong, 2006

out=[]; z=1;
for i=2:nCond
  
   tw=prt.Cond(i).OnOffsets + 2;  % +2 for 4s delay BOLD resp
   
   for j=1:length(tw) % n trials per cond 
       out(z,:)=mean(data2(tw(j,1):tw(j,2),:));
       z=z+1;
   end
    
    
end


end

