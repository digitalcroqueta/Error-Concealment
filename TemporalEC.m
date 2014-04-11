
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMPORAL ERROR CONCEALMENT

time1t = cputime;

% Read frame samples:
fileName0 = 'foreman66.Y';
fileID0 = fopen(fileName0, 'r'); 
fileName1 = 'foreman72.Y';
fileID1 = fopen(fileName1, 'r'); 

% Frame size = (352x288)
height = 288;
width = 352;

% Read frames (we used as target frame a previous one):
targetFrame = fread(fileID0, [width,height]);
f1 = rot90(targetFrame,3); % We need to rotate the image (3x90degrees counterclockwise)
anchorFrame = fread(fileID1, [width,height]);
f2 = rot90(anchorFrame,3);
close;
close;

% Display frames:
figure (1)
imshow(uint8(f1))
title('Previous Frame')
figure (2)
imshow(uint8(f2))
title('Next Frame without block loss')

% Setup block error parameters:
concentrationVertical = 4;
concentrationHorizontal = 4;

frameLoss = f2;
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
figure (3)
imshow(frameLoss, [0 255]);
title('Next Frame with block loss')

[Hloss, Wloss] = size(frameLoss); 
frameConcealed = frameLoss;

for yi = 1:length(verticalLoss)
    for xi = 1:length(horizontalLoss)
        % Look for the block errors:
        if (frameLoss(verticalLoss(yi)+(1:blockSize),horizontalLoss(xi)+(1:blockSize)) == 0)
            % For each lost block
            % Look for a matching block based on the neighboors
            i = verticalLoss(yi);
            j = horizontalLoss(xi);
            range = 14;
            N =  blockSize;
            k = 10000;
            % For a defined search range we look for the matching
            % neighboors in the previous frame
            % (similar to the EBM algorithm)
            for m = -range:1:range
                for n = -range:1:range
                    % North
                    if ((i+N+m)>0 && (i+N+m+N-1)<=Hloss && (j+n)>0 && (j+n+N-1)<=Wloss)
                        a = sum(sum(abs(frameLoss(i+(1:blockSize)+N,j+(1:blockSize))-f1(i+m+N+(1:blockSize),j+n+(1:blockSize)))));
                        if (a < k)
                            k = a;
                            dy = m;
                            dx = n;
                        end
                    end
                    
                    % South
                    if ((i-N+m)>0 && (i-N+m+N-1)<=Hloss && (j+n)>0 && (j+n+N-1)<=Wloss)
                        a = sum(sum(abs(frameLoss(i+(1:blockSize)-N,j+(1:blockSize))-f1(i+m-N+(1:blockSize),j+n+(1:blockSize)))));
                        if (a < k)
                            k = a;
                            dy = m;
                            dx = n;
                        end
                    end 
                    
                    % East
                    if ((i+m)>0 && (i+m+N-1)<=Hloss && (j+n+N)>0 && (j+n+N+N-1)<=Wloss)
                        a = sum(sum(abs(frameLoss(i+(1:blockSize),j+N+(1:blockSize))-f1(i+m+(1:blockSize),j+n+N+(1:blockSize)))));
                        if (a < k)
                            k = a;
                            dy = m;
                            dx = n;
                        end
                    end  
                    
                    % West
                    if ((i+m)>0 && (i+m+N-1)<=Hloss && (j+n-N)>0 && (j+n-N+N-1)<=Wloss)
                        a = sum(sum(abs(frameLoss(i+(1:blockSize),j-N+(1:blockSize))-f1(i+m+(1:blockSize),j+n-N+(1:blockSize)))));
                        if (a < k)
                            k = a;
                            dy = m;
                            dx = n;
                        end
                    end 
                end
            end
            % Copy the best option in the lost block
            frameConcealed(i+(1:blockSize),j+(1:blockSize)) = f1(i+dy+(1:blockSize),j+dx+(1:blockSize));
        end
    end
end

% Display
figure (4)
imshow(frameConcealed, [0 255]);
title('Frame with temporal error concealment')

% Calculate processing time:
time2t = cputime;
disp(['Processing time in temporal error concealment = ' num2str(time2t-time1t)]);

% Calculate PSNR
fe1 = f2 - frameLoss;
mse1 = mean(mean(fe1.^2));
PSNR1 = 10*log10(255^2/mse1);
disp(['PSNR without error concealment = ' num2str(PSNR1) ' dB'])

fe2 = f2 - frameConcealed;
mse2 = mean(mean(fe2.^2));
PSNR2 = 10*log10(255^2/mse2);
disp(['PSNR with error concealment = ' num2str(PSNR2) ' dB'])
