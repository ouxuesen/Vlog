//
//  SampleBufferTransformTool.h
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/13.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleBufferTransformTool : NSObject

/// UIImage转CMSampleBufferRef
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;
/// CMSampleBufferRef转UIImage
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
/// 图片合成
- (UIImage *)addImage:(UIImage*)image1 toImage:(UIImage*)image2;
/// 存入相册
- (void)exportDidFinish:(NSURL*)outputURL complete:(void (^)(BOOL complete,NSString *errorMsg))completeHander;

@end

NS_ASSUME_NONNULL_END
