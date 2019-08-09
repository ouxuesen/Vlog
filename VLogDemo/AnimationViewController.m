//
//  AnimationViewController.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/12.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "AnimationViewController.h"
#import "AlphabetAnimationLayer.h"
#import "TEstViewAnimation.h"
#import "LEDPictureFameView.h"
#import "UIView+AutoLayout.h"
@interface AnimationViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *animationStylePicker;
/** animationLayer */
@property (nonatomic,strong) AlphabetAnimationLayer *animationLayer;
/** pickDataSource */
@property (nonatomic,strong) NSArray *pickDataSource;
- (IBAction)valueChage:(UISlider*)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic,strong) NSTimer *timeTest;
@property (weak, nonatomic) IBOutlet UIButton *starbutton;
- (IBAction)startButtonClick:(id)sender;
@property (nonatomic,strong) TEstViewAnimation *testView;
@property (nonatomic,strong) LEDPictureFameView * pictURVIew;
@end

@implementation AnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    _testView = [[TEstViewAnimation alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    //    [self.view addSubview:_testView];
    //
    _pictURVIew= [[LEDPictureFameView alloc] initWithFrame:CGRectMake(0, 100, 368*2, 640*2)];
    [self.view insertSubview:_pictURVIew atIndex:0];
    
//    [_pictURVIew autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    [_pictURVIew startMianAnimation];
    
    __block  NSMutableArray *tempArray = [NSMutableArray new];
    [tempArray addObject:@{@"type":@(2),@"word":@"cat"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"c"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"a"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"t"}];
    [tempArray addObject:@{@"type":@(2),@"word":@"cat"}];
    
    [tempArray addObject:@{@"type":@(2),@"word":@"car"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"c"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"ar"}];
    [tempArray addObject:@{@"type":@(2),@"word":@"car"}];
    
    [tempArray addObject:@{@"type":@(2),@"word":@"crab"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"c"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"r"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"a"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"b"}];
    [tempArray addObject:@{@"type":@(2),@"word":@"crab"}];
    
    [tempArray addObject:@{@"type":@(2),@"word":@"clap"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"c"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"l"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"a"}];
    [tempArray addObject:@{@"type":@(1),@"word":@"p"}];
    [tempArray addObject:@{@"type":@(2),@"word":@"clap"}];
    
    
    
    //    self.animationLayer.backgroundColor = [UIColor yellowColor].CGColor;
    //    [self.animationLayer setupAlphaberAnimationLayer];
    //    [self.view.layer addSublayer:self.animationLayer];
    
    //    self.pickDataSource = @[@"pointDown",@"pointBreath",@"pointMove",@"pointJump"];
    //    [self.animationLayer alphabetAnimation_pointDown];
    __weak typeof (self) weakSelf = self;
    __block CGFloat time = 0.0;
    __block CGFloat titleTime = 1.0;
    __block NSInteger index = -1;
    __block NSInteger allCount = (NSInteger)tempArray.count;
    _timeTest = [NSTimer scheduledTimerWithTimeInterval:1.0/15 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (!weakSelf.starbutton.selected) {
            return ;
        }
        time = time+1.0/15;
        if(time>titleTime-0.5/15&&titleTime<titleTime+0.5/15){
             CGFloat worktime = 0.0;
            if (index==-1) {
                worktime = 1+[weakSelf.pictURVIew startTitileAnimationView];
            }else{
                if (allCount>index) {
                    NSDictionary*dic = tempArray[index];
                    
                    CGFloat worktime = 0.0;
                    if ([dic[@"type"] integerValue] == 1) {
                        worktime = [weakSelf.pictURVIew showWoridImageWithSinglesyllable:dic[@"word"]];
                    }else{
                        worktime = [weakSelf.pictURVIew showWoridImageWithWord:dic[@"word"]];
                    }
                }
            }
            titleTime =  titleTime+worktime+1;
            NSLog(@"index = %ld",index);
            index++;
            
        }
        [weakSelf.pictURVIew refeshEverframe];
        
    }];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.animationLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.animationStylePicker.frame.size.height - 10);
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickDataSource.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickDataSource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *title = self.pickDataSource[row];
    NSLog(@"title = %@",title);
    switch (row) {
        case 0:
            [self.animationLayer alphabetAnimation_pointDownWithOffset_x:0];
            break;
        case 1:
            [self.animationLayer alphabetAnimation_pointBreathWithOffset_x:0];
            break;
        case 2:
            [self.animationLayer alphabetAnimation_pointMove:CGPointMake(0, 0) moveTo:CGPointMake(self.animationLayer.bounds.size.width, self.animationLayer.bounds.size.height-point_w/2) moveRadius:10];
            break;
        case 3:
            [self.animationLayer alphabetAnimation_pointJumpWithOffset_x:100];
            break;
        default:
            break;
    }
}

- (AlphabetAnimationLayer *)animationLayer {
    if (!_animationLayer) {
        _animationLayer = [[AlphabetAnimationLayer alloc] init];
        
        _animationLayer.backgroundColor = [UIColor redColor].CGColor;
    }
    return _animationLayer;
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _animationLayer.frame = CGRectMake(0, 300, self.view.bounds.size.width, 80);
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)valueChage:(UISlider*)sender {
    [self.animationLayer setAnimationProgress:sender.value];
}
- (IBAction)startButtonClick:(id)sender {
    self.starbutton.selected = !self.starbutton.selected;
    if (self.starbutton.selected) {
        
    }else{
        
    }
}
@end


