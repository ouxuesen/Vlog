//
//  FilePathTool.h
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/13.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilePathTool : NSObject

/// 获取路径
+ (NSString *)getSandBoxFilePath;
/// 删除录屏文件
+ (void)deleteRecordFile;

@end

NS_ASSUME_NONNULL_END
