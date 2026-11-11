%% SPLAT assay analysis
%
%   Quantify Lipo-positive objects and DV-positive objects that do not
%   spatially overlap with Lipo-positive regions in two-Channel TIFF images.
%   The non-overlapping DV count is used to minimize contributions from
%   fluorescence crosstalk in the DV channel.
%
%
% INPUT
%   Two-channel .tif/.tiff files in the input directory. This script assumes
%   that channel 1 is Lipo and channel 2 is DV.
%
% OUTPUT
%   Binary masks (Lipo, DV, and non-overlapping DV) and a particle-count
%   table in CSV and Excel formats.
%

clearvars;

%% folders and settings
baseFolder = 'the file folder apth/';
experimentFolder = '/experiment folder/';
inputFolder = fullfile(baseFolder, experimentFolder, 'tif');
outputFolder = fullfile(baseFolder, experimentFolder);
maskFolder = fullfile(outputFolder, 'mask');

% Image channel assignment
lipoCh = 1;
dvCh = 2;

% Adaptive local threshold settings 
neighborhoodSize = 81;
lipoSensitivity = 0.32;
dvSensitivity = 0.30;

firstFileIndex = 1;
fileIndexStep = 1;

%% load input files
if ~isfolder(inputFolder)
    error('Input directory does not exist: %s', inputFolder);
end

imageFiles = [dir(fullfile(inputFolder, '*.tif')); ...
              dir(fullfile(inputFolder, '*.tiff'))];
imageFiles = imageFiles(~[imageFiles.isdir]);

% Sort explicitly so file-index-based selection is reproducible.
[~, sortOrder] = sort(lower({imageFiles.name}));
imageFiles = imageFiles(sortOrder);

if isempty(imageFiles)
    error('No TIFF files found in: %s', inputFolder);
end

selectedIndices = firstFileIndex:fileIndexStep:numel(imageFiles);
if isempty(selectedIndices)
    error(['No files selected. There are %d TIFF files, but the first ' ...
           'selected index is %d. Check the file-selection settings.'], ...
           numel(imageFiles), firstFileIndex);
end

if ~isfolder(maskFolder)
    mkdir(maskFolder);
end

%% Analyze
nSelected = numel(selectedIndices);
imageName = strings(nSelected, 1);
nLipo = zeros(nSelected, 1);
nDVtotal = zeros(nSelected, 1);
nDVnonoverlap = zeros(nSelected, 1);
dvToLipoRatio = nan(nSelected, 1);

for k = 1:nSelected
    fileIndex = selectedIndices(k);
    filename = imageFiles(fileIndex).name;
    imagePath = fullfile(inputFolder, filename);

    % Each TIFF must contain both channel images as separate Chs.
    imageInfo = imfinfo(imagePath);
    if numel(imageInfo) < max(lipoCh, dvCh)
        error('Missing required TIFF Chs in %s.', filename);
    end

    lipoImage = imread(imagePath, lipoCh);
    dvImage = imread(imagePath, dvCh);

    %Channels should have same sizes.
    if ~isequal(size(lipoImage), size(dvImage))
        error('Channel image sizes differ in %s.', filename);
    end

    % Segment the two channels independently.
    lipoThreshold = adaptthresh(lipoImage, lipoSensitivity, ...
        'NeighborhoodSize', neighborhoodSize);
    dvThreshold = adaptthresh(dvImage, dvSensitivity, ...
        'NeighborhoodSize', neighborhoodSize);

    lipoMask = imbinarize(lipoImage, lipoThreshold);
    dvMask = imbinarize(dvImage, dvThreshold);

    % Label connected components with MATLAB's default connectivity,
    [~, currentNLipo] = bwlabel(lipoMask);
    [dvLabels, currentNDV] = bwlabel(dvMask);

    % Retain only DV objects with no pixels in the Lipo-positive mask.
    nonoverlapDVmask = false(size(dvMask));
    currentNDVnonoverlap = 0;

    for objectIndex = 1:currentNDV
        objectMask = dvLabels == objectIndex;
        if ~any(objectMask(:) & lipoMask(:))
            currentNDVnonoverlap = currentNDVnonoverlap + 1;
            nonoverlapDVmask = nonoverlapDVmask | objectMask;
        end
    end

    % record object counts and ratio.
    imageName(k) = string(filename);
    nLipo(k) = currentNLipo;
    nDVtotal(k) = currentNDV;
    nDVnonoverlap(k) = currentNDVnonoverlap;

    if currentNLipo > 0
        dvToLipoRatio(k) = currentNDVnonoverlap / currentNLipo;
    else
        % Undefined when no Lipo objects are found.
        warning('No Lipo objects found in %s. Ratio set to NaN.', filename);
    end

    % Save masks as 8-bit images (0 = background, 255 = foreground).
    imwrite(uint8(lipoMask) * 255, fullfile(maskFolder, ['L_' filename]));
    imwrite(uint8(dvMask) * 255, fullfile(maskFolder, ['D_' filename]));
    imwrite(uint8(nonoverlapDVmask) * 255, ...
        fullfile(maskFolder, ['nonoverlap_DV_' filename]));

    fprintf('[%d/%d] %s: Lipo = %d, DV total = %d, DV nonoverlap = %d, ratio = %.4f\n', ...
        k, nSelected, filename, currentNLipo, currentNDV, ...
        currentNDVnonoverlap, dvToLipoRatio(k));
end

%% Export 
results = table(imageName, nLipo, nDVtotal, nDVnonoverlap, dvToLipoRatio, ...
    'VariableNames', {'ImageName', 'LipoCount', 'DVTotalCount', ...
                      'DVNonoverlapCount', 'DVtoLipoRatio'});

writetable(results, fullfile(outputFolder, 'particle_counts.csv'));
writetable(results, fullfile(outputFolder, 'particle_counts.xlsx'));

fprintf('Finished: %d images analyzed. Results saved to %s\n', ...
    nSelected, outputFolder);
