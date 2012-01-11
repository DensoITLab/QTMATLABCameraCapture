/*
 * QTMATLABCameraCapture
 * qtcamera_capture.c
 *
 * Copyright (c) Yuichi YOSHIDA and Yusuke Sekikawa, 2012/01/10
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida and Yusuke Sekikawa" nor the names of its
 * contributors may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <string.h>
#include "mex.h"
#include "qtcamera_c.h"
#include "CameraWrapper.h"

void mexFunction(int Nreturned, mxArray *returned[], int Noperand, const mxArray *operand[]) {
	mxArray* tmp;
    void* camera;
    tmp = mxGetField(operand[0], 0, "camera_obj");
	
	memcpy((void*)&camera, mxGetPr(tmp), sizeof(void*));
	unsigned char *out_img = NULL;
	
	unsigned char *buf = getBuffer(camera);
	
	int device_id, x, y, h, w, cnt;
	int offsetR, offsetG, offsetB, idx1, idx2;
	mwSize img_size[3];
	
    w = getWidth(camera);
    h = getHeight(camera);
	
    //http://en.wikipedia.org/wiki/YUV#Y.27UV422
    switch (getFormat(camera)) {
        case QtCameraPixelFormatGRAY:
            img_size[0] = h;
            img_size[1] = w;
            img_size[2] = 1;
            returned[0] = mxCreateNumericArray(3, img_size, mxUINT8_CLASS, mxREAL);
            out_img = (unsigned char*)mxGetPr(returned[0]);
            if (buf != NULL) {
                for(y = 0; y < h; y++){
                    for(x = 0; x < w; x++){
                        idx1 = x * h + y;
                        idx2 = (y * w + (w - 1 - x));
                        out_img[idx1] = buf[idx2];
                    }
                }
            }
            else{
                memset(out_img,'0',w*h);
            }
            break;
        case QtCameraPixelFormatY420:
            img_size[0] = h;
            img_size[1] = w;
            img_size[2] = 1;
            returned[0] = mxCreateNumericArray(3, img_size, mxUINT8_CLASS, mxREAL);
            out_img = (unsigned char*)mxGetPr(returned[0]);
            if (buf != NULL) {
                for(y = 0; y < h; y++){
                    for(x = 0; x < w; x++){
                        idx1 = x * h + y;
                        idx2 = (y * w + (w - 1 - x));
                        out_img[idx1] = buf[idx2];
                    }
                }
            }
            else{
                memset(out_img,'0',w*h);
            }
            
            break;
        case QtCameraPixelFormatBGRA:
        default:
            offsetR = w * h * 0;
            offsetG = w * h * 1;
            offsetB = w * h * 2;
            
            img_size[0] = h;
            img_size[1] = w;
            img_size[2] = 3;
            returned[0] = mxCreateNumericArray(3, img_size, mxUINT8_CLASS, mxREAL);
            out_img = (unsigned char*)mxGetPr(returned[0]);
            
            if (buf != NULL) {
                for(y = 0; y < h; y++){
                    for(x = 0; x < w; x++){
                        idx1 = x * h + y;
                        idx2 = (y * w + (w - 1 - x)) * 4;
                        out_img[offsetR + idx1] = buf[idx2 + 2];
                        out_img[offsetG + idx1] = buf[idx2 + 1];
                        out_img[offsetB + idx1] = buf[idx2 + 0];
                    }
                }
            }
            else {
                for(y = 0; y < h; y++){
                    for(x = 0; x < w; x++){
                        idx1 = x * h + y;
                        idx2 = ((h - y - 1) * w + (w - 1 - x)) * 4;
                        out_img[offsetR + idx1] = 0;
                        out_img[offsetG + idx1] = 0;
                        out_img[offsetB + idx1] = 0;
                    }
                }
            }
            break;
    }
    
}