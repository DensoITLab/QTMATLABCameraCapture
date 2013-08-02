#
#  QTMATLABCameraCapture
#  Makefile
# 
#  Copyright (c) Yuichi YOSHIDA and Yusuke Sekikawa, 2012/01/10
#  All rights reserved.
#  
#  BSD License
# 
#  Redistribution and use in source and binary forms, with or without modification, are 
#  permitted provided that the following conditions are met:
#  - Redistributions of source code must retain the above copyright notice, this list of
#   conditions and the following disclaimer.
#  - Redistributions in binary form must reproduce the above copyright notice, this list
#   of conditions and the following disclaimer in the documentation and/or other materia
#  ls provided with the distribution.
#  - Neither the name of the "Yuichi Yoshida and Yusuke Sekikawa" nor the names of its
#  contributors may be used to endorse or promote products derived from this software
#  without specific prior written permission.
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
#  XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
#  F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
#  ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
#  AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
#  UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
#  NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
#  CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
#  HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

MATLAB=/Applications/MATLAB_R2013a.app
mex=$(MATLAB)/bin/mex
CC=/usr/bin/gcc
GPP=/usr/bin/g++
LD=/usr/bin/ld
LDFLAGS=-L$(MATLAB)/bin/maci64 -lm -lmex -lmx -lut
MEX_LDFLAGS='-bundle -exported_symbols_list $(MATLAB)/extern/lib/maci64/mexFunction.map -framework AppKit -framework AGL -framework QTKit -framework CoreVideo'

CFLAGS= -O3

OUTPUTS = qtcamera_create.mexmaci64 qtcamera_release.mexmaci64 qtcamera_capture.mexmaci64
MEX_SOURCE = qtcamera_create.c qtcamera_release.c qtcamera_capture.c qtcamera_c.h CameraWrapper.h QTCamera.o CameraWrapper.o
OBJECTS = QTCamera.o CameraWrapper.o

$(OUTPUTS):$(MEX_SOURCE)
	$(mex) qtcamera_create.c CameraWrapper.o QTCamera.o -L. -f ./mexopts.sh -lobjc LDFLAGS=$(MEX_LDFLAGS) CFLAGS='$(CFLAGS)'
	$(mex) qtcamera_release.c CameraWrapper.o QTCamera.o -L. -f ./mexopts.sh -lobjc -D__MACOSX_CORE__ LDFLAGS=$(MEX_LDFLAGS) CFLAGS='$(CFLAGS)'
	$(mex) qtcamera_capture.c CameraWrapper.o QTCamera.o -L. -f ./mexopts.sh -lobjc -D__MACOSX_CORE__ LDFLAGS=$(MEX_LDFLAGS) CFLAGS='$(CFLAGS)'

QTCamera.o:QTCamera.m qtcamera_c.h
	$(CC) -c QTCamera.m -o QTCamera.o $(CFLAGS) -std=c99

CameraWrapper.o:CameraWrapper.m qtcamera_c.h
	$(CC) -c CameraWrapper.m -o CameraWrapper.o $(CFLAGS) -std=c99 -I$(MATLAB)/extern/include

clean:
	rm -f $(OUTPUTS)
	rm -f $(OBJECTS)
	rm -f libMATLABCamera.a