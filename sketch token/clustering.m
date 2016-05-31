clear;
addpath(genpath('include/toolbox'));

feat_root = '../../data/feat_pos/test_and_val/';
save_root = '../../data/clustered/test_and_val/';
if ~exist(save_root, 'dir'), mkdir(save_root); end;

layers = dir(feat_root);
layers = {layers.name};
layers = layers(3:end);
num_layers = length(layers);
k = [50 50 50 50 50];

for l = num_layers:-1:1
    %% loading features:
    layer = layers{l};
    if ~exist([save_root, layer, '_feats.mat'], 'file')
        feat_layer_dir = [feat_root, layer, '/'];
        feat_list = dir([feat_layer_dir, '*.mat']);
        feat_list = {feat_list.name};
        feat_pos_full = [];
        rc_pos_full = [];
        for i = 1:length(feat_list)
            feat_name = feat_list{i};
            disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *loading features: ', feat_name(1:end-4), ', ', num2str(i), '/', num2str(length(feat_list))]);
            load([feat_layer_dir, feat_name], 'feat_pos', 'rc_pos');
            rc_pos = [rc_pos, repmat(int32(str2num(feat_name(1:end-4))), size(rc_pos, 1), 1)];
            feat_pos_full = [feat_pos_full; feat_pos];
            rc_pos_full = [rc_pos_full; rc_pos];
        end
        clear rc_pos feat_pos;
        disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *saving loaded features...']);
        save([save_root, layer, '_feats'], 'feat_pos_full', 'rc_pos_full');
    else
        disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *features exist. Now loading...']);
        load([save_root, layer, '_feats.mat'], 'feat_pos_full', 'rc_pos_full');
    end
    
    %% clustering:
    % L2 normalization as preprocessing
    feat_norm = sqrt(sum((feat_pos_full').^2, 1));
    feat_pos_full = (bsxfun(@rdivide, feat_pos_full', feat_norm))';
    
    disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *starting clustering...']);
    [IDX, codebook] = kmeans2(feat_pos_full, k(l));
    disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *clustering finished...']);
    disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *saving clustering results...']);
    save([save_root, layer, '_clustered'], 'IDX', 'codebook');
    
    %% pruning:
    disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *starting pruning...']);
    [codebook_new, IDX_new] = pruning(codebook, IDX, feat_pos_full);
    disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *pruning finished...']);
    disp(['clustering (round ', num2str(l), '/', num2str(num_layers), ') *saving pruning results...']);
    save([save_root, layer, '_pruned'], 'IDX_new', 'codebook_new');
end