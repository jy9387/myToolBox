
function skeleton_Micoco(mask_dir)
    addpath(genpath('SkelPruningTradeoff/'));
    fmt = '*.png';
    database = retr_database_dir(mask_dir, fmt);

	tic,
    for n = 1:length(database.path)
        fprintf('Skeleton calculate: %d of %d\n', n, length(database.path));
        try
            func_skeleton(database.path{n} );
        catch
            fprintf('Skip: %d \n', n);
            continue;
        end
    end
    toc;

function func_skeleton(mask_path )
    alpha = 9.0;
    threshold = 0.001;
    mask = imread(mask_path);
%     bw1=im2bw(mask);
    mask = rgb2gray(mask);
    bw1 = (mask~=0);
    bw1 = imfill(bw1, 'holes');
    [m,n] = size(bw1);  
    [skel_image, skel_dist] = DSE(bw1,50, alpha,threshold);
    skel_image = skel_image/2;
%     [sx,sy] = find(skel_image == 0);
%     list = [sx,sy];
%     skel_image = my_plot(skel_image, list, [0 0 0], 1);
    SK = (skel_dist.*(skel_image==0));
    SK = SK(4:end-3, 4:end-3);
    save([mask_path(1:end-8),'_SK.mat'],'SK');
    imwrite(~double(imresize(bw1,size(SK)))+SK,[mask_path(1:end-8),'_SkShow.jpg']);
    
