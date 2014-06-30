//
//  CamPreView.h
//  CustomCamTest
//
//  Created by AE on 6/22/14.
//  Copyright (c) 2014 Aaron Eckhart. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AVCaptureSession;

@interface CamPreView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
