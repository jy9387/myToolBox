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

