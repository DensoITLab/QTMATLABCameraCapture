/*
 * QTMATLABCameraCapture
 * CameraWrapper.m
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

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <Quartz/Quartz.h>

#import "QTCamera.h"

void* create(int width, int height, QtCameraPixelFormat format) {
	QTCamera *camera = [[QTCamera alloc] init];
	[camera setupQTSessionWidth:width height:height format:format];
	return (void*)camera;
}

int getWidth(void *obj) {
	QTCamera *camera = (QTCamera*)obj;
	return [camera width];
}

int getHeight(void *obj) {
	QTCamera *camera = (QTCamera*)obj;
	return [camera height];
}

int getFormat(void *obj){
	QTCamera *camera = (QTCamera*)obj;
	return [camera format];
}


void release(void *obj) {
	QTCamera *camera = (QTCamera*)obj;
	[camera stop];
	[camera release];
}

unsigned char *getBuffer(void *obj) {
	QTCamera *camera = (QTCamera*)obj;
    return [camera buffer];
}