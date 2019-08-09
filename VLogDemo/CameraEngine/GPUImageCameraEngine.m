//
//  GPUImageCameraEngine.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/11.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "GPUImageCameraEngine.h"

@interface GPUImageCameraEngine()

/** videoCamera */
@property (nonatomic,strong) GPUImageVideoCamera *videoCamera;
/** movieWriter */
@property (nonatomic,strong) GPUImageMovieWriter *movieWriter;
/** filter */
@property (nonatomic,strong) GPUImageFilter *filter;

@end

@implementation GPUImageCameraEngine

- (void)dealloc {
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

- (void)setupGPUImageCamera:(GPUImageView *)cameraView {
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    // 添加加载输入输出流 --> 解决第一帧视频黑屏的问题
    [self.videoCamera addAudioInputsAndOutputs];
    if ([self.videoCamera.inputCamera lockForConfiguration:nil]) {
        //自动对焦
        if ([self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //自动白平衡
        if ([self.videoCamera.inputCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [self.videoCamera.inputCamera unlockForConfiguration];
    }
    // 创建渲染滤镜
    self.filter = [[GPUImageFilter alloc] init];
    [self.videoCamera addTarget:self.filter];
    [self.filter addTarget:cameraView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoCamera startCameraCapture];
    });
}

- (void)setupMovieWriter {
    NSURL *fileUrl = [NSURL fileURLWithPath:[self getSandBoxFilePath]];
    unlink([fileUrl.absoluteString UTF8String]);
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:fileUrl size:CGSizeMake(480, 640)];
    self.movieWriter.encodingLiveVideo = YES;
    self.movieWriter.shouldPassthroughAudio = YES;
    // 绑定音频编码目标
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    /// 重点 将屏幕显示滤镜添加到 输出流
    /// 到时候如果添加了水印这里的滤镜就是 结合屏幕水印的滤镜
    [self.filter addTarget:self.movieWriter];
}

- (void)startRecorder {
    [self deleteRecordFile];
    double delayToStartRecording = 0.5;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Start recording");
        [self.movieWriter startRecording];
    });
}

- (void)stopRecorder {
    [self.filter removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
    NSLog(@"Movie completed, comple Video");
}

- (void)startCapture {
    [self.videoCamera startCameraCapture];
}

- (void)stopCapture {
    if (self.videoCamera) {
        [self.videoCamera stopCameraCapture];
        [self.videoCamera removeAllTargets];
        [self.videoCamera removeInputsAndOutputs];
    }
}

- (void)dellocCamera {
    self.videoCamera = nil;
}

/// 获取路径
- (NSString *)getSandBoxFilePath {
    NSString *videoFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/video.mov"];
    NSLog(@"文件路径 %@",videoFilePath);
    return videoFilePath;
}

/// 删除录屏文件
- (void)deleteRecordFile {
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
