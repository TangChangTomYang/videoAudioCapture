//
//  AVAssetExportSession+export.h
//  MyVideo
//
//  Created by edz on 2021/7/29.
//  Copyright © 2021 yangrui. All rights reserved.
//


#import <AVFoundation/AVFoundation.h> 

@interface AVAssetExportSession (export)


// 临时存储(大文件, 原始数据)
+(NSURL *)outputTempVideoFileUrl;

// 最终存储(小文件, 压缩后的数据)
+(NSURL *)outputVideoFileUrl;


// 临时存储(大文件, 原始数据)
+(NSURL *)outputTempAudioFileUrl;

// 最终存储(小文件, 压缩后的数据)
+(NSURL *)outputAudioFileUrl;


+(void)exportVideoFileFromPath:(NSURL *)fileUrl toPath:(NSURL *)toPath;



+(void)exportAudioFileFromPath:(NSURL *)fileUrl toPath:(NSURL *)toPath;
    
@end

 
