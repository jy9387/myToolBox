#-*-coding:utf-8-*-



import json,os
import scipy.io
#import xmltodict

def jsonSplit(json_path, save_dir):
    if not os.path.exists(save_dir):
        os.mkdir(save_dir)
        print 'Make root: %s' % save_dir
    save_dir_json = os.path.join(save_dir, 'json')
    save_dir_mat = os.path.join(save_dir, 'mat')
    if not os.path.exists(save_dir_json):
        os.mkdir(save_dir_json)
        print 'Make dir for saving .json: %s' % save_dir_json
    if not os.path.exists(save_dir_mat):
        os.mkdir(save_dir_mat)
        print 'Make dir for saving .mat: %s' % save_dir_mat
    with open(json_path, 'r') as f:
        x = json.load(f)
    print 'Loaded.'
    images = x['images']
    annotations = x['annotations']
    for image in images:
        imgpath = os.path.split(image['file_name'])
        imgname = imgpath[1]
        filename_json = os.path.join(save_dir_json, imgname[:-4] + '.json')
#        filename2=os.path.join(save_dir,imgname[:-4]+'.xml')
        filename_mat = os.path.join(save_dir_mat, imgname[:-4] + '.mat')        
        id_image = image['id']
        objects = []
        for annotation in annotations:
            id_anno = annotation['image_id']
            if id_image == id_anno:
                objects.append(annotation)
        Annotation = {'image':image, 'objects':objects}
        xs = []
        ys = []
        ws = []
        hs = []
        for obj in objects:
            bbox = obj['bbox']
            xs.append(bbox[0])
            ys.append(bbox[1])
            ws.append(bbox[2])
            hs.append(bbox[3])
       	scipy.io.savemat(filename_mat, {'x' : xs, 'y' : ys, 'w' : ws, 'h' : hs})
        print filename_mat
        with file(filename_json, 'w') as f:
            json.dump(Annotation, f, indent = 1)
        print filename_json
#        Annotation={'Annotation':Annotation}
#        convertedXml=xmltodict.unparse(Annotation)
#        with file(filename2,'w') as f:
#            f.write(convertedXml,indent=1)
#            f.write(convertedXml)
#        print filename2

json_path = os.path.join('.', 'instances_train2014.json')
save_dir = os.path.join('.', 'train2014')
jsonSplit(json_path, save_dir)

json_path = os.path.join('.', 'instances_val2014.json')
save_dir = os.path.join('.', 'val2014')
jsonSplit(json_path, save_dir)
#save_dir=os.path.join('.','train2014')
#if not os.path.exists(save_dir):
#    os.mkdir(save_dir)
#    print 'Make dir: %s'%save_dir
#rootfile=os.path.join('.','instances_train2014.json')
#print 'Load %s ...'%rootfile
#with open(rootfile,'r') as f:
#    x=json.load(f)
#print 'Loaded.'
#
#images=x['images']
#annotations=x['annotations']
#
#for image in images[0:2]:
#    filename=os.path.join(save_dir,image['file_name'][15:-4]+'.json')
#    id_image=image['id']
#    objects=[]
#    for annotation in annotations:
#        id_anno=annotation['image_id']
#        if id_image==id_anno:
#            objects.append(annotation)
#    Annotation={'image:':image, 'objects':objects}
#    with file(filename,'w') as f:
#        json.dump(Annotation,f)
#    print filename
