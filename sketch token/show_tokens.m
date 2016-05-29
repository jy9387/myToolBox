clear;

cluster_root = '../../data/clustered/test_and_val/';
gt_root = '../../data/groundTruth/test_and_val/';
save_root = '../../data/sketch_tokens/test_and_val/';

params_model = [0,3,1,35;...
                0,3,1,1;...
                1,2,2,0;...
                0,3,1,1;...
                0,3,1,1;...
                1,2,2,0;...
                0,3,1,1;...
                0,3,1,1;...
                0,3,1,1;...
                1,2,2,0;...
                0,3,1,1;...
                0,3,1,1;...
                0,3,1,1;...
                1,2,2,0;...
                0,3,1,1;...
                0,3,1,1;...
                0,3,1,1];
layer_idx = [2, 5, 9, 13, 17];

[~, rcpt_size] = rcpt_field_back(params_model, [321, 481]);
patches_size = rcpt_size(layer_idx);


for c = 1:length(layer_idx)
    %% for the c_th layer:
    disp(['----------starting extracting patches: layer ', num2str(c), '----------']);
    load([cluster_root, '/', num2str(c), '_clustered.mat']);
    load([cluster_root, '/', num2str(c), '_feats.mat']);
    IDX_unq = unique(IDX);
    patch_size = int32([patches_size(c), patches_size(c)]);
    
    save_root_cth = fullfile(save_root, ['layer_', num2str(c)]);
    if ~exist(save_root_cth, 'dir'), mkdir(save_root_cth); end;
    
    for i = 1:length(IDX_unq)
        disp(['extracting patches: layer ', num2str(c), ' center: ', num2str(IDX_unq(i))]);
        %% for the i_th clustered center:
%         IDX_tmp = IDX(IDX == IDX_unq(i));
        rc_pos_tmp = rc_pos_full(IDX == IDX_unq(i), :);
        rc_token = rc_pos_tmp(:, 3:4);
        rc_img_idx = rc_pos_tmp(:, 5);
        
        save_patches_dir = fullfile(save_root_cth, 'patches', ['center_', num2str(IDX_unq(i))]);
        patch_avrg = extr_token(rc_token, rc_img_idx, patch_size, gt_root, save_patches_dir);
        
        save_avrg_dir = fullfile(save_root_cth, 'avrg');
        if ~exist(save_avrg_dir, 'dir'), mkdir(save_avrg_dir); end;
        save([save_avrg_dir, '/patch_avrg_', num2str(IDX_unq(i)), '.mat'], 'patch_avrg');
        imwrite(patch_avrg, [save_avrg_dir, '/patch_avrg_', num2str(IDX_unq(i)), '.png']);
    end
    
end