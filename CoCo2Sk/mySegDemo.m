%% initialize COCO api for instance annotations
dataDir='../'; dataType='val2014';
saveDir = sprintf('%s/skDataset/imgs/%s/', dataDir, dataType);
saveDir2 = sprintf('%s/skDataset/segs/%s/', dataDir, dataType);
annFile=sprintf('%s/annotations/instances_%s.json',dataDir,dataType);
if(~exist('coco','var')), coco=CocoApi(annFile); end

%% display COCO categories and supercategories
cats = coco.loadCats(coco.getCatIds());
nms={cats.name}; fprintf('COCO categories: ');
fprintf('%s, ',nms{:}); fprintf('\n');
nms=unique({cats.supercategory}); fprintf('COCO supercategories: ');
fprintf('%s, ',nms{:}); fprintf('\n');

%% get all images containing given categories, select one at random
catIds = coco.getCatIds('catNms', []);
imgIds = coco.getImgIds('catIds', []);

for c = 1:length(catIds)
    if ~exist([saveDir, num2str(catIds(c))], 'dir'), mkdir([saveDir, num2str(catIds(c))]); end;
end
for c = 1:length(catIds)
    if ~exist([saveDir2, num2str(catIds(c))], 'dir'), mkdir([saveDir2, num2str(catIds(c))]); end;
end

k = 1;

for i = 1:length(imgIds)
    imgId = imgIds(i); 
    img = coco.loadImgs(imgId);
    disp(['image: ', img.file_name, '           ', num2str(i), '/', num2str(length(imgIds))]);
    annIds = coco.getAnnIds('imgIds',imgId,'catIds',catIds,'iscrowd',[]);
    anns = coco.loadAnns(annIds);
    if isempty(anns)
        continue;
    end
    I = imread(sprintf('%s/images/%s/%s',dataDir,dataType,img.file_name));
    S = imread(sprintf('%s/images/%s_Segmentations/%s',dataDir,dataType,[img.file_name(1:end-4), '.png']));
    for a = 1:length(anns)
        ann = anns(a);
        area = ann.area;
        if area<10000
            continue;
        end
        bbox = uint32(ann.bbox);
        cat_id = ann.category_id;
        patch = I(max(1, bbox(2)) : min(size(I,1), bbox(2)+bbox(4)), max(1, bbox(1)) : min(size(I,2), bbox(1)+bbox(3)), :);
        imwrite(patch, [saveDir, num2str(cat_id), '/', num2str(k), '.png']);
        patch = S(max(1, bbox(2)) : min(size(I,1), bbox(2)+bbox(4)), max(1, bbox(1)) : min(size(I,2), bbox(1)+bbox(3)), :);
        imwrite(patch, [saveDir2, num2str(cat_id), '/', num2str(k), '_Seg.png']);
        k = k + 1;
    end
end
