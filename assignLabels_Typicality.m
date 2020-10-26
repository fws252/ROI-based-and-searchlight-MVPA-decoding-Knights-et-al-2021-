%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was created by Ethan Knights and Fraser W. Smith.

function out=assignLabels_Typicality(input)

%PRT (for pairs): 
% 1-Knife_Atypical 2-Knife_Typical
% 3-Whisk_Atypical 4-Whisk_Typical
% 5-Pizzacutter_Atypical 6-Pizzacutter_Typical
% 7-Spoon_Atypical 8-Spoon_Typical
% 9-Bar_K_Atypical 10-Bar_K_Typical
% 11-Bar_W_Atypical 12-Bar_W_Typical . 
% 13-Bar_P_Atypical 14-Bar_P_Typical
% 15-Bar_S_Atypical 16-Bar_S_Typical

%decode typicality [Tools]
 pairs=[2 6 8; 1 5 7];  %% NB typical first then atypical
 tmp1=zeros(size(input,1),1);

  for j=1:2
     for i=1:3
        f=find(input(:,1)==pairs(j,i));
        if(j==1)
            tmp1(f)=1;
        else
            tmp1(f)=2;
        end
     end
  end 
 
%decode typicality [Nontools]
 pairs=[10 14 16; 9 13 15];
 tmp2=zeros(size(input,1),1);
 
   for j=1:2
     for i=1:3
        f=find(input(:,1)==pairs(j,i));
        if(j==1)
            tmp2(f)=1;
        else
            tmp2(f)=2;
        end
     end
  end 

stackCM=[tmp1 tmp2 input];
out=stackCM;