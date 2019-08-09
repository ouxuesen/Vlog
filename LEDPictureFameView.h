//
//  LEDPictureFameView.h
//  VLogDemo
//
//  Created by ou xuesen on 2019/6/26.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEDPictureFameView : UIView

-(void)refeshEverframe;

-(void)startMianAnimation;
-(CGFloat)startTitileAnimationView;
-(CGFloat)showWoridImageWithSinglesyllable:(NSString*)singlesyllable;
-(CGFloat)showWoridImageWithWord:(NSString*)word;

@end

NS_ASSUME_NONNULL_END
