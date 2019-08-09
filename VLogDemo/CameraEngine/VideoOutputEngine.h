//
//  VideoOutputEngine.h
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/13.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoOutputEngine : NSObject

- (void)setUpWriter;
- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer time:(CMTime)videoTime;
- (void)finishWriteFile;

@end

NS_ASSUME_NONNULL_END
