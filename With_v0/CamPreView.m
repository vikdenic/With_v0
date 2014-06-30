//
//  CamPreView.m
//  CustomCamTest
//
//  Created by AE on 6/22/14.
//  Copyright (c) 2014 Aaron Eckhart. All rights reserved.
//

#import "CamPreView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CamPreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/






+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
	return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
	[(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}



@end
