//
//  AVAssetExportSession+export.m
//  MyVideo
//
//  Created by edz on 2021/7/29.
//  Copyright © 2021 yangrui. All rights reserved.
//

#import "AVAssetExportSession+export.h"

@implementation AVAssetExportSession (export)


// 临时存储(大文件, 原始数据)
+(NSURL *)outputTempVideoFileUrl{
    long long time = [[NSDate date] timeIntervalSince1970];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld_temp.mp4",time]];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    return fileUrl;
}

// 最终存储(小文件, 压缩后的数据)
+(NSURL *)outputVideoFileUrl{
    long long time = [[NSDate date] timeIntervalSince1970];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.mp4",time]];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    return fileUrl;
}


// 临时存储(大文件, 原始数据)
+(NSURL *)outputTempAudioFileUrl{
    long long time = [[NSDate date] timeIntervalSince1970];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld_temp.mp4",time]];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    return fileUrl;
}

// 最终存储(小文件, 压缩后的数据)
+(NSURL *)outputAudioFileUrl{
    long long time = [[NSDate date] timeIntervalSince1970];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.mp4",time]];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    return fileUrl;
}


+(void)exportVideoFileFromPath:(NSURL *)fileUrl toPath:(NSURL *)toPath{
    
    NSLog(@"-准备--Video--导出ing");
    
    AVAsset *asset = [AVAsset assetWithURL:fileUrl];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset
                                                                           presetName:AVAssetExportPresetMediumQuality];
    
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = toPath;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
         
        if (exportSession.status == AVAssetExportSessionStatusCompleted ) {
            NSLog(@"-----导出 Video ok,at: %@",toPath);
//            BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fileUrl.path];
//            if(isExists){
//                [[NSFileManager defaultManager] removeItemAtPath:fileUrl.path error:nil];
//            }
        }
    }];
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"------导出Video进度: %f", exportSession.progress);
        if(exportSession.progress >= 1){
            [timer invalidate];
        }
    }];
}



+(void)exportAudioFileFromPath:(NSURL *)fileUrl toPath:(NSURL *)toPath{
    
    NSLog(@"-准备--Audio--导出ing");
    
    AVAsset *asset = [AVAsset assetWithURL:fileUrl];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = toPath;
    
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
         
        if (exportSession.status == AVAssetExportSessionStatusCompleted ) {
            NSLog(@"-----导出 Audio ok,at: %@",toPath);
//            BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:fileUrl.path];
//            if(isExists){
//                [[NSFileManager defaultManager] removeItemAtPath:fileUrl.path error:nil];
//            }
        }
    }];
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"------导出Audiov进度: %f", exportSession.progress);
        if(exportSession.progress >= 1){
            [timer invalidate];
        }
    }];
}


@end
