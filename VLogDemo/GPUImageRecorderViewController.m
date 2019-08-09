//
//  GPUImageRecorderViewController.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/14.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "GPUImageRecorderViewController.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import "SampleBufferTransformTool.h"
#import "CanvasView.h"
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface GPUImageRecorderViewController ()<GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageUIElement *faceView;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) GPUImageNormalBlendFilter *blendFilter;
/** animationView */
@property (nonatomic,strong) CanvasView *animationView;
/** tool */
@property (nonatomic,strong) SampleBufferTransformTool *tool;
@property (nonatomic,strong) NSURL *movieURL;
@property (nonatomic, assign) CGFloat fistTime;
@property (nonatomic,strong) NSTimer *timeTest;
- (IBAction)scressennCLick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *button_1;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)backBUbttonClick:(id)sender;

@end

@implementation GPUImageRecorderViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.filterView.frame = self.view.frame;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tool = [[SampleBufferTransformTool alloc] init];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat videoWidth = width;
    CGFloat videoHeight = height;
    CGFloat  proportion = 480.0/640;
    CGFloat actualproportion = (width)/(height);
    if (actualproportion>proportion) {
        videoWidth = floor(height *proportion);
    }else if (actualproportion<proportion){
        videoHeight = floor(width/proportion);
    }
//    UIView*contentView = [[UIView alloc]initWithFrame:CGRectMake((width-videoWidth)/2,(height-videoHeight)/2,videoWidth,videoHeight)];
    UIView*contentView = [[UIView alloc]initWithFrame:CGRectMake(0,0,width,height)];
    [self.view addSubview:contentView];
    self.animationView = [[CanvasView alloc]initWithFrame:CGRectMake(0,0,width,height)];

    self.faceView = [[GPUImageUIElement alloc] initWithView:self.animationView];
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    float FrameRate = 15.0;
    [self.videoCamera setFrameRate:FrameRate];
//    NSLog(@"self.videoCamera = %d",self.videoCamera.frameRate);
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc] init];
    self.filterView.center = contentView.center;
    [contentView addSubview:self.filterView];
    [self.videoCamera addAudioInputsAndOutputs];
    // 录像文件
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mov"];
    unlink([pathToMovie UTF8String]);
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    // 配置录制信息
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480, 640)];
    self.videoCamera.audioEncodingTarget = _movieWriter;
    _movieWriter.encodingLiveVideo = YES;
    [self.videoCamera startCameraCapture];
    
    // 响应链配置
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    
    GPUImageFilter *beautifyFilter_1 = [[GPUImageFilter alloc] init];
    [self.faceView addTarget:beautifyFilter_1];
  
    self.blendFilter = [[GPUImageNormalBlendFilter alloc] init];
    [beautifyFilter addTarget:self.blendFilter];
    [beautifyFilter addTarget:self.filterView];

    [beautifyFilter_1 addTarget:self.blendFilter];
    [self.blendFilter addTarget:_movieWriter];
    // 结束回调
    __weak typeof (self) weakSelf = self;
    __block float current = 0 ;
    [beautifyFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        __strong typeof (self) strongSelf = weakSelf;
        CGFloat allFrames = [weakSelf.animationView animationDuration]*FrameRate;
        current = current+1.0;
        if (current>allFrames) {
            current = 0;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
              strongSelf.animationView.currentProgress = current/allFrames;
            [strongSelf.animationView setEverframe];
        });
      
        dispatch_async([GPUImageContext sharedContextQueue], ^{
            [strongSelf.faceView updateWithTimestamp:time];
        });
    }];
   
    [contentView addSubview:self.animationView];
//    [contentView layoutIfNeeded];
    [self.view bringSubviewToFront:_button_1];
    [self.view bringSubviewToFront:_button];
    [self.view bringSubviewToFront:_backButton];

}


-(void) willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)scressennCLick:(UIButton*)sender {
    if (sender.tag == 0) {
          [_movieWriter startRecording];
    }else{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.movieWriter finishRecording];
            [self.tool exportDidFinish:self.movieURL complete:^(BOOL complete, NSString * _Nonnull errorMsg) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }];
         [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
- (IBAction)backBUbttonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
