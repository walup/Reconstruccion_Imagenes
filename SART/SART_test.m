%% Set the sinogram 
sinogram = radon(phantom(128));
reconstructor = SARTReconstructorFinal();
reconstructor = reconstructor.setSinogram(sinogram,128);
%% See the rays 
reconstructor.rays.drawRays(120,reconstructor.grid);
%% Reconstruct
reconstructor= reconstructor.reconstruct();
%% Show the image (let us pray)
img = reconstructor.img;
figure();
imagesc(img), colormap gray;
%%
