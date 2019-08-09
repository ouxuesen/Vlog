//
//  LottieAnimationViewController.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/11.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "LottieAnimationViewController.h"
#import <Lottie/Lottie.h>
#import "TEstViewAnimation.h"

@interface LottieAnimationViewController ()

@property (strong, nonatomic) LOTAnimationView *animationView;

@end

@implementation LottieAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setupAnimationView];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.animationView.frame = self.view.frame;
}

- (void)setupAnimationView {
    self.animationView = [LOTAnimationView animationNamed:@"clap"];
    self.animationView.loopAnimation = YES;
    [self.animationView play];
    [self.view addSubview:self.animationView];
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
