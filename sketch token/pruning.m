function [ centers_new, assignments_new] = pruning( centers, assignments, features)
centers = centers'; assignments = assignments'; features = features';
[~, K] = size(centers);

%% L2 normalization
feat_norm = sqrt(sum(features.^2));
features = bsxfun(@rdivide, features, feat_norm);
count = hist(double(assignments), K);

%% based on centers
pw_cen = zeros(K, K);
for k  = 1:K
    for m = 1:K
        pw_cen(k,m) = norm(centers(:, k)-centers(:, m));
    end
end

%% based on data points
pw_all = zeros(K, K);
for k = 1:K
    target = centers(:, k);
    for m = 1:K
        temp_feat = features(:, assignments==m);
        dist = sqrt(sum(bsxfun(@minus, target, temp_feat).^2, 1));
        sort_value = sort(dist, 'ascend');
        pw_all(k, m) = mean(sort_value(1:round(0.95*length(sort_value))));
    end
end

%% compute metric
list = zeros(1, K);
for k = 1:K
    rec = zeros(1, K);
    for m = 1:K
        if m ~= k
            rec(m) = (pw_all(m, m) + pw_all(k, k))/pw_cen(m, k);
        end
    end
    list(k) = max(rec);
end
count_norm = count/sum(count);

%% give big penalty if cluster number is too small
penalty = 100*(count<100);

%% combine the above metrics, the lower the better
com = list - K*count_norm + penalty; 
[a, b] = sort(com, 'ascend');
sort_com = [a; b];

%% greedy pruning
sort_cls = sort_com(2, :);    
rec = ones(1, K);
thresh1 = 0.95;
thresh2 = 0.2;
prune = [];
prune_res = [];

while sum(rec) > 0
    temp = [];
    idx = find(rec==1, 1);
    cls = sort_cls(idx);
    target = centers(:, cls);
    temp_feat = features(:, assignments==cls);
    dist = sqrt(sum(bsxfun(@minus, target, temp_feat).^2, 1));
    sort_value = sort(dist, 'ascend');
    dist_thresh = sort_value(round(thresh1*length(sort_value)));
    rec(idx) = 0;
    for n = idx+1:K
        if rec(n) == 1
            temp_feat = features(:, assignments==sort_cls(n));
            dist = sqrt(sum(bsxfun(@minus, target, temp_feat).^2, 1));
            if mean(dist<dist_thresh) >= thresh2
                temp = [temp, [n; sort_cls(n); mean(dist<dist_thresh)]];
                rec(n) = 0;
            end
        end
    end
%     fprintf('%d, %d, %d\n', idx, cls, size(temp, 2));
    prune = [prune, [idx; cls; size(temp, 2)]];
    prune_res = [prune_res, {temp}];
end
pruning_table=cell(size(prune, 2), 1);
%% update new dictionary
K_new = size(prune, 2);
centers_new = zeros(size(centers,1), K_new);
assignments_new = 0*assignments;
for k = 1:K_new
    if isempty(prune_res{k})
        temp = prune(2, k);
    else
        temp = [prune(2, k), prune_res{k}(2, :)];
    end
    pruning_table{k}=temp;
    weight = count(1, temp); 
    weight = weight/sum(weight);
    temp_cen = centers(:, temp);
    centers_new(:, k) = temp_cen*weight';
    for i = 1:length(temp)
        assignments_new(assignments==temp(i)) = k;
    end
end

centers_new = centers_new'; assignments_new = assignments_new';
end

