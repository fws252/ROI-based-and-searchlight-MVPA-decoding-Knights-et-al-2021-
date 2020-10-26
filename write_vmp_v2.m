%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

function write_vmp_v2(fileNames,outname,data,scale,lThresh)

test=xff([fileNames.testVMP]);% DEBUG MASK INSTEAD

fixBbox=1;

test.Map.Name=outname(1:end-4);
test.Map.LowerThreshold=lThresh;
nMap=size(data,4)
size(test.Map.VMPData)
size(data)

if(nMap==1)
    if(size(data)==size(test.Map.VMPData))
        test.Map.VMPData=single(data.*scale);
    else
        error('Data to be written not in right space');
    end
else
    
    test.NrOfMaps=nMap;
    test.Map(2:nMap)=test.Map(1);
    
    for i=1:nMap
        if(size(data(:,:,:,i))==size(test.Map(i).VMPData))
            test.Map(i).VMPData=single(data(:,:,:,i).*scale);  
            fprintf('Max %.4f\t Min %.4f\n',max(test.Map(i).VMPData(find(test.Map(i).VMPData))),min(test.Map(i).VMPData(find(test.Map(i).VMPData))));
        else
            error('Data to be written not in right space');
        end
    end
    
end



if(fixBbox)
    
    % this makes the mask display identically to one created in BVQX
    % check testVOImap.m for tests of these issues
    test.XStart=test.XStart-1;
    test.YStart=test.YStart-1;
    test.ZStart=test.ZStart-1;

    test.XEnd=test.XEnd-1;
    test.YEnd=test.YEnd-1;
    test.ZEnd=test.ZEnd-1;
end

test.SaveAs(outname);

% make gray scale??
% test.Map.RGBLowerThreshPos= [0 0 0];
% test.Map.RGBUpperThreshPos= [255 255 255];