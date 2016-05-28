function [ rcpt_centers, rcpt_sizes ] = rcpt_field_back( params_model, input_size )
%% Format of Input: 
% 1. params_model = [params_layer1; params_layer2;
%   ...], where params_layer = [layer_type, layer_kernelsize, layer_stride, 
%   layer_pad] (layer_type = 0 or 1 means convolutional layer or pooling layer, 
%   respectively);
% 2. input_size = [H W];

output_size = cnn_output_size(params_model, input_size);
depth = size(output_size, 1);
rcpt_centers = cell(depth, 1);
rcpt_sizes = zeros(depth, 1);
for l = depth:-1:1
    rcpt_r = zeros(output_size(l, 1), 1);
    rcpt_c = zeros(output_size(l, 2), 1);
    [rcpt_start, rcpt_end] = rcpt_field_core(params_model(1:l,1), params_model(1:l,2), params_model(1:l,3), params_model(1:l,4), 1, 1, output_size(1:l, 1), input_size(1));    
    rcpt_sizes(l) = rcpt_end - rcpt_start + 1;
    for i = 1:length(rcpt_r)
        [rcpt_start, rcpt_end] = rcpt_field_core(params_model(1:l,1), params_model(1:l,2), params_model(1:l,3), params_model(1:l,4), i, i, output_size(1:l, 1), input_size(1));
        rcpt_r(i) = (rcpt_start + rcpt_end)/2;
    end
    for i = 1:length(rcpt_c)
        [rcpt_start, rcpt_end] = rcpt_field_core(params_model(1:l,1), params_model(1:l,2), params_model(1:l,3), params_model(1:l,4), i, i, output_size(1:l, 2), input_size(2));
        rcpt_c(i) = (rcpt_start + rcpt_end)/2;
    end
    rcpt_centers{l}.r = rcpt_r;
    rcpt_centers{l}.c = rcpt_c;
end

end

function [ output_size ] = cnn_output_size( params_model, input_size )
%% Format of Input: 
% 1. params_model = [params_layer1; params_layer2;
%   ...], where params_layer = [layer_type, layer_kernelsize, layer_stride, 
%   layer_pad] (layer_type = 0 or 1 means convolutional layer or pooling layer, 
%   respectively);
% 2. input_size = [H W];

depth = size(params_model, 1);
output_size = zeros(depth, 2);
bottom_size = input_size;
for l = 1:depth
    params_layer = params_model(l, :);
    switch params_layer(1)
        case 0 % conv_layer
            top_size = floor((bottom_size + 2 * params_layer(4) - params_layer(2)) ./ params_layer(3)) + 1;
        case 1 % pooling_layer
            top_size = ceil((bottom_size + 2 * params_layer(4) - params_layer(2)) ./ params_layer(3)) + 1;
        otherwise
            error('Unknown layer type (nor 0 or 1).');
    end
    output_size(l, :) = top_size;
    bottom_size = top_size;
end

end

function [ rcpt_start, rcpt_end ] = rcpt_field_core(layer_type, kernel, stride, pad, idx_start, idx_end, output_end, input_end)
blob_max = [input_end; output_end];
depth = size(layer_type, 1);
top_start = idx_start; top_end = idx_end;
for l = depth:-1:1
    switch layer_type(l)
        case 0
            bottom_start = 1 + stride(l) * (top_start - 1) - pad(l);
            bottom_end = kernel(l) + stride(l) * (top_end - 1) - pad(l);
        case 1
            bottom_start = stride(l) * top_start - pad(l);
            bottom_end = (stride(l) * top_end - pad(l)) + kernel(l) - 1;
            if pad(l) == 0
                bottom_end = min(bottom_end, blob_max(l));
            end
    end
    top_start = bottom_start;
    top_end = bottom_end;
end
rcpt_start = bottom_start;
rcpt_end = bottom_end;
end