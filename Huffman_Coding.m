% Read the image
img = imread('Road.jpg');
[input_image_path, name, ext] = fileparts('Road.jpg');
% Convert the image to grayscale
img = rgb2gray(img);
% Get the size of the image
[rows, columns] = size(img);

% Calculate the frequency of each pixel value
freq = zeros(256, 1);
for i = 1:rows
    for j = 1:columns
        value = img(i, j);
        freq(value + 1) = freq(value + 1) + 1;
    end
end

% Calculate the probability of each pixel value
prob = freq / (rows * columns);

% Create the Huffman tree
huffTree = createHuffTree(prob);

% Create the Huffman dictionary
huffDict = createHuffDict(huffTree, []);

% Compress the image
compressedImg = compressImage(img, huffDict);

% Save the compressed image
save('compressedImg.mat', 'compressedImg');

% Decompress the image
decompressedImg = decompressImage(compressedImg, huffDict, rows, columns);

% Display the decompressed image
imshow(decompressedImg, [0 255]);

% Display the original image
subplot(1, 2, 1);
imshow(img, [0 255]);
title('Original Image');

% Display the decompressed image
subplot(1, 2, 2);
imshow(decompressedImg, [0 255]);
title('Decompressed Image');

% Save the decompressed imageS

% Save the decompressed image in the same directory as the input image
imwrite(decompressedImg, fullfile(input_image_path, [name '_decompressed' ext]), 'jpg');

% Define the Huffman tree function
function tree = createHuffTree(prob)
    tree = cell(length(prob), 1);
    for i = 1:length(prob)
        tree{i} = struct('value', i - 1, 'prob', prob(i), 'left', [], 'right', []);
    end
    while numel(tree) > 1
        % Sort the tree
        [~, order] = sort(cellfun(@(x) x.prob, tree));
        tree = tree(order);
        % Merge the two nodes with the smallest probability
        node1 = tree{1};
        node2 = tree{2};
        newNode = struct('value', [], 'prob', node1.prob + node2.prob, 'left', node1, 'right', node2);
        tree = [{newNode}; tree(3:end)];
    end
end

% Define the Huffman dictionary function
function dict = createHuffDict(tree, prefix)
    if isempty(tree{1}.value)
        dict = [createHuffDict({tree{1}.left}, [prefix, 0]); createHuffDict({tree{1}.right}, [prefix, 1])];
    else
        dict = struct('value', tree{1}.value, 'code', prefix);
    end
end

% Define the image compression function
function compressed = compressImage(img, dict)
    [rows, columns] = size(img);
    compressed = cell(rows, columns);
    for i = 1:rows
        for j = 1:columns
            compressed{i, j} = dict([dict.value] == img(i, j)).code;
        end
    end
end

% Define the image decompression function
function decompressed = decompressImage(compressed, dict, rows, columns)
    decompressed = zeros(rows, columns, 'uint8');
    for i = 1:rows
        for j = 1:columns
            for k = 1:length(dict)
                if isequal(dict(k).code, compressed{i, j})
                    decompressed(i, j) = dict(k).value;
                    break;
                end
            end
        end
    end
end