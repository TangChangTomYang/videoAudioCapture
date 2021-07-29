//
//  ExportAudioViewController.m
//  MyVideo
//
//  Created by edz on 2021/7/27.
//  Copyright © 2021 yangrui. All rights reserved.
//

#import "ExportAudioViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAssetExportSession+export.h"


@interface ExportAudioViewController ()<AVCaptureFileOutputRecordingDelegate>
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureInput *audioDevInput;
@property(nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property(nonatomic, strong) NSTimer *timer;


@end

@implementation ExportAudioViewController



-(void)setUpSession{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
}

-(void)setUpAudioDevInput{
    AVCaptureDevice *audioDev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    NSError *err = nil;
    AVCaptureInput *audioDevInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDev error:&err];
    if (err) {
        NSLog(@"setUpAudioDevInput err: %@", err.localizedDescription);
        return;
    }
    
    [self.session beginConfiguration];
    if ([self.session canAddInput:audioDevInput]) {
        [self.session addInput:audioDevInput];
        self.audioDevInput = audioDevInput;
    }
    [self.session commitConfiguration];
}

-(void)setUpfileOutput{
    
    
    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.session beginConfiguration];
    if ([self.session canAddOutput:movieFileOutput]) {
        [self.session addOutput:movieFileOutput];
        self.movieFileOutput = movieFileOutput;
    }
    [self.session commitConfiguration];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpSession];
    [self setUpAudioDevInput];
    [self setUpfileOutput];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    
    [self stopStore];
    [self stopCapture];
    
}


-(void)startCapture{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

-(void)stopCapture{
    [self stopStore];
    if ([self.session isRunning]) {
        [self.session startRunning];
    }
}

-(void)startStore{
    if (![self.movieFileOutput isRecording]) {
        [self.movieFileOutput startRecordingToOutputFileURL:[AVAssetExportSession outputAudioFileUrl] recordingDelegate:self];
        
        [self startTimer];
    }
}

-(void)startTimer{
    [self emptyTimer];
    len = 0;
   self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
}

-(void)emptyTimer{
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}
static int len = 0;
-(void)timerAction{
    NSLog(@"------len: %d", ++len);
}


-(void)stopStore{
    if ([self.movieFileOutput isRecording]) {
        [self.movieFileOutput stopRecording];
    }
}



- (IBAction)startCaptureBtnClick:(id)sender {
    [self startCapture];
    NSLog(@"开始采集声音");
}




 
- (IBAction)stopCaptureBtnClick:(id)sender {
    [self stopCapture];
    NSLog(@"停止采集声音");
    
}
- (IBAction)startStoreBtnClick:(id)sender {
    [self startStore];
    NSLog(@"开始存储声音");
}

- (IBAction)stopStoreBtnClick:(id)sender {
    [self stopStore];
    NSLog(@"停止存储声音");
}

- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark- AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
      fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    NSLog(@"---开始存储audio: %@",fileURL.path);
    
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
   
    NSLog(@"---停止存储audio: %@",outputFileURL.path);
    
    [AVAssetExportSession exportAudioFileFromPath:outputFileURL toPath:[AVAssetExportSession  outputAudioFileUrl]];
 
    
    
}




 

@end
