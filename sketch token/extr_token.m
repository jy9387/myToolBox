function [ patch_avrg ] = extr_token( rc_token, rc_img_idx, patch_size, gt_root, save_root )
%% extract some patches w.r.t. the sketch tokens belonging to one cluster from the groundTruth maps in the whole dataset.
%   meaning of Inputs:                                                                  
%       rc_token:   localizations ([r_center, c_center] on the groundTruth map) of the points belonging to 
%                   one cluster;
%       rc_img_idx: image index of each rc_token;
%       patch_size: the size ([height, width]) of the respective field;

% if ~exist(save_root, 'dir'), mkdir(save_root); end;
patch_avrg = zeros(patch_size);
rc_img_idx_unq = unique(rc_img_idx);
idx = 0;
for i = 1:length(rc_img_idx_unq)
    load([gt_root, num2str(rc_img_idx_unq(i))], 'groundTruth');
    gt = zeros(size(groundTruth{1}.Boundaries))>0;
    for g = 1:length(groundTruth)
        gt = gt|groundTruth{g}.Boundaries;
    end
    gt_size = size(gt);
    rc_one_img = rc_token(rc_img_idx == rc_img_idx_unq(i), :);
    patches_yx = extr_token_one_img(rc_one_img, patch_size, gt_size);
    pad_r = max(max(1 - patches_yx(:,1), 0), max(patches_yx(:,3) - gt_size(1), 0));
    pad_c = max(max(1 - patches_yx(:,2), 0), max(patches_yx(:,4) - gt_size(2), 0));
    pad = max(pad_r, pad_c);
    pad = max(pad(:));
    if pad ~= 0
        gt_pad = padarray(gt, [pad, pad]);
    else
        gt_pad = gt;
    end
    for p = 1:size(patches_yx, 1)
        idx = idx + 1;
        patch_r_min = patches_yx(p, 1) + pad;
        patch_r_max = patches_yx(p, 3) + pad;
        patch_c_min = patches_yx(p, 2) + pad;
        patch_c_max = patches_yx(p, 4) + pad;        
        patch = gt_pad(patch_r_min:patch_r_max, patch_c_min: patch_c_max);
%         save([save_root, '/patch_', num2str(idx), '.mat'], 'patch');
        patch_avrg = patch_avrg + patch;
    end
end
patch_avrg = patch_avrg ./ idx;

end

