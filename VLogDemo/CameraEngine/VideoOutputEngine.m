//
//  VideoOutputEngine.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/13.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "VideoOutputEngine.h"
#import "FilePathTool.h"

@interface VideoOutputEngine ()

/**  写入音视频  */
@property (nonatomic, strong) AVAssetWriter *assetWriter;
/**  写入视频输出  */
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
/**  写入音频输出  */
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
/** inputPixelBufferAdptor */
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *inputPixelBufferAdptor;
/**  视频文件地址  */
@property (strong, nonatomic) NSURL *videoURL;
/**  是否可以写入  */
@property (nonatomic, assign) BOOL canWrite;
/**  是否开始录制  */
@property(nonatomic,assign) BOOL isStart;
/** encoderQueue */
@property (nonatomic,strong) dispatch_queue_t encoderQueue;

@end

@implementation VideoOutputEngine

- (void)dealloc {
    self.encoderQueue = nil;
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

- (void)setUpWriter {
    [FilePathTool deleteRecordFile];
    self.videoURL = [NSURL fileURLWithPath:[FilePathTool getSandBoxFilePath]];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    NSError *error = nil;
    self.assetWriter = [AVAssetWriter assetWriterWithURL:self.videoURL fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        NSLog(@"asseetWriter error");
    }
    //写入视频大小
    NSInteger numPixels = width * height;
    //每像素比特
    CGFloat bitsPerPixel = 24.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(15),
                                             AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
                                             };
    AVVideoCodecType type;
    if (@available(iOS 11.0, *)){
        type = AVVideoCodecTypeH264;
    } else {
        type = AVVideoCodecH264;
    }
    //视频属性
    NSDictionary *videoCompressionSettings = @{ AVVideoCodecKey : type,
                                                AVVideoWidthKey : @(width * 2),
                                                AVVideoHeightKey : @(height * 2),
                                                AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                                AVVideoCompressionPropertiesKey : compressionProperties };
    
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
    //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    NSDictionary* sourcePixelBufferAttributesDictionary = @{
      (NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
      (NSString*)kCVPixelBufferWidthKey:@(width),
      (NSString*)kCVPixelBufferHeightKey:@(height),
      (NSString*)kCVPixelFormatOpenGLESCompatibility:@(1)
      };
    
    self.inputPixelBufferAdptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterVideoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    // 音频设置
    NSDictionary *audioCompressionSettings = @{ AVEncoderBitRateKey : @(128000),
                                                AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                AVNumberOfChannelsKey : @(2),
                                                AVSampleRateKey : @(44100)};
    /* 注：
     <1>AVNumberOfChannelsKey 通道数  1为单通道 2为立体通道
     <2>AVSampleRateKey 采样率 取值为 8000/44100/96000 影响音频采集的质量
     <3>d 比特率(音频码率) 取值为 8 16 24 32
     <4>AVEncoderAudioQualityKey 质量  (需要iphone8以上手机)
     <5>AVEncoderBitRateKey 比特采样率 一般是128000
     */
    
    /*另注：aac的音频采样率不支持96000，当设置成8000时，assetWriter也是报错*/
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
    
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    } else {
        NSLog(@"AssetWriter videoInput append Failed");
    }
    
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    } else {
        NSLog(@"AssetWriter audioInput Append Failed");
    }
    
    _canWrite = NO;
}

/**
 *  开始写入数据
 */
- (void)appendPixelBuffer:(CVPixelBufferRef)pixelBuffer time:(CMTime)videoTime{
    if (pixelBuffer == NULL) {
        NSLog(@"empty pixelBuffer");
        return;
    }
    
    @autoreleasepool {
        if (self.assetWriter.status == AVAssetWriterStatusUnknown) {
            BOOL startSuccess = [self.assetWriter startWriting];
            if (!startSuccess) {
                NSLog(@"start Write error %@",self.assetWriter.error);
            }
            if (startSuccess) {
                [self.assetWriter startSessionAtSourceTime:videoTime];
                self.canWrite = YES;
            }
        }
        
        //写入数据
        if (self.inputPixelBufferAdptor.assetWriterInput.isReadyForMoreMediaData) {
            BOOL success = [self.inputPixelBufferAdptor appendPixelBuffer:pixelBuffer withPresentationTime:videoTime];
            if (!success) {
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    if (self.assetWriter.status == AVAssetWriterStatusFailed) {
                        NSLog(@"写入文件失败 %@",self.assetWriter.error);
                    } else if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                        NSLog(@"文件写入完成");
                    }
                    //                        [weakSelf stopVideoRecorder];
                }];
                
                NSLog(@"append pixel buffer faild %@",self.assetWriter.error);
            } else {
                NSLog(@"写入成功");
            }
        }
    }
}

- (void)finishWriteFile {
    if (self.assetWriter.status == AVAssetWriterStatusWriting) {
        [self.assetWriterVideoInput markAsFinished];
    }
}

/**
 *  结束录制视频
 */
- (void)stopVideoRecorder {
    __weak __typeof(self)weakSelf = self;
    
    if(_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting) {
        [_assetWriter finishWritingWithCompletionHandler:^{
            weakSelf.canWrite = NO;
            weakSelf.assetWriter = nil;
            weakSelf.assetWriterAudioInput = nil;
            weakSelf.assetWriterVideoInput = nil;
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf saveVideo];
    });
}

- (void)saveVideo {
    
}

- (dispatch_queue_t)encoderQueue {
    if (!_encoderQueue) {
        _encoderQueue = dispatch_queue_create("encoderQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _encoderQueue;
}

- (NSURL *)outputFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *outPutFileName = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",outPutFileName]];
    NSURL* outPutVideoUrl = [NSURL fileURLWithPath:myPathDocs];
    return outPutVideoUrl;
}

@end
