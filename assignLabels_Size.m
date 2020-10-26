%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was created by Ethan Knights and Fraser W. Smith.

function out=assignLabels_Size(input)

%PRT (for pairs): 
% 1-Knife_Atypical 2-Knife_Typical
% 3-Whisk_Atypical 4-Whisk_Typical
% 5-Pizzacutter_Atypical 6-Pizzacutter_Typical
% 7-Spoon_Atypical 8-Spoon_Typical
% 9-Bar_K_Atypical 10-Bar_K_Typical
% 11-Bar_W_Atypical 12-Bar_W_Typical 
% 13-Bar_P_Atypical 14-Bar_P_Typical
% 15-Bar_S_Atypical 16-Bar_S_Typical



%decode Size + Atypical [Average across exemplars (Pizzac,Spoon,Knife) classifications]
%Controlling for reach direction too


%decode Size
%Pizzac/PizzacBar vs. Spoon/SpoonBar [Large vs. Med]
pairs =[5 13; 7 15];
tmp1=zeros(size(input,1),1);

 for j=1:2
     for i=1:2
        f=find(input(:,1)==pairs(j,i));
        if(j==1)
            tmp1(f)=1;
        else
            tmp1(f)=2;
        end
     end
 end
 
%decode Size
%Pizzac/PizzacBar vs. Knife/KnifeBar [Large vs. Small]
pairs =[5 13; 1 9];
tmp2=zeros(size(input,1),1);

 for j=1:2
     for i=1:2
        f=find(input(:,1)==pairs(j,i));
        if(j==1)
            tmp2(f)=1;
        else
            tmp2(f)=2;
        end
     end
 end
 
 
%decode Size
%Spoon/SpoonBar vs. Knife/KnifeBar [Med vs. Small]
pairs =[7 15; 1 9];
tmp3=zeros(size(input,1),1);

 for j=1:2
     for i=1:2
        f=find(input(:,1)==pairs(j,i));
        if(j==1)
            tmp3(f)=1;
        else
            tmp3(f)=2;
        end
     end
 end


stackCM=[tmp1 tmp2 tmp3 input];
out=stackCM;

