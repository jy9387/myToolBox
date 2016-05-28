# -*- coding: utf-8 -*-
import numpy as np
import scipy.misc
import Image
import scipy.io
import scipy
import os
caffe_root = '../../'
import sys
sys.path.insert(0, caffe_root + 'python')
import caffe
caffe.set_mode_gpu()
caffe.set_device(2)
test_dir = '../../data/images/test_and_val/'
save_dir_root = '../../data/edges/test_and_val/'
net = caffe.Net('./deploy.prototxt','./hed_pretrained_bsds.caffemodel', caffe.TEST)

save_dir_1 = save_dir_root + '1/';
save_dir_2 = save_dir_root + '2/';
save_dir_3 = save_dir_root + '3/';
save_dir_4 = save_dir_root + '4/';
save_dir_5 = save_dir_root + '5/';
save_dir_fuse = save_dir_root + '0/';

if not os.path.exists(save_dir_1):
    os.makedirs(save_dir_1)
if not os.path.exists(save_dir_2):
    os.makedirs(save_dir_2)
if not os.path.exists(save_dir_3):
    os.makedirs(save_dir_3)
if not os.path.exists(save_dir_4):
    os.makedirs(save_dir_4)
if not os.path.exists(save_dir_5):
    os.makedirs(save_dir_5)
if not os.path.exists(save_dir_fuse):
    os.makedirs(save_dir_fuse)

imgs = [im for im in os.listdir(test_dir) if '.jpg' in im]
print imgs
nimgs = len(imgs)
print "totally "+str(nimgs)+"images"
for i in range(nimgs):
    img = imgs[i]
    print img
    img = Image.open(test_dir + img)
    img = np.array(img, dtype=np.float32)
    #if img.shape[0] > 400:
    #    r = np.float(400) / img.shape[0]
    #    print r
    #    img = scipy.misc.imresize(img, r)
    #    img = np.array(img, dtype=np.float32)
    #    print img.shape, '------------------'
    img = img[:,:,::-1]
    img -= np.array((104.00698793,116.66876762,122.67891434))
    img = img.transpose((2,0,1))
    net.blobs['data'].reshape(1, *img.shape)
    net.blobs['data'].data[...] = img
    net.forward()

    conv1 = net.blobs['conv1_2'].data[0][...]
    scipy.io.savemat(save_dir_1 + imgs[i][0:-4],dict({'E':1-conv1/conv1.max()}),appendmat=True)
    #scipy.misc.imsave(save_dir_1 + imgs[i],1-conv1/conv1.max())

    conv2 = net.blobs['conv2_2'].data[0][...]
    scipy.io.savemat(save_dir_2 + imgs[i][0:-4],dict({'E':1-conv2/conv2.max()}),appendmat=True)
    #scipy.misc.imsave(save_dir_2 + imgs[i],1-conv2/conv2.max())

    conv3 = net.blobs['conv3_3'].data[0][...]
    scipy.io.savemat(save_dir_3 + imgs[i][0:-4],dict({'E':1-conv3/conv3.max()}),appendmat=True)
    #scipy.misc.imsave(save_dir_3 + imgs[i],1-conv3/conv3.max())

    conv4 = net.blobs['conv4_3'].data[0][...]
    scipy.io.savemat(save_dir_4 + imgs[i][0:-4],dict({'E':1-conv4/conv4.max()}),appendmat=True)
    #scipy.misc.imsave(save_dir_4 + imgs[i],1-conv4/conv4.max())

    conv5 = net.blobs['conv5_3'].data[0][...]
    scipy.io.savemat(save_dir_5 + imgs[i][0:-4],dict({'E':1-conv5/conv5.max()}),appendmat=True)
    #scipy.misc.imsave(save_dir_5 + imgs[i],1-conv5/conv5.max())

    fuse = net.blobs['sigmoid-fuse'].data[0][0,:,:]
    scipy.io.savemat(save_dir_fuse + imgs[i][0:-4],dict({'E':1-fuse/fuse.max()}),appendmat=True)
    scipy.misc.imsave(save_dir_fuse + imgs[i],1-fuse/fuse.max())
    print imgs[i]+"   ("+str(i+1)+" of "+str(nimgs)+")    saved"
    
    #xx = dict()
    #conv_blobs = [b for b in net.blobs.keys() if 'conv' in b]
    #for b in conv_blobs:
    #    xx[b] = net.blobs[b].data[0][...]
    #scipy.io.savemat(save_dir_fuse + imgs[i][0:-4],xx,appendmat=True)
