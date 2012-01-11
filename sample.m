%
%  QTMATLABCameraCapture
%  sample.m
% 
%  Copyright (c) Yuichi YOSHIDA and Yusuke Sekikawa, 12/01/10.
%  All rights reserved.
%  
%  BSD License
% 
%  Redistribution and use in source and binary forms, with or without modification, are 
%  permitted provided that the following conditions are met:
%  - Redistributions of source code must retain the above copyright notice, this list of
%   conditions and the following disclaimer.
%  - Redistributions in binary form must reproduce the above copyright notice, this list
%   of conditions and the following disclaimer in the documentation and/or other materia
%  ls provided with the distribution.
%  - Neither the name of the "Yuichi Yoshida and Yusuke Sekikawa" nor the names of its 
%  contributors may be used to endorse or promote products derived from this software
%  thout specific prior written permission.
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
%  XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
%  F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
%  ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
%  AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
%  UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
%  NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
%  CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
%  HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

% qtcamera_create(widht,height,mode)
%
% width height
% 0 for default size
%
% mode 
% 0: default(RGB)
% 1: W*H--Y     (WhiteIsZero)
% 2: W*H--RGB
% 3: W*H--Y +   W/2*H/2--U    +   W/2*H/2--V
% Other :same as default.
% Note.Mode 2 and 4 is faster than others.

mode=1;
width=0;
height=0;
camera = qtcamera_create(width,height,mode);

frames = 200;

for i=1:frames
    image = qtcamera_capture(camera);
    imshow(image);
    title(sprintf('%d / %d',i,frames));
    pause(0.01);
end
qtcamera_release(camera);
