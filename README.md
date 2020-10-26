# ROI-based-and-searchlight-MVPA-decoding-Knights-et-al-2020-
Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, FW., Rossit, S. (2020). %Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions. %bioRxiv. doi: 10.1101/2020.10.14.339606

This code performs linear SVM decoding analyses of brain imaging data in voxel space. The code imports fMRi data into MATLAB from BrainVoyager VTC format. It then performs GLM analysis to estimate beta weights per ROI and then trains and tests linear SVM pattern classifiers using leave 1 run out cross-validation (ROI-BASED). The searchlight decoding is performed by interfacing to the Searchmight Toolbox specified below.

Requirements
You need LIBSVM (see https://www.csie.ntu.edu.tw/~cjlin/libsvm/), NEUROELF (https://neuroelf.net/) and Searchmight (http://www.franciscopereira.org/searchmight/; for the searchlight decoding)

Authors
The code was originally created by Fraser W. Smith and was adapted to this project by Ethan Knights and Fraser W Smith.

Main Citation
Knights, E., Mansfield, C., Tonin, D., Saada, J., Smith, FW., Rossit, S. (2020). %Hand-selective visual regions represent how to grasp 3D tools for use: brain decoding during real actions. bioRxiv. doi: 10.1101/2020.10.14.339606

Code Citations
Smith, F.W. & Muckli, L. (2010). Non-Stimulated early visual areas carry information about surrounding conte xt. Proceedings of the National Academy of Sciences USA, 107 (46), 20099-20103.

Smith, F.W., & Goodale, M.A. (2015). Decoding visual object categories in early somatosensory cortex. Cerebral Cortex, 25, 1020-1031. E-PUB 2013.

