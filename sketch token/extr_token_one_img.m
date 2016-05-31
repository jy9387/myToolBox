function [ patches_yx ] = extr_token_one_img( rc_token, patch_size, gt_size )
%% extract some patches w.r.t. the sketch tokens belonging to one cluster from a given groundTruth map.
%   meaning of Inputs:                                                                  
%       rc_token:   localizations ([r_center, c_center] on the groundTruth map) of the points belonging to 
%                   one cluster;
%       patch_size: the size ([height, width]) of the respective field;
%       gt_size:    the size ([height, width]) of the groundTruth map;

patch_num = size(rc_token, 1);
patches_yx = zeros(patch_num, 4);

yx_token = rc_token - repmat(patch_size/2, patch_num, 1) + 1;
j = 1;
for i = 1:patch_num
    yx_tmp = yx_token(i, :);
%     if (min(yx_tmp) > 0)&&(yx_tmp(1) + patch_size(1) - 1 < gt_size(1))&&(yx_tmp(2) + patch_size(2) - 1 < gt_size(2))
%         patches_yx(j, :) = [yx_tmp, yx_tmp + patch_size - 1]; % [ymin, xmin, ymax, xmax];
%         j = j + 1;
%     else
%         patches_yx(j, :) = [];
%     end
    patches_yx(i, :) = [yx_tmp, yx_tmp + patch_size - 1]; % [ymin, xmin, ymax, xmax];
end

end

