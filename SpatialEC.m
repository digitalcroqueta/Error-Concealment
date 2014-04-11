
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL ERROR CONCEALMENT (pseudo-directional interpolation)

time1s = cputime;

% USE THIS CODE FOR PROCESSING [.JPG] FORMAT TESTS
%fileName = 'lena.jpg';
%originalFrame = double(imread(fileName));
%[height,width] = size(originalFrame);

% USE THIS CODE FOR PROCESSING [.Y] FORMAT TESTS
fileName0 =  'foreman72.Y';
fileID0 = fopen(fileName0, 'r'); 
height = 288;
width = 352;
targetFrame = fread(fileID0, [width,height]);
originalFrame = rot90(targetFrame,3); 
close;


% Setup block error parameters:
concentrationVertical = 4;
concentrationHorizontal = 4;

% Original frame
figure (1)
imshow(originalFrame, [0 255]);
title('Original frame')


frameLoss = originalFrame;
% Generation of errors in the frame
blockSize = 8;
% We are going to simulate block loss 
% so that there are four neighboring blocks available for a lost block
yL = blockSize*concentrationVertical;
xL = blockSize*concentrationHorizontal;
% Possible positions of lost blocks
verticalLoss = yL:yL:(height-yL);
horizontalLoss = xL:xL:(width-xL);
for yi = 1:length(verticalLoss)
    for xi = 1:length(horizontalLoss)
       frameLoss(verticalLoss(yi)+(1:blockSize), horizontalLoss(xi)+(1:blockSize)) = 0;
    end
end
      
% Frame with loss of information
figure (2)
imshow(frameLoss, [0 255]);
title('Frame with loss of information')

frameConcealed = frameLoss;

for yi = 1:length(verticalLoss)
    for xi = 1:length(horizontalLoss)
        % First, we look for the block errors:
        if (frameLoss(verticalLoss(yi)+(1:blockSize),horizontalLoss(xi)+(1:blockSize)) == 0)
            k = 0;
            o1 = verticalLoss(yi);
            o2 = horizontalLoss(xi);
            while (k <=(blockSize/2))
                
                    % North
                for g = (o1+k):(o1+(blockSize/2))
                    frameConcealed(g,o2+k) = (1/3)*( frameConcealed(g-1,o2+k) + frameConcealed(g,o2+k-1) + frameConcealed(g-1,o2+k-1));
                end
                for g = (o1+blockSize-k):-1:(o1+(blockSize/2))
                    frameConcealed(g,o2+k) = (1/3)*( frameConcealed(g+1,o2+k) + frameConcealed(g,o2+k-1) + frameConcealed(g+1,o2+k-1));
                end
                
                    % South
                for g = (o1+k):(o1+(blockSize/2))
                    frameConcealed(g,o2+blockSize-k) = (1/3)*( frameConcealed(g-1,o2+blockSize-k) + frameConcealed(g,o2+blockSize-k+1) + frameConcealed(g-1,o2+blockSize-k+1));
                end
                for g = (o1+blockSize-k):-1:(o1+(blockSize/2))
                    frameConcealed(g,o2+blockSize-k) = (1/3)*( frameConcealed(g+1,o2+blockSize-k) + frameConcealed(g,o2+blockSize-k+1) + frameConcealed(g+1,o2+blockSize-k+1));
                end     
                
                    % West
                for g = (o2+k):(o2+(blockSize/2))
                    frameConcealed(o1+k,g) = (1/3)*( frameConcealed(o1+k,g-1) + frameConcealed(o1+k-1,g) + frameConcealed(o1+k-1,g-1));
                end
                for g = (o2+blockSize-k):-1:(o2+(blockSize/2))
                    frameConcealed(o1+k,g) = (1/3)*( frameConcealed(o1+k,g+1) + frameConcealed(o1+k-1,g) + frameConcealed(o1+k-1,g+1));
                end     
                
                    % East
                for g = (o2+k):(o2+(blockSize/2))
                    frameConcealed(o1+blockSize-k,g) = (1/3)*( frameConcealed(o1+blockSize-k,g-1) + frameConcealed(o1+blockSize-k+1,g) + frameConcealed(o1+blockSize-k+1,g-1));
                end
                for g = (o2+blockSize-k):-1:(o2+(blockSize/2))
                    frameConcealed(o1+blockSize-k,g) = (1/3)*( frameConcealed(o1+blockSize-k,g+1) + frameConcealed(o1+blockSize-k+1,g) + frameConcealed(o1+blockSize-k+1,g+1));
                end
                
                k = k+1;
            end
        end
    end
end

figure (3)
imshow(frameConcealed, [0 255]);
title('Frame with spatial error concealment')

% Calculate processing time:
time2s = cputime;
disp(['Processing time in spatial error concealment = ' num2str(time2s-time1s)]);

% Calculate PSNR
fe1 = originalFrame - frameLoss;
mse1 = mean(mean(fe1.^2));
PSNR1 = 10*log10(255^2/mse1);
disp(['PSNR without error concealment = ' num2str(PSNR1) ' dB'])

fe2 = originalFrame - frameConcealed;
mse2 = mean(mean(fe2.^2));
PSNR2 = 10*log10(255^2/mse2);
disp(['PSNR with error concealment = ' num2str(PSNR2) ' dB'])
