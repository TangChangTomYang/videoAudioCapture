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
@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property(nonatomic, strong)AVCaptureSession *session;
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong)AVCaptureConnection *audioConnection;
@property(nonatomic, strong)AVCaptureDeviceInput *videoInput;
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
}
- (IBAction)stopRecordBtnClick:(id)sender {
    
    [self.session stopRunning];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
}
- (IBAction)changeCamera:(id)sender {
    
    //切换摄像头的主要步骤
    
    // 1 获取之前的摄像头

    // 2 获取当前应该显示的摄像头
    AVCaptureDevice *currentDev = nil;
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *dev in devices) {
        
        if (dev.position != self.videoInput.device.position) {
            currentDev = dev;
            break;
        }
    }
    
    if (currentDev == nil) {
        NSLog(@"没有其他的摄像头可以 使用, 切换摄像头失败");
        return;
    }
    
    // 3 根据当前应该显示的摄像头的Device 创建新的 input
    NSError *err = nil;
   AVCaptureDeviceInput *currentInput = [AVCaptureDeviceInput deviceInputWithDevice:currentDev error:&err];
    if (err) {
        NSLog(@"切换摄像头时 出错");
        return;
    }
    self.session;

    // 4 在Session 中切换input
    //session 的配置需要在这个Session 事物中立配置
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    [self.session addInput:currentInput];
    self.videoInput = currentInput;
    [self.session commitConfiguration];
    
    
    
}


#pragma mark- 私有方法

-(BOOL)setupAudioCature{
    
    // 设置音频的输入（话筒、麦克风）
   AVCaptureDevice *audoiDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (audoiDev == nil) {
        NSLog(@"当前的话筒不可用");
        return NO;
    }
    
    
    // 创建输入源
    NSError *err = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audoiDev error:&err];
    if (err) {
        NSLog(@"设置音频输入源出错");
        return NO;
    }
    
    // 将音频输入源添加到session
    [self.session addInput:audioInput];
    
    
    // 给音频设置音频输出源
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    [audioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    [self.session addOutput:audioOutput];
    self.audioConnection = [audioOutput connectionWithMediaType:AVMediaTypeAudio];
    return YES;
    
    
}


-(BOOL)setupVideoCapture{
    //1、创建捕捉会话
    [self session];
    
    
    //2、给捕捉会话添加输入源
    // 获取前置摄像头和后置摄像头
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if(devices.count == 0){
        NSLog(@"用户当前的摄像头部能使用");
        return NO;
    }
    
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
    AVCaptureDeviceInput *devInput = [AVCaptureDeviceInput deviceInputWithDevice:backGroundDev error:&err];
    self.videoInput = devInput;
    if(err){
        NSLog(@"设置摄像头捕捉输入时出错");
        return NO;
    }
    
    [self.session addInput:devInput];
    
    //3、给捕捉会话设置输出源
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    [self.session addOutput:videoDataOutput];

    
    return YES;
    
}

-(void)setupPreviewLayer{
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    self.previewLayer = previewLayer;
}



#pragma mark- 视频代理
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    
    // 说明这里也可以通过 connection 来区分是音频还是视频的输出
    // 方式1
    
//    if (![audioConnection isEqual:connection]) {
//        NSLog(@"视频数据输出了");
//    }
//    else{
//          NSLog(@"音频输出  音频输出");
//
//    }
    
    
    // 方式2
    // 视频输出
    if ([output isKindOfClass:[AVCaptureVideoDataOutput  class]]) {
         NSLog(@"视频数据输出了");
    }
    // 音频输出
    else if([output isKindOfClass:[AVCaptureAudioDataOutput  class]]){
         NSLog(@"音频输出  音频输出");
        
    }
   
    
}

@end
