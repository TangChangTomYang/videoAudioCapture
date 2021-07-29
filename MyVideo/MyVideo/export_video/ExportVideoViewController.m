//
//  ExportVideoViewController.m
//  MyVideo
//
//  Created by edz on 2021/7/27.
//  Copyright © 2021 yangrui. All rights reserved.
//

#import "ExportVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAssetExportSession+export.h"


@interface ExportVideoViewController ()<AVCaptureFileOutputRecordingDelegate>
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureDeviceInput *currentCameraDevInput;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property(nonatomic, strong) NSTimer *timer;
  

@end

@implementation ExportVideoViewController

 
-(void)initSetUpSession{
    [self setupSession];

    [self setupVideoCaptureDevice];
    [self setupAudioCaptureDevice];
    [self setupPreviewLayer];
    
    [self setupMovieFileOutput];
}

-(void)setupSession{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if([session canSetSessionPreset:AVCaptureSessionPresetHigh]){
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    self.session = session;
}

-(void)setupVideoCaptureDevice{
    
    AVCaptureDeviceInput *cameraDevInput = [self createCameraDeviceInputWithPositon:AVCaptureDevicePositionBack];
     
    if (cameraDevInput) {
        [self.session beginConfiguration];
        if ([self.session canAddInput:cameraDevInput]) {
            [self.session addInput:cameraDevInput];
            self.currentCameraDevInput = cameraDevInput;
        }
        [self.session commitConfiguration];
    }
}

-(void)setupAudioCaptureDevice{
    AVCaptureDevice *audioDivice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    NSError *err = nil;
    AVCaptureDeviceInput *audioDiviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDivice error:&err];
    if (err != nil) {
        return;
    }
    [self.session beginConfiguration];
    if ([self.session canAddInput:audioDiviceInput]) {
        [self.session addInput:audioDiviceInput];
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

-(void)setupMovieFileOutput{
    AVCaptureMovieFileOutput *movieFileOutput =  [[AVCaptureMovieFileOutput alloc] init];
    // 解决时长超过10s没声音问题
    movieFileOutput.movieFragmentInterval = kCMTimeInvalid;
    [self.session beginConfiguration];
    if ([self.session canAddOutput:movieFileOutput]) {
        [self.session addOutput:movieFileOutput];
        self.movieFileOutput = movieFileOutput;
    }
    [self.session commitConfiguration];
     
}

-(AVCaptureDeviceInput *)createCameraDeviceInputWithPositon:(AVCaptureDevicePosition )postion{
    
    NSArray<AVCaptureDevice *> *devArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *cameraDev = nil;
    for (int i = 0; i < devArr.count; i++) {
        cameraDev = devArr[i];
        if (postion == cameraDev.position) {
            break;
        }
    }
    if (cameraDev == nil) {
        return nil;
    }
    
    
    NSError *err = nil;
    AVCaptureDeviceInput *cameraDevInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDev error:&err];
    if (err) {
        NSLog(@"切换摄像头时 出错");
        return nil;
    }
    
    return cameraDevInput;
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
    
    if([self.movieFileOutput isRecording]){
        [self stopStore];
    }
    if ([self.session isRunning]) {
        [self stopCapture];
    }
}




-(void)exchangeCameraPosition{
    
    if (self.currentCameraDevInput) {
        
        AVCaptureDevice *cameraDevice = [self.currentCameraDevInput device];
        AVCaptureDevicePosition position = AVCaptureDevicePositionBack; ;
        if (position == cameraDevice.position) {
            position = AVCaptureDevicePositionFront;
        }
        
        AVCaptureDeviceInput *cameraDevInput = [self createCameraDeviceInputWithPositon:position];
        [self.session beginConfiguration];
        [self.session removeInput:self.currentCameraDevInput];
        if ([self.session canAddInput:cameraDevInput]) {
            [self.session addInput:cameraDevInput];
            self.currentCameraDevInput = cameraDevInput;
        }
        [self.session commitConfiguration];
         
    }
    
}

// 开始采集
-(void)startCapture{
   if (![self.session isRunning]) {
       [self.session startRunning];
   }
}

// 停止采集
-(void)stopCapture{
   if ([self.session isRunning]) {
       [self.session stopRunning];
   }
}

// 开始存储
-(void)startStore{
    if ([self.session isRunning]) {
         
        /*
         UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
         AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)devOrientation;
         if (devOrientation == UIDeviceOrientationLandscapeLeft) {
             videoOrientation = AVCaptureVideoOrientationLandscapeRight;
         }
         else if(devOrientation == UIDeviceOrientationLandscapeRight){
             videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
         }
         AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
         connection.videoOrientation = videoOrientation;
         */
        if ([self.movieFileOutput isRecording] == NO) {
            NSURL *fileUrl = [AVAssetExportSession  outputTempVideoFileUrl];
            [self.movieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        }
    }
}

// 停止存储
-(void)stopStore{
    if([self.movieFileOutput isRecording]){
        [self.movieFileOutput stopRecording];
    }
}




#pragma mark- 点击事件

- (IBAction)startCaptureBtnClick:(id)sender {
    [self startCapture];
    NSLog(@"-----开始采集");
}


- (IBAction)stopCaptureBtnClick:(id)sender {
    [self stopCapture];
    NSLog(@"-----停止采集");
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)frontBackBtnClick:(id)sender {
    
    [self exchangeCameraPosition];
    NSLog(@"-----切换摄像头");
}

static long len = 0;
- (IBAction)startStoreBtnClick:(id)sender {
    [self startStore];
    NSLog(@"-----开始存储");
    
    [self emptyTimer];
    len = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

-(void)timerAction{
    NSLog(@"-----len: %ld", ++len);
}


- (IBAction)stopStoreBtnClick:(id)sender {
    [self stopStore];
    [self emptyTimer];
    NSLog(@"-----停止存储");
}

-(void)emptyTimer{
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}



#pragma mark- <AVCaptureFileOutputRecordingDelegate> 代理
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
      fromConnections:(NSArray<AVCaptureConnection *> *)connections{
     
    NSLog(@"-----didStartRecordingToOutputFileAtURL: %@--",fileURL.path);
    
}
 

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    NSLog(@"-----didFinishRecordingToOutputFileAtURL: %@--",outputFileURL.path);
    
    
    [AVAssetExportSession exportVideoFileFromPath:outputFileURL toPath:[AVAssetExportSession  outputVideoFileUrl]];
 
    
    
}



//-(void)exportVideoFromPath:(NSURL *)fileUrl toPath:(NSURL *)toPath{
//
//    NSLog(@"-准备----导出ing");
//
//    AVAsset *asset = [AVAsset assetWithURL:fileUrl];
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset
//                                                                           presetName:AVAssetExportPresetMediumQuality];
//    exportSession.outputFileType = AVFileTypeMPEG4;
//    exportSession.shouldOptimizeForNetworkUse = YES;
//    exportSession.outputURL = toPath;
//    [exportSession exportAsynchronouslyWithCompletionHandler:^{
//
//        if (exportSession.status == AVAssetExportSessionStatusCompleted ) {
//            NSLog(@"-----导出 ok,at: %@",toPath);
//            BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fileUrl.path];
//            if(isExists){
//                [[NSFileManager defaultManager] removeItemAtPath:fileUrl.path error:nil];
//            }
//        }
//    }];
//
//
//    [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"------导出进度: %f", exportSession.progress);
//        if(exportSession.progress >= 1){
//            [timer invalidate];
//        }
//    }];
//}



 
@end
