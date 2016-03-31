#-*-coding:utf-8-*-
import re

class Layer(object):
    """docstring for Layer"""
    def __init__(self, layer_type, kernel_h, stride_h, pad_h_top, idx_start, idx_end):
        self.type = int(layer_type)
        self.kernel_h = int(kernel_h)
        self.stride_h = int(stride_h)
        self.pad_h_top = int(pad_h_top)
        self.idx_start = int(idx_start)
        self.idx_end = int(idx_end)
    def get_bottom_idx(self):
        if(self.type == 0):
            idx_bottom_start = 1 + self.stride_h * (self.idx_start - 1) - self.pad_h_top
            idx_bottom_end = self.kernel_h + self.stride_h * (self.idx_end - 1) - self.pad_h_top
            return idx_bottom_start, idx_bottom_end


layer_params = raw_input('please enter the primary parameters of the toppest level with format like: layer_type, kernel_h, stride_h, pad_h_top, idx_start, idx_end\n')
layer_params = re.split(r'[\s\,]+', layer_params)
layer = Layer(layer_params[0], layer_params[1], layer_params[2], layer_params[3], layer_params[4], layer_params[5])
while(1):
    idx_bottom_start, idx_bottom_end = layer.get_bottom_idx()
    print 'the receptive field is between:', idx_bottom_start, 'and', idx_bottom_end
    layer_params = raw_input('please enter the parameters of the bottom level with format like: layer_type, kernel_h, stride_h, pad_h_top\n')
    layer_params = re.split(r'[\s\,]+', layer_params)
    try:
        layer = Layer(layer_params[0], layer_params[1], layer_params[2], layer_params[3], idx_bottom_start, idx_bottom_end)
    except IndexError, e:
        print 'Program was terminated. The final receptive field is between:', idx_bottom_start, 'and', idx_bottom_end
        print 'The size of receptive field of the toppest layer is:', idx_bottom_end - idx_bottom_start + 1
        break