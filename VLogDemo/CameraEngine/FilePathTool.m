//
//  FilePathTool.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/13.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "FilePathTool.h"

@implementation FilePathTool

/// 获取路径
+ (NSString *)getSandBoxFilePath {
    NSString *videoFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/video.mp4"];
    NSLog(@"文件路径 %@",videoFilePath);
    return videoFilePath;
}

/// 删除录屏文件
+ (void)deleteRecordFile {
    NSString *filePath = [self getSandBoxFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"删除文件出错 %@",error);
        } else {
            NSLog(@"删除文件成功");
        }
    }
}

@end
