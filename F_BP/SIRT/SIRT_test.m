%% Test

%%
%Create a sinogram
sinogram = radon(phantom(32));
%Create a reconstructor 
reconstructor = SIRTReconstructor();
%Set the reconstructor
reconstructor = reconstructor.setSinogram(sinogram,1,10);
%% Obtain the equations (this is the worst part so i suggest running it separately)
reconstructor = reconstructor.obtainEquations();
%% now we reconstruct
reconstructor = reconstructor.reconstruct();
%% Show the image
img = reconstructor.img;
imagesc(img),colormap gray;