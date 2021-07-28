//
//  PreviewViewController.m
//  MyVideo
//
//  Created by edz on 2021/7/28.
//  Copyright © 2021 yangrui. All rights reserved.
//

#import "PreviewViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PreviewViewController ()

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation PreviewViewController


 

-(void)initSetUpSession{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    
    [self setupVideoCapture];
    
    [self setupPreviewLayer];
     
}

-(void)setupVideoCapture{
    NSArray<AVCaptureDevice *> *devArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *cameraDev = nil;
    for (int i = 0; i < devArr.count; i++) {
        cameraDev = devArr[i];
        if (AVCaptureDevicePositionBack == cameraDev.position) {
            break;
        }
    }
    if (cameraDev == nil) {
        return;
    }
    
    NSError *err = nil;
    AVCaptureDeviceInput *cameraDevInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDev error:&err];
    if (err) {
        return;
    }
    
    [self.session beginConfiguration];
    if ([self.session canAddInput:cameraDevInput]) {
        [self.session addInput:cameraDevInput];
    }
    [self.session commitConfiguration];
    
}

-(void)setupPreviewLayer{
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:previewLayer];
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
    
}

-(void)startPreview{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

-(void)stopPreview{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
     
    [self initSetUpSession];
     
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
     
    [self stopPreview];
}




- (IBAction)startBtnClick:(id)sender {
    [self startPreview];
}

- (IBAction)stopBtnClick:(id)sender {
    [self stopPreview];
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
