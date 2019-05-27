classdef ImageIdentifier
    
   properties
       images;
       validationData;
       trainData;
       imgRows;
       imgCols;
       imgDepth;
       layers;
       trainedNet;
   end
   
   
   methods
       %Function to load the images. 
       function obj = loadImages(obj,dir)
           %Includes the subfolders which contain
           %images in different categories. In this case
           %tumor and non tumor. 
           imgs = imageDatastore(dir,'IncludeSubfolders',true,'LabelSource','foldernames');
           obj.images = imgs;
           
           %Split into validation and train data 
           labelCounter = countEachLabel(imgs);
           numTrainFiles = round(min(labelCounter.Count)/2);
           disp('num train files ')
           disp(numTrainFiles)
           [trainData,validData] = splitEachLabel(imgs,numTrainFiles,'randomize');
           obj.validationData = validData;
           obj.trainData = trainData;
           %Get the size of the images. 
           sampleImage = imread(char(obj.images.Files(1)));
           obj.imgRows = size(sampleImage,1);
           obj.imgCols = size(sampleImage,2);
           obj.imgDepth = size(sampleImage,3);
       end
       
       function obj = setSimpleCNN(obj)
           %The input size
           inputSize = [obj.imgRows obj.imgCols 1];
           %Number of classes
           numClasses = 2;
           %Simple layer structure
           layers = [
               %Preprocessing
               imageInputLayer(inputSize);
               %20 5x5 filters 
               convolution2dLayer(9,30,'Padding','same');
               batchNormalizationLayer;
               %The activation function is relu
               reluLayer
               %pool 
               maxPooling2dLayer(2,'Stride',2);
               %Another convolution layer
               convolution2dLayer(3,32,'Padding','same');
               batchNormalizationLayer;
               reluLayer;
               fullyConnectedLayer(2);
               softmaxLayer;
               classificationLayer;
               
           ];
       obj.layers = layers;
       end
       
       function obj = train(obj)
           options = trainingOptions('sgdm','MaxEpochs',5,'ValidationData',obj.validationData,'ValidationFrequency',30,'Verbose',false,'Plots','training-progress');
           obj.trainedNet = trainNetwork(obj.trainData,obj.layers,options);
       end
       
       function label = classifyImg (obj,img)
          inputSize = obj.trainedNet.Layers(1).InputSize;
          img = imresize(img,inputSize(1:2));
          label = obj.trainedNet.classify(img); 
       end
      
      
      
     
   end
    
    
    
    
    
end