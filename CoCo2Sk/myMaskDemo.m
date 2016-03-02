%% initialize COCO api for instance annotations
dataDir='../'; dataType='val2014';
annFile=sprintf('%s/annotations/instances_%s.json',dataDir,dataType);
if(~exist('coco','var')), coco=CocoApi(annFile); end

%% display COCO categories
cats = coco.loadCats(coco.getCatIds());
catNms={cats.name}; fprintf('COCO categories: ');
fprintf('%s, ',catNms{:}); fprintf('\n');
save_dir = fullfile(dataDir,'images',[dataType,'_Segmentations']);
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
%% get all images containing given categories
catIds = coco.getCatIds('catNms', catNms);
imgIds = cell(length(catIds),1);
for i=1:length(catIds)
    imgIds{i} = coco.getImgIds('catIds', catIds(i) );
end
imgIds = cell2mat(imgIds);
imgIds = unique(imgIds);
for i = 1:length(imgIds)
    tic,
    img = coco.loadImgs(imgIds(i));
    I = imread(sprintf('%s/images/%s/%s',dataDir,dataType,img.file_name));
    annIds = coco.getAnnIds('imgIds',imgIds(i),'catIds',catIds,'iscrowd',[]);
    anns = coco.loadAnns(annIds);
    mask = myMask2(anns, I);
    assert((size(I,1)==size(mask,1))&&(size(I,2)==size(mask,2)));
    imwrite(mask, fullfile(save_dir, [img.file_name(1:end-4), '.png']));
% %     myMask(anns, I);
% %     saveas(1, fullfile(save_dir, [img.file_name(1:end-4), '.png']));
    toc;
end