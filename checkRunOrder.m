%The analysis code that was used in:
%Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020).
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions.
%bioRxiv. doi: 10.1101/2020.10.14.339606
%
%The code was originally created by Fraser W. Smith (see Smith & Muckli 2010 PNAS)
%and was adapted to this project by Ethan Knights and Fraser W. Smith.

% view
[x]=getFileInfo3('BM30',1);
% the order of the runs here MUST match
x.prtNames'
x.data_name'
x.cond_locs'

% pantomime
[x]=getFileInfo3('BM30',2);

% the order of the runs here MUST match
x.prtNames'
x.data_name'
x.cond_locs'