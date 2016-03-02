images_root = 'images/';
Segs_root = 'Segs/val2014/';
save_root = 'Segs/val2014/';
if ~exist(save_root, 'dir'), mkdir(save_root); end;

Segs_list = dir([Segs_root, '*_Seg.png']);
Segs_list = {Segs_list.name};
for s = 1:length(Segs_list)
    s
    Seg_name = Segs_list{s};
    src_path = fullfile(images_root, [Seg_name(1:end-8), '.png']);
    des_path = fullfile(save_root, [Seg_name(1:end-8), '.png']);
    copyfile(src_path, des_path);
end