%% Create the identifier and load the files. 
imgIdentifier = ImageIdentifier();
imgIdentifier = imgIdentifier.loadImages('training');
%% Create the convnet
imgIdentifier = imgIdentifier.setSimpleCNN();

%% Train the thing
imgIdentifier = imgIdentifier.train();