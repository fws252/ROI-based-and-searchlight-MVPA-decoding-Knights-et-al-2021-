%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function [outV,maskDims]=prepare_masks_G_v5_fws(subject,fileNames,subSample,nVox)

% function to take tal VOI file and turn it into
% BV mask/vtc system coords
% allows sampling of VTC from predefined ROIS
% FWS 14/9/2010 UWO, mod 17/6/2011

% *** assumes VOIs are in tal space ***

% it also outputs a vmp file of locations which should
% correspond, more or less, to the input locations
% note the mapping will not be exact however
% thanks to the wonders of BV interpolations

%fileNames=getFileInfo3(subject);  %% always =0 here I think???

voi_names=fileNames.loc_name;
dir_name=fileNames.dir_name;
vtc=xff([dir_name char(fileNames.data_name{1})]); % for resolution info
vtc=bless(vtc);

if(subSample)
    vmp=xff([dir_name char(fileNames.vmpNames)]);
    %nVox=1000;  %% typical choice in V1
    retM=1; %% =1 for retinotopy map corr values, =0 for a normal t map
end

nVoiFiles=length(voi_names);
mask=zeros(vtc.BoundingBox.DimXYZ);  %% for checking the solution
maskDims=size(mask);
z=1; report=[];  %% in case out of bounds
nVs=[];

% read in the voi file
in=xff([dir_name voi_names]);  %% standard ROI analysis
in=bless(in);  %% stop it being removed from memory
nVoi=in.NrOfVOIs;


for j=1:nVoi

    if(j<=nVoi)
        name{j}=in.VOI(j).Name;  %% name of voi
        %acpc_coords=in.VOI(j).Voxels;   %% vox coords in tal space
    
        tal_coords=in.VOI(j).Voxels;   %% vox coords in tal space
    end
%     else
%         zkk=1; tal_coords=[];
%         for jj=1:nVoi
%             tmp=(in.VOI(jj).Voxels);
%             tal_coords(zkk:zkk+size(tmp,1)-1,:)=tmp;
%             zkk=zkk+size(tmp,1);
%         end
%         
%     end

    % the normal case
    % convert TAL to BV internal volume coords (ie mask / vtc space)
    
  %%%  [outC] = switchBVint2tal(tal_coords);
  %%%  c = bvcoordconv(outC, 'tal2bvc',vtc.BoundingBox);
    
    c = bvcoordconv(tal_coords, 'tal2bvc',vtc.BoundingBox); 
    
    %Version of ACPC combine with binding box but not happy 
    %rows = size(acpc_coords);
    %bbx = vtc.BoundingBox;
    %minusbbx = bbx.BBox(1,1:3);
    %acpc_coords (1:rows(1),:) 
    %for rowVoi=1:rows
    %   c(rowVoi,1:3) = acpc_coords(rowVoi,1:3)- minusbbx(1:3);
    %end
    %c = acpc_coords
    %c
    %-------------
    
    
    %c = bvcoordconv(acpc_coords, 'acpc2bvc',vtc.BoundingBox); %ACPC Version
    c=round(c);  %% results are not round to begin with; ACPC Version
    
    %c=round(tal_coords); %DEBUG Debug Version no conversion coordinates as they come ACPC Version
    [c,b1,a1]=unique(c,'rows');  %% only unique entries

    voi_coords{j}=c;

    % AND the check procedure
    linInd=[];

    try
        linInd=sub2ind(size(mask),c(:,1),c(:,2),c(:,3));
    catch ME
         % HACK - sometimes a coordinate is out of range
         % cp to BVQXtools vtc_VOITimeCourse.m
        z=z+1;
        report(z,1:2)=[j];

        for jj=1:3  % dims         
            ff=find(c(:,jj)>maskDims(jj) | c(:,jj)<=1);
         if(ff)  
            report(z,3)=jj%;
            report(z,4)=max(c(:,jj));
            report(z,5)=min(c(:,jj));            
            c(ff,:)=[];
         end

        end
         linInd=sub2ind(size(mask),c(:,1),c(:,2),c(:,3));
    end
    
    
    if(subSample) % take only part of region as function of some vmp stats  
        vals=vmp.Map(3).VMPData(linInd);
        
        if(retM==1) % a little more involved
            vals=vals-fix(vals); % extract correlation mag from VMP value, int is lag, dec is corr
        end  
       
        [valsS,indx]=sort(vals,'descend');

        linInd=linInd(indx(1:nVox));
        ch{j}=vmp.Map(3).VMPData(linInd); % store the values for later
        ch{j}=ch{j}-fix(ch{j});
    end

   % pfy=[1:length(linInd)]';
    voi_coords_lin{j}=linInd;%[linInd pfy];  %% faster

    mask(linInd)=mask(linInd)+1;  % update the mask positions

    nVs(j)=length(linInd);  %% nVox per VOI 

    c=[];

end

% add in another procedure to only return unique entires in each layer
% ie layer 1 has no overlap with other layers
% this has been changed for partial faces data where we have V1-V3, then
% EVC (so last ROI is not included here)
voi_coords_lin_unique=[]; list=1:nVoi-1;
for i=1:nVoi % not the last one (the grand overlap)
    
    tmp=voi_coords_lin{i};
    f=find(list~=i);
    
    for j=1:length(f)
        
        tmp2=voi_coords_lin{f(j)};
        tmp=setdiff(tmp,tmp2,'stable'); % find elements in tmp not in tmp2
        
    end
    
    voi_coords_lin_unique{i}=tmp;
    
%     if(i<4)
%         voi_coords_lin_unique2{i}=tmp(1:100,1);
%     end
end

% check its correct
pU1=[]; pU2=[];
for i=1:nVoi
    
    for j=1:nVoi
        
        pU1(i,j)=length(intersect(voi_coords_lin{i},voi_coords_lin{j})); % original
        pU2(i,j)=length(intersect(voi_coords_lin_unique{i},voi_coords_lin_unique{j})); % new
        % pU2 should be a diagonal matrix 
        
    end
end

% add in one extra which pools across all the rest
%voi_coords_lin_unique{nVoi+1}=cat(1,voi_coords_lin_unique{1:nVoi});


% write vmp of voi coordinate positions - these should match VOIs in BVQX
voiN=voi_names(1:end-4);
outname=sprintf('%s.vmp',voiN);
%write_vmp(outname,mask,[1 1 1],2,fileNames);
write_vmp_v2(fileNames,outname,mask,1,0);%DEBUG VERSION WITHOUT WRITE VMP


outV=[];
outV.voi_coords=voi_coords;
outV.voi_coords_lin=voi_coords_lin;
outV.voi_coords_linU=voi_coords_lin_unique;
%outV.voi_coords_linU2=voi_coords_lin_unique2; % only top 100 unique
outV.pS=cat(3,pU1,pU2); % outV.pS(:,:,2) should be a diagonal matrix (corresponding to pU2 above)
outV.voi_names=name;
outV.nVs=nVs;
outV.nVsU=diag(pU2); % n of unique voxels in each layer
outV.subject=subject;
outV.maskDims=maskDims;

if(subSample)
    outV.ch=ch; % stats of vmp sampled voxels
end
