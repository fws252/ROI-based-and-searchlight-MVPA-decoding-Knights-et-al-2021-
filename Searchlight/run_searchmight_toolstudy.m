%The experiment code that was used in: Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020). 
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions. bioRxiv. doi: 10.1101/2020.10.14.339606
%The code was originally created by Fraser W. Smith (see Smith & Goodale 2015 Cerebral Cortex, eprint 2013) 
% and was adapted to this project by Ethan Knights and Fraser W. Smith.

subs={'CR09','DT12','JM15','JR24','KH02','KL04','LB28','LP12','MC17','MK14','QP18','QR30','RE29','RL17','RS06','SC13','ST28','TS12','VB04'};

addMotionPredictors=1;

decodeVersion=1; %% Which classifications recode (1=Typicality, 2=Size)

nSubs=length(subs);
vs=[]; ams=[]; pms=[];



% set searchmight paths and check
addpath('/gpfs/home/wyq12enu/SearchmightToolbox.Linux_x86_64.0.2.5');
addpath('/gpfs/home/wyq12enu/SearchmightToolbox.Linux_x86_64.0.2.5/CoreToolbox/ExternalPackages.Linux_x86_64/libsvm');
checkExternalPackages

% since same for each subject - to save recomputing each time
rr=3; %% radius
load toolstudy1_19subs_commonMaskFile.mat;

mask = sMask2;
% [meta] = createMetaFromMask( mask,rr );
if(~exist(sprintf('Tvis_Meta_radius%d.mat',rr)))
    [meta] = createMetaFromMask( mask,rr ); % use common mask across subs
    save(sprintf('Tvis_Meta_radius%d.mat',rr),'meta');
else
    load(sprintf('Tvis_Meta_radius%d.mat',rr));
end



for s=1:nSubs
    
    %     % get data from each subject-in right space for searchlight etc
    %     [outD]=read_data_vtc_block_4searchlight(subs{s},0); %run once!
    
    subject=subs{s}
    in=load(sprintf('%s_toolstudy1_SingleBlockRespEstBetas_Searchlight.mat',subject));
    
    examples=in.outD.stackB;
    
    
    if decodeVersion == 1;
        stackCM=assignLabels_Typicality(in.outD.stackCM); %for function addpath(ROIMVPA)!
        nToDecode = 2;
    elseif decodeVersion == 2;
        stackCM=assignLabels_Size(in.outD.stackCM); %for function addpath(ROIMVPA)!
        nToDecode = 3;
    end
    
    
    for decode=1:nToDecode
        
        nPairs=1;
        
        
        locs=outD.stackCM(:,decode)==1 | outD.stackCM(:,decode)==2;
        
        labels=stackCM(locs,decode);
        
        examples=examples(locs,:);
        
        runLabels=stackCM(locs,end);
        
        
        ams=[];
        pms=[];
        

        for c=3  % classifier
            
            if(c==1)
                classifier = 'gnb_searchmight'; % fast GNB
            elseif(c==2)
                classifier= 'lda_shrinkage';
            elseif(c==3)
                classifier= 'svm_linear';
            end
            
 
            [am,pm] = computeInformationMap(examples,labels,runLabels,classifier,'searchlight', ...
                meta.voxelsToNeighbours,meta.numberOfNeighbours);

            % place the accuracy map in a 3D volume using the meta structure
            %volume = repmat(NaN,meta.dimensions);
            volume = zeros(meta.dimensions);
            volume(meta.indicesIn3D) = am;
            
            outname=sprintf('%s_toolstudy1_SearchLight%d_decode%d.mat',subject,rr,decode);
            parsave2(outname,am,pm,volume);
            
            %plot proper
            %for iz=1:2:46; figure, imagesc(volume(:,:,iz),[1/7 0.3]); end
            
            % collect these
            vs(:,:,:,s)=volume;
            
            % store results
            ams(:,s)=am;
            pms(:,s)=pm;
        end
        
        
    end
end




return;

