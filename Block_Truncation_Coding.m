% Read the image
img = imread('Dog.jpg');

% Convert the image to grayscale
img = rgb2gray(img);

% Define the block size
block_size = 8;

% Compress the image using BTC
btc_compressed = btc_compression(img, block_size);

% Display the original and compressed images
subplot(1, 2, 1);
imshow(img);

subplot(1, 2, 2);
imshow(uint8(btc_compressed));

function btc_compressed = btc_compression(img, block_size)
    % Get the size of the image
    [rows, columns] = size(img);
    
    % Initialize the compressed image
    btc_compressed = zeros(rows, columns);
    
    % Process each block
    for i = 1:block_size:rows
        for j = 1:block_size:columns
            % Get the current block
            block = img(i:min(i+block_size-1,rows), j:min(j+block_size-1,columns));
            
            % Calculate the mean and standard deviation of the block
            mean_block = mean(block(:));
            std_block = std(double(block(:)));
            
            % Threshold the block
            block(block >= mean_block) = mean_block + std_block;
            block(block < mean_block) = mean_block - std_block;
            
            % Store the compressed block
            btc_compressed(i:min(i+block_size-1,rows), j:min(j+block_size-1,columns)) = block;
        end
    end
end