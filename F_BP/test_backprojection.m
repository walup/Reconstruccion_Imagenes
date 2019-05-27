%Test for our methods 

%% 
backprojector = Backprojector2();
sinogram = radon(phantom(256));
backprojector = backprojector.setSinogram(sinogram,Filter.RAMP,pi);
%% Debug the transform phase
tr = backprojector.getFourierTransform();

%% Debug the filter phase
filtered = backprojector.filterProjections(tr);

%% Test the inverse transform
inverseFilt = backprojector.inverseFourier(filtered);

%% backproject
backprojector = backprojector.backprojection();
img = backprojector.img;
imagesc(img),colormap gray

%% it works, now let's try the filters
backprojector = backprojector.setSinogram(m,Filter.RAMP,2*pi);
imgHamming = backprojector.backprojection();
figure(2);
imagesc(imgHamming),colormap gray

%%
imagesc(iradon(m,1:3:360,'linear','hann')),colormap gray