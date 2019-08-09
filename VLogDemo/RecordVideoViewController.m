//
//  RecordVideoViewController.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/6.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "RecordVideoViewController.h"
#import <Lottie/Lottie.h>
#import <GPUImage.h>
#import "WatermarkEngine.h"
#import "GPUImageCameraEngine.h"
#import <SVProgressHUD.h>
#import "AlphabetAnimationLayer.h"
#import "VideoOutputEngine.h"
#import "SampleBufferTransformTool.h"
#import "FilePathTool.h"

@interface RecordVideoViewController ()

@property (weak, nonatomic) IBOutlet GPUImageView *cameraView;

/** animationView */
@property (nonatomic,strong) LOTAnimationView *animationView;
/** waterEngine */
@property (nonatomic,strong) WatermarkEngine *waterEngine;
/** cameraEngine */
@property (nonatomic,strong) GPUImageCameraEngine *cameraEngine;
/** animationLayer */
@property (nonatomic,strong) AlphabetAnimationLayer *animationLayer;
/** videoOutput */
@property (nonatomic,strong) VideoOutputEngine *videoOutput;
/** tool */
@property (nonatomic,strong) SampleBufferTransformTool *tool;

/** isStartRecorder */
@property (nonatomic,assign) BOOL isStartRecorder;

@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEngine];
    [self setCamera];
    [self setupAnimationView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.animationLayer removeFromSuperlayer];
    [self.cameraEngine dellocCamera];
    self.animationLayer = nil;
    self.cameraEngine = nil;
    self.waterEngine = nil;
    self.videoOutput = nil;
    self.tool = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.animationView.frame = CGRectMake(0, 0, self.cameraView.frame.size.width, self.cameraView.frame.size.height);
    self.animationLayer.frame = self.animationView.frame;
}

#pragma mark - OutputSampleBufferDelegate
- (void)getOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self.isStartRecorder) {
        return;
    }
    CMSampleBufferRef newSampleBuffer = nil;
    CMSampleBufferCreateCopy(nil, sampleBuffer, &newSampleBuffer);
    UIImage *captureImage = [self captureImg];
    UIImage *bufferImage = [self.tool imageFromSampleBuffer:sampleBuffer];
    UIImage *convertedImage = [self.tool addImage:captureImage toImage:bufferImage];
    CVPixelBufferRef pixelBuffer = [self.tool pixelBufferFromCGImage:convertedImage.CGImage];
    if (pixelBuffer) {
        // 编码存储
        [self.videoOutput appendPixelBuffer:pixelBuffer time:CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)];
//        CFRelease(pixelBuffer);
    }
}

- (IBAction)startOrStopRecordVideo:(UIButton *)sender {
    sender.tag ? [self stopRecorder] : [self setRecorder];
    self.isStartRecorder = !sender.tag;
    NSString *alert = sender.tag ? @"停止录制" :@"开始录制";
    [SVProgressHUD showSuccessWithStatus:alert];
}

- (void)setEngine {
    self.waterEngine = [[WatermarkEngine alloc] init];
    self.cameraEngine = [[GPUImageCameraEngine alloc] init];
//    self.cameraEngine.delegate = self;
    self.videoOutput = [[VideoOutputEngine alloc] init];
    [self.videoOutput setUpWriter];
    self.tool = [[SampleBufferTransformTool alloc] init];
}

- (void)setCamera {
    [self.cameraEngine setupGPUImageCamera:self.cameraView];
}

- (void)setRecorder {
    [self.cameraEngine startRecorder];
}

- (void)stopRecorder {
    [self.cameraEngine stopRecorder];
//    [self.videoOutput finishWriteFile];
    __weak typeof(self) weakSelf = self;
    NSURL *musicUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"]];
    NSURL *videoUrl = [NSURL fileURLWithPath:[FilePathTool getSandBoxFilePath]];
    [SVProgressHUD showInfoWithStatus:@"视频正在导出" maskType:SVProgressHUDMaskTypeGradient];
    [self.waterEngine addWaterMarkTypeWithLottieAndInputVideoURL:videoUrl musicUrl:musicUrl lottieAnimationName:@"clap" WithCompletionHandler:^(NSURL * _Nonnull outPutURL, int code) {
        [weakSelf.tool exportDidFinish:outPutURL complete:^(BOOL complete, NSString * _Nonnull errorMsg) {
            errorMsg = !errorMsg.length ? @"视频导出成功" : errorMsg;
            [SVProgressHUD showSuccessWithStatus:errorMsg];
        }];
    }];
}

- (void)setupAnimationView {
    self.animationView = [LOTAnimationView animationNamed:@"clap"];
    self.animationView.loopAnimation = YES;
    [self.animationView play];
    [self.cameraView addSubview:self.animationView];
    
    [self.animationLayer setupAlphaberAnimationLayer];
    [self.cameraView.layer addSublayer:self.animationLayer];
//    [self.animationLayer alphabetAnimation_pointBreath];
}

- (AlphabetAnimationLayer *)animationLayer {
    if (!_animationLayer) {
        _animationLayer = [[AlphabetAnimationLayer alloc] init];
    }
    return _animationLayer;
}

- (UIImage *)captureImg {
    UIGraphicsBeginImageContextWithOptions(self.animationLayer.frame.size, false, [UIScreen mainScreen].scale);
    [self.animationLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
