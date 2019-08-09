//
//  SampleBufferTransformTool.m
//  VLogDemo
//
//  Created by 刘冉 on 2019/6/13.
//  Copyright © 2019 LRCY. All rights reserved.
//

#import "SampleBufferTransformTool.h"
#import <Photos/Photos.h>

@implementation SampleBufferTransformTool

/// UIImage转CVPixelBufferRef
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    UIImage *ciImg = [UIImage imageWithCIImage:convertedImage];
    
    return ciImg;
}

- (UIImage *)addImage:(UIImage*)image1 toImage:(UIImage*)image2{
    //将底部的一张的大小作为所截取的合成图的尺寸
    UIGraphicsBeginImageContext(CGSizeMake(image2.size.width, image2.size.height));
    // Draw image2，底下的
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (void)exportDidFinish:(NSURL *)outputURL complete:(nonnull void (^)(BOOL, NSString * _Nonnull))completeHander {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __block PHObjectPlaceholder *placeholder;
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path)) {
            NSError *error;
            BOOL isComplete = NO;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
                placeholder = [createAssetRequest placeholderForCreatedAsset];
            } error:&error];
            if (error) {
                isComplete = NO;
            } else{
                isComplete = YES;
            }
            if (completeHander) {
                completeHander(isComplete,error.description);
            }
        } else {
            if (completeHander) {
                completeHander(NO,@"视频保存相册失败，请设置软件读取相册权限");
            }
        }
    });
}

@end
