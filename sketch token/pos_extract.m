clear;
gt_root = '../../data/groundTruth/test_and_val/';
edges_root = '../../data/edges/test_and_val/';
save_root = '../../data/feat_pos/test_and_val/';


gt_list = dir([gt_root, '*.mat']);
gt_list = {gt_list.name};

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

    
for i = 1:length(gt_list)
    disp(['-----------extracting: ', gt_list{i}, '; ', num2str(i), '/', num2str(length(gt_list)), '----------']);
    %% load groundTruth:
    gt_path = [gt_root, gt_list{i}];
    load(gt_path);
    gt = zeros(size(groundTruth{1}.Boundaries))>0;
    for g = 1:length(groundTruth)
        gt = gt|groundTruth{g}.Boundaries;
    end
    input_size = size(gt);
    [rcpt_centers, rcpt_sizes] = rcpt_field_back(params_model, input_size);
    for l = 1:5
        save_conv_dir = [save_root, num2str(l), '/'];
        if ~exist(save_conv_dir, 'dir'), mkdir(save_conv_dir); end;
        feat_conv_dir = [edges_root, num2str(l), '/'];
        
        %% load feature maps of CNN:
        feat_path = [feat_conv_dir, gt_list{i}];
        load(feat_path);
        feat = permute(E, [2 3 1]);

        %% find groundTruth at the feature maps:
        feat_pos = zeros(0, size(feat, 3));
        rc_pos = zeros(0, 4);
        rcpt_center = rcpt_centers{layer_idx(l)};
        rcpt_r = int32(rcpt_center.r);
        rcpt_c = int32(rcpt_center.c);
        for c = 1:length(rcpt_c)
            for r = 1:length(rcpt_r)
                if (0 < rcpt_r(r)) && (rcpt_r(r) <= size(gt,1)) && (0 < rcpt_c(c)) && ( rcpt_c(c)<= size(gt,2)) && (gt(rcpt_r(r), rcpt_c(c)) == true)
                    feat_tmp = permute(feat(r, c, :), [2, 3, 1]);
                    feat_pos = [feat_pos; feat_tmp];
                    rc_pos = [rc_pos; [ r, c, rcpt_r(r), rcpt_c(c)]];
                end
            end
        end
        save([save_conv_dir, gt_list{i}], 'feat_pos', 'rc_pos');
    end
end