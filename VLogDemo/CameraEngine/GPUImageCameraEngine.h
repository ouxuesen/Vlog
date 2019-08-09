//
//  GPUImageCameraEngine.h
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/11.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageCameraEngine : NSObject

- (void)setupGPUImageCamera:(GPUImageView *)cameraView;
- (void)setupMovieWriter;
- (void)stopCapture;
- (void)dellocCamera;

- (void)startRecorder;
- (void)stopRecorder;

- (NSString *)getSandBoxFilePath;
@end

NS_ASSUME_NONNULL_END
