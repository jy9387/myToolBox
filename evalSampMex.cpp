#include "mex.h"
#include "math.h"
#include <algorithm>
#include <vector>
#include <iostream>

using namespace std;
#define PI 3.14159265f
typedef struct {int c,r,w,h;} Box;
typedef vector<Box> Boxes;

class EvalSampler
{
public:
	int _h,_w;
	float _alpha;
	float _maxAspectRatio,_minBoxArea;
	void sampler(Boxes &boxes);
private:
	float _scStep, _arStep, _rcStepRatio;
//    float _arRad,_scNum;
//    float _width,_height,_minSize,_scStep2;
};
//////////////////////////////////////////////////////////////////////////////////////////
void EvalSampler::sampler(Boxes &boxes)
{
	_scStep=sqrt(1/_alpha);
	_arStep=(1+_alpha)/(2*_alpha);
	_rcStepRatio=(1-_alpha)/(1+_alpha);
	boxes.resize(0);int arRad,scNum; float minSize=sqrt(_minBoxArea);
	arRad = int(log(_maxAspectRatio)/log(_arStep*_arStep));//_arRad=arRad;
	scNum = int(ceil(log(max(_w,_h)/minSize)/log(_scStep)));//_scNum=scNum;_width=_w;_height=_h;_minSize=minSize;_scStep2=_scStep;
	for(int s=0; s<scNum; s++){
		int a,r,c,bh,bw,kr,kc,bId=-1; float ar,sc;
		for (a=0;a<2*arRad+1;a++){
			ar=pow(_arStep,float(a-arRad)); sc=minSize*pow(_scStep,float(s));
			bh=int(sc/ar); kr=max(2,int(bh*_rcStepRatio));
			bw=int(sc*ar); kc=max(2,int(bw*_rcStepRatio));
			for(c=0;c<_w-bw+kc;c+=kc)for(r=0;r<_h-bh+kr;r+=kr){
				Box b; b.r=r;b.c=c;b.h=bh;b.w=bw; boxes.push_back(b);
			}
		}
	}
}

void mexFunction(int nl, mxArray *pl[], int nr, const mxArray *pr[])
{
    if(nr != 5) mexErrMsgTxt("Five inputs required.");
    if(nl > 1) mexErrMsgTxt("At most one output expected.");
	EvalSampler evalSamp; Boxes boxes;
	evalSamp._w = int(mxGetScalar(pr[0]));
	evalSamp._h = int(mxGetScalar(pr[1]));
	evalSamp._alpha = float(mxGetScalar(pr[2]));
	evalSamp._maxAspectRatio = float(mxGetScalar(pr[3]));
	evalSamp._minBoxArea = float(mxGetScalar(pr[4]));
	evalSamp.sampler(boxes);
	 
	int n = (int)boxes.size();
	pl[0] = mxCreateNumericMatrix(n,4,mxSINGLE_CLASS,mxREAL);
	float *bbs = (float*) mxGetData(pl[0]);
	for(int i=0; i<n; i++){
		bbs[i+0*n]=(float)boxes[i].c+1;
		bbs[i+1*n]=(float)boxes[i].r+1;
		bbs[i+2*n]=(float)boxes[i].w;
		bbs[i+3*n]=(float)boxes[i].h;
	}
//     pl[1] = mxCreateNumericMatrix(1,14,mxSINGLE_CLASS,mxREAL);
//     float *test = (float*) mxGetData(pl[1]);
//     test[0]=evalSamp._scStep;
//     test[1]=evalSamp._arStep;
//     test[2]=evalSamp._rcStepRatio;
//     test[3]=evalSamp._w;
//     test[4]=evalSamp._h;
//     test[5]=evalSamp._alpha;
//     test[6]=evalSamp._maxAspectRatio;
//     test[7]=evalSamp._minBoxArea;
//     test[8]=evalSamp._arRad;
//     test[9]=evalSamp._scNum;
//     test[10]=evalSamp._width;
//     test[11]=evalSamp._height;
//     test[12]=evalSamp._minSize;
//     test[13]=evalSamp._scStep2;
}



/*void mexFunction(int nl, mxArray *pl[], int nr, const mxArray *pr[])
{
	if(nr!=5) mexErrMsgTxt("Five inputs required.");
	if(nl>1) mexErrMsgTxt("At most one output expected.");
	if(mxGetClassID(pr[0])!=mxSINGLE_CLASS) mexErrMsgTxt("I must be a float*");
	
}*/
