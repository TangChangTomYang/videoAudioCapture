//
//  ViewController.m
//  MyVideo
//
//  Created by yangrui on 2018/4/9.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


/** 捕捉视频
 */
@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, // 视频输出代理
                            AVCaptureAudioDataOutputSampleBufferDelegate,  // 音频输出代理
                            AVCaptureFileOutputRecordingDelegate           // 文件写入代理(直接将采集到的视频写入文件)
                            >

@property(nonatomic, strong)AVCaptureSession *session;
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong)AVCaptureDeviceInput *camaraDevInput;
@property(nonatomic, strong)AVCaptureVideoDataOutput *videoDataOutput;
@property(nonatomic, strong)AVCaptureMovieFileOutput *videoFileOutput ;
@end

@implementation ViewController


-(AVCaptureSession *)session{
    
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}


- (IBAction)startRecordBtnClick:(id)sender {
    //1、 设置视频的输入和输出
    [self setupVideoCapture];
    
    //2、 设置音频的输入输出
    [self setupAudioCature];
    
    //4、给用户一个预览图层
    [self setupPreviewLayer];
    
    //5、开始采集
    [self.session startRunning];
    
    [self saveViewDataOutputToFile];
}
- (IBAction)stopRecordBtnClick:(id)sender {
    // 停止文件写入
    [self.videoFileOutput  stopRecording];
    
    [self.session stopRunning];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
}


/** 将采集到的输出写入文件  */
-(void)saveViewDataOutputToFile{
    
    // 创建写入文件的输出
    AVCaptureMovieFileOutput *videoFileOutput = [[AVCaptureMovieFileOutput alloc]init];
    AVCaptureConnection *connection = [videoFileOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setAutomaticallyAdjustsVideoMirroring:YES];
    
    [self.session beginConfiguration];
    if([self.session canAddOutput:videoFileOutput]){
        [self.session addOutput:videoFileOutput];
    }
    [self.session commitConfiguration];
    
    self.videoFileOutput =  videoFileOutput;
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.mp4"];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [videoFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
}


#pragma mark- 私有方法




-(BOOL)setupVideoCapture{
    //1、创建捕捉会话
    
    //2、创建输入源
   // NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devices];
    // 从前置摄像和后置摄像中选择后置摄像头
    AVCaptureDevice *backGroundDev = nil;
    for (AVCaptureDevice *dev  in devices) {
        if(AVCaptureDevicePositionBack  == dev.position){
            backGroundDev = dev;
            break;
        }
    }
    if(backGroundDev == nil){
        NSLog(@"当前后置摄像头不能使用");
        return NO;
    }
    NSError *err = nil;
    AVCaptureDeviceInput *camaraDevInput = [AVCaptureDeviceInput deviceInputWithDevice:backGroundDev error:&err];
    
    if(err){
        NSLog(@"设置摄像头捕捉输入时出错");
        return NO;
    }
    self.camaraDevInput = camaraDevInput;
    
    
    //3、创建输出源
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    self.videoDataOutput = videoDataOutput;
   
    //4. 添加输入输出源
    [self addDevInPut:camaraDevInput dataOutput:videoDataOutput];
    
    
    return YES;
    
}

- (IBAction)changeCamera:(id)sender {
    
    //切换摄像头的主要步骤
    
    // 1 获取之前的摄像头
    
    // 2 获取当前应该显示的摄像头
    AVCaptureDevice *currentCameraDev = nil;
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *cameraDev in devices) {
        
        if (cameraDev.position != self.camaraDevInput.device.position) {
            currentCameraDev = cameraDev;
            break;
        }
    }
    
    if (currentCameraDev == nil) {
        NSLog(@"没有其他的摄像头可以 使用, 切换摄像头失败");
        return;
    }
    
    // 3 根据当前应该显示的摄像头的Device 创建新的 input
    NSError *err = nil;
    AVCaptureDeviceInput *cameraDevInput = [AVCaptureDeviceInput deviceInputWithDevice:currentCameraDev error:&err];
    if (err) {
        NSLog(@"切换摄像头时 出错");
        return;
    }
    
    
    // 4 在Session 中切换input
    [self.session beginConfiguration];
    
    [self.session removeInput:self.camaraDevInput];
    // 添加输入源
    if ([self.session canAddInput:cameraDevInput]) {
        [self.session addInput:cameraDevInput];
        self.camaraDevInput = cameraDevInput;
    }
    
    [self.session commitConfiguration];
    
    
}


#pragma mark- 私有方法

/** 添加输入 输入源*/
-(void)addDevInPut:(AVCaptureInput *)input dataOutput:(AVCaptureOutput *)dataOutPut{
    [self.session beginConfiguration];
    // 添加输入源
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    if([self.session canAddOutput:dataOutPut]){
        [self.session addOutput:dataOutPut];
    }
    
    [self.session commitConfiguration];
    
}


/** 设置预览图层*/
-(void)setupPreviewLayer{
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
}


-(BOOL)setupAudioCature{
    
    // 设置音频的输入（话筒、麦克风）
    AVCaptureDevice *audoiDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (audoiDev == nil) {
        NSLog(@"当前的话筒不可用");
        return NO;
    }
    
    
    // 创建输入源
    NSError *err = nil;
    AVCaptureDeviceInput *audioDevInput = [AVCaptureDeviceInput deviceInputWithDevice:audoiDev error:&err];
    if (err) {
        NSLog(@"设置音频输入源出错");
        return NO;
    }
    
    // 创建音频设置音频输出源
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    
    [self addDevInPut:audioDevInput dataOutput:audioOutput];
    
    return YES;
    
    
}


#pragma mark- 视频代理
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    

    if ([[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] isEqual:connection]) {
         NSLog(@"视频数据输出了");
    }
    else{
        
          NSLog(@"音频输出  音频输出");
    }
    
    
}

#pragma mark- AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
    
    NSLog(@"开始写入文件");
}

- (void)captureOutput:(AVCaptureFileOutput *)output didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections NS_AVAILABLE_MAC(10_7){
    
     NSLog(@"暂停写入文件");
}

- (void)captureOutput:(AVCaptureFileOutput *)output didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections NS_AVAILABLE_MAC(10_7){
      NSLog(@"恢复 写入文件");
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    
      NSLog(@"结束写入文件");
}

@end
