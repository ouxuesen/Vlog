//
//  WatermarkEngine.h
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/10.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WatermarkEngine : NSObject

/// 视频添加水印、背景音乐、动画名
- (void)addWaterMarkTypeWithLottieAndInputVideoURL:(NSURL*)inputURL
                                          musicUrl:(NSURL *)musicinputURL
                               lottieAnimationName:(NSString *)animationName
                             WithCompletionHandler:(void (^)(NSURL* outPutURL, int code))handler;

@end

NS_ASSUME_NONNULL_END
