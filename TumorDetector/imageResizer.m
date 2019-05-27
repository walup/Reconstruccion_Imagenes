function y = imageResizer(folder,newFolderName)
%Create a new folder 
mkdir(newFolderName);

%
files = dir(fullfile(folder));
n = length(files);
%The width and height
WIDTH = 256;
HEIGHT = 256;

resizedImgs = {};
for i = 1:n
    %Open the image and convert to gray
    if(~isequal(files(i).name, '.') && ~isequal(files(i).name,'..'))
        %Convert to double
        img = imread(strcat(folder,'/',char(files(i).name)));
        if(size(img,3) == 3)
        img = rgb2gray(img);
        end
        disp(size(img));
        %Get it to the required size. 
        img = imresize(img,[WIDTH HEIGHT]);
        %Add it to the array 
        resizedImgs{end+1} = {img,files(i).name};
    end
end

%Now add all the images to the dir. 
y = resizedImgs;
disp(n);
disp(size(resizedImgs));
for i = 1:n
   imwrite(resizedImgs{i}{1},strcat(newFolderName,'/',char(resizedImgs{i}{2}))); 
end


end