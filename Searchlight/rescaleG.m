%The experiment code that was used in: Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, F., & Rossit, S. (2020). 
%Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions. bioRxiv. doi: 10.1101/2020.10.14.339606
%The code was originally created by Fraser W. Smith (see Smith & Goodale 2015 Cerebral Cortex, eprint 2013) 
% and was adapted to this project by Ethan Knights and Fraser W. Smith.

function out=rescaleG(x,b)

%%% rescale entries to see easier in BVQX
%%% as Rainer does (see BV blog - between 0 and 10 here)
%%EK - RescaleG (rather than RescaleW) is for when max value doesnt reach
%%100%. This does not hppen if classifications arent fairly easy.
a=0;
%b=10;

k=sign(x);
x2=abs(x);

m = min(x2(:)); M = max(x2(:));
xR = (b-a) * (x2-m)/(M-m) + a;

max(xR)
min(xR)

out=xR.*k;