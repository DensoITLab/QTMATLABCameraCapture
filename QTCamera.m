/*
 * QTMATLABCameraCapture
 * QTCamera.m
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

#import <QTKit/QTKit.h>
#import "QTCamera.h"

@implementation QTCamera

- (void)setupQTSessionWidth:(int) width height:(int)height format:(QtCameraPixelFormat)format{
    int cameraNum=0;
    _buffer=NULL;
    _bufSize=0;
    _format = format;
	NSLog(@"QTCamera setupQTSession");
	NSAutoreleasePool* localpool = [NSAutoreleasePool new];
    
	QTCaptureDevice *device; 
	NSArray* devices = [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo];
	if ([devices count] == 0) {
        NSLog(@"error-1");
        goto EXCEPTION;
	}
	
	if (cameraNum >= 0) {
		int nCameras = [devices count];
        if( cameraNum < 0 || cameraNum >= nCameras )
            goto EXCEPTION;
		device = [devices objectAtIndex:cameraNum] ;
	} else {
		device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo]  ;
	}
	int success; 
	NSError* error; 
	
    if (device) {
		
		success = [device open:&error];
        if (!success) {
            NSLog(@"error-1");
            goto EXCEPTION;
        }
		
		_input = [[QTCaptureDeviceInput alloc] initWithDevice:device] ;
		_session = [[QTCaptureSession alloc] init] ;
		
        success = [_session addInput:_input error:&error];		
		
		if (!success) {
            NSLog(@"error-1");
            goto EXCEPTION;
        }
		
		
		_output = [[QTCaptureDecompressedVideoOutput alloc] init];
		[_output setDelegate:self]; 
		NSDictionary *pixelBufferOptions ;
        
        NSNumber *colorMode;
        
        switch (format) {
            case QtCameraPixelFormatGRAY:
                colorMode=[NSNumber numberWithUnsignedInt:kCVPixelFormatType_8IndexedGray_WhiteIsZero];
                break;
            // case QtCameraPixelFormat2VUY:
            //     colorMode=[NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8];
            //     break;
            case QtCameraPixelFormatY420:
                colorMode=[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8Planar];
                break;
            default:
                colorMode=[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
                break;
        }
        
		if (width > 0 && height > 0) {
			pixelBufferOptions = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithDouble:1.0*width], (id)kCVPixelBufferWidthKey,
								  [NSNumber numberWithDouble:1.0*height], (id)kCVPixelBufferHeightKey,
								  colorMode,
								  (id)kCVPixelBufferPixelFormatTypeKey,
								  nil]; 
		} else {
			pixelBufferOptions = [NSDictionary dictionaryWithObjectsAndKeys:
								  colorMode, 
								  (id)kCVPixelBufferPixelFormatTypeKey,
								  nil]; 
		}
		[_output setPixelBufferAttributes:pixelBufferOptions]; 
		
#if QTKIT_VERSION_MAX_ALLOWED >= QTKIT_VERSION_7_6_3
		[_output setAutomaticallyDropsLateVideoFrames:YES]; 
#endif	
        success = [_session addOutput:_output error:&error];
        if (!success) {
            NSLog(@"error-5");
            goto EXCEPTION;
        }
		
		[_session startRunning];
	}
    [localpool release]; 
    return;
    
EXCEPTION:
    if (_session)
        [_session release];
    if (_input)
        [_input release];
    if (_output) {
        [_output setDelegate:nil]; 
        [_output release];
    }
	[localpool release];
}

- (void)stop {
	[_session stopRunning];
}

- (void)dealloc {
    
    NSAutoreleasePool* localpool = [NSAutoreleasePool new];
	
	QTCaptureDevice *device = [_input device];
    if ([device isOpen])
        [device close];
	
	[_session release];
    [_input release];
	[_output setDelegate:nil]; 
	[_output release];
    
	[localpool release]; 
    [super dealloc];
    
    if(_buffer)
        free(_buffer);
}

- (int)width {
	return _width;
}

- (int)height {
	return _height;
}
- (int)format {
	return _format;
}

- (unsigned char*)buffer {
	return _buffer;
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput 
  didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	 withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	   fromConnection:(QTCaptureConnection *)connection {
	
    CVBufferRetain(videoFrame);
    CVImageBufferRef imageBuffer  = videoFrame;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    size_t datasize = CVPixelBufferGetDataSize(imageBuffer);
    if (_buffer == NULL || _bufSize < datasize) {
        _buffer = (unsigned char*)malloc(sizeof(unsigned char) * datasize);
        _width = (int)width;
        _height = (int)height;
        _bufSize= (int)datasize;
    }
    switch (_format) {
        // case QtCameraPixelFormat2VUY:
        // {
        //     unsigned char* baseAddress=(unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        //     for(int cnt = 0; cnt < width * height; cnt++){
        //         _buffer[cnt] = baseAddress[2*cnt+1];                
        //     }
        //     for(int cnt = 0; cnt < width * height/2; cnt++){
        //         _buffer[cnt+width*height] = baseAddress[4*cnt];
        //         _buffer[cnt+width*height+width*height/2] = baseAddress[4*cnt+2];
        //     }
        // }
        //     break;
        case QtCameraPixelFormatY420:
            memcpy(_buffer, CVPixelBufferGetBaseAddressOfPlane(imageBuffer,0), sizeof(unsigned char) * width * height);
            // memcpy(_buffer+width*height, CVPixelBufferGetBaseAddressOfPlane(imageBuffer,1), sizeof(unsigned char) * width * height/4);
            // memcpy(_buffer+width*height+width*height/4, CVPixelBufferGetBaseAddressOfPlane(imageBuffer,2), sizeof(unsigned char) * width * height/4);
            break;
        case QtCameraPixelFormatGRAY:
        default:
        {   
            unsigned char* baseAddress=(unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
            memcpy(_buffer, baseAddress, sizeof(unsigned char) * datasize);
        }
            break;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CVBufferRelease(imageBuffer);
}
@end
