//
//  WatermarkEngine.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/10.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "WatermarkEngine.h"
#import <Lottie/Lottie.h>
#import <AVFoundation/AVFoundation.h>

@implementation WatermarkEngine

- (void)dealloc {
    NSLog(@"DELLOC : %@",NSStringFromClass(self.class));
}

- (void)addWaterMarkTypeWithLottieAndInputVideoURL:(NSURL *)inputURL musicUrl:(NSURL *)musicinputURL lottieAnimationName:(NSString *)animationName WithCompletionHandler:(void (^)(NSURL * _Nonnull, int))handler {
    if (!inputURL.absoluteString.length || !musicinputURL.absoluteString.length) {
        return;
    }
    // 初始化视频媒体文件
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(YES) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVAsset *videoAsset = [AVURLAsset URLAssetWithURL:inputURL options:opts];
    // 插入背景音频
    AVAsset *audioAsset = [AVAsset assetWithURL:musicinputURL];
    // 创建 AVMutableComposition 实例
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    // 视频通道 工程文件中的轨道，有音频轨、视频轨，里边可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    // 把视频轨道数据加入到可变轨道中
    NSError *errorVideo = nil;
    AVAssetTrack *assetVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CMTime endTime = assetVideoTrack.asset.duration;
    BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)
                                  ofTrack:assetVideoTrack
                                   atTime:kCMTimeZero error:&errorVideo];
    NSLog(@"errorVideo:%ld error = %d",errorVideo.code,bl);
    
    // 插入音频通道
    NSError *audioError = nil;
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:&audioError];
    // 视频原声通道
    NSError *originalAudioError = nil;
    AVMutableCompositionTrack *originalAudioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *originalAudioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [originalAudioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration) ofTrack:originalAudioAssetTrack atTime:kCMTimeZero error:&originalAudioError];
    if (originalAudioError) {
        NSLog(@"视频原声插入失败 %@",originalAudioError);
    }
    if (audioError) {
        NSLog(@"audio Error %@",audioError);
    }
    
    //修改背景音乐的音量start
    AVMutableAudioMix *videoAudioMixTools = [AVMutableAudioMix audioMix];
    if (audioAsset) {
        //调节音量
        //获取音频轨道
        AVMutableAudioMixInputParameters *firstAudioParam = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        //设置音轨音量,可以设置渐变,设置为1.0就是全音量
        [firstAudioParam setVolumeRampFromStartVolume:.5 toEndVolume:.5 timeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)];
        [firstAudioParam setTrackID:audioTrack.trackID];
        videoAudioMixTools.inputParameters = [NSArray arrayWithObject:firstAudioParam];
    }
    
    // AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, endTime);
    
    // AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = assetVideoTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait_ = YES;
    }
    
    [videoLayerInstruction setTransform:assetVideoTrack.preferredTransform atTime:kCMTimeZero];
    [videoLayerInstruction setOpacity:0.0 atTime:endTime];
    // 添加 instructions
    instruction.layerInstructions = [NSArray arrayWithObjects:videoLayerInstruction, nil];
    
    // AVMutableVideoComposition 管理所有视频轨道,可以决定最终视频尺寸，裁剪需要在这里进行
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    CGSize videoSize;
    if (isVideoAssetPortrait_) {
        videoSize = CGSizeMake(assetVideoTrack.naturalSize.height, assetVideoTrack.naturalSize.width);
    } else {
        videoSize = assetVideoTrack.naturalSize;
    }
    videoComp.renderSize = videoSize;
    videoComp.instructions = [NSArray arrayWithObject:instruction];
    videoComp.frameDuration = CMTimeMake(1, 30);
    [self applyVideoEffectsToComposition:videoComp size:videoSize lottieAnimation:animationName];
    
    // 视频输出地址
    NSURL* outPutVideoUrl = [self outputFilePath];
    
    AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=outPutVideoUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComp;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"输出视频地址:%@ andCode:%@",outPutVideoUrl.absoluteString,exporter.error);
            handler(outPutVideoUrl,(int)exporter.error.code);
        });
    }];
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

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)videoSize lottieAnimation:(NSString *)animationName{
    LOTAnimationView* animation = [LOTAnimationView animationNamed:animationName];
    animation.frame = CGRectMake(0,0, videoSize.width , videoSize.height);
    animation.animationSpeed = 1.0 ;
    animation.loopAnimation = YES;
    [animation play];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:animation.layer];
    parentLayer.geometryFlipped = true;
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    NSLog(@"nnn");
}

@end
