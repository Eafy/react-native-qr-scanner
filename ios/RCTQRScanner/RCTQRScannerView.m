//
//  RCTQRScannerView.m
//  RCTQRScanner
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/1.
//  Copyright © 2019 Eafy. All rights reserved.
//

#import "RCTQRScannerView.h"
#import "QRScannerNative.h"

@interface RCTQRScannerView ()

@property (nonatomic,strong) QRScannerNative *scanNative;
@property (nonatomic,assign) BOOL canCameraPermission;      //是否有摄像头权限
@property (nonatomic,assign) BOOL isStartScan;              //是否开始h扫描
@property (nonatomic,assign) BOOL isNeedRereadQR;           //是否需要循环重读扫描
@property (nonatomic,assign) NSTimeInterval rereadQRTime;   //循环间隔时间

@end

@implementation RCTQRScannerView

- (void)dealloc
{
    if (!_scanNative) {
        [self setIsStartScan:self.isStartScan];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    if (self.cropRect.size.width == 0 || self.cropRect.size.height == 0) {
        self.cropRect = self.bounds;
    }

    [self setupScanReader];

    if (self.isStartScan) {
        [self setIsStartScan:self.isStartScan];
    }
}

- (void)setupScanReader
{
    if (!_scanNative) {
        CGRect viewRect = self.frame;
        CGFloat x = self.cropRect.origin.y / viewRect.size.height;
        CGFloat y = self.cropRect.origin.x / viewRect.size.width;
        CGFloat width = self.cropRect.size.height / viewRect.size.height;
        CGFloat height = self.cropRect.size.width / viewRect.size.width;
        CGRect cropRect = CGRectMake(x, y, width, height);

        __weak __typeof(self) weakSelf = self;
        self.scanNative = [[QRScannerNative alloc] initWithPreView:self ObjectType:nil cropRect:cropRect success:^(NSArray<QRScannerResult *> *array) {
            [weakSelf scanResultWithArray:array];
        }];

        [self.scanNative setNeedRereadQR:self.isNeedRereadQR waitTime:self.rereadQRTime];
    }
}

- (void)scanResultWithArray:(NSArray<QRScannerResult*>*)array
{
    [self playSound];

    NSMutableArray *resultArray = [NSMutableArray array];
    for (QRScannerResult *result in array) {
        NSLog(@"%@", result.strScanned);
        [resultArray addObject:result.strScanned];
    }

    NSDictionary *event = @{
                            @"type": @"onScanResult",
                            @"params": resultArray
                            };
    [self sendEventWithParams:event];
}

- (void)playSound
{
    BOOL isExist = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.scanAudioFile]) {
        isExist = YES;
    } else {
        NSString *searchFile = [[NSBundle mainBundle] pathForResource:self.scanAudioFile ofType:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:searchFile]) {
            self.scanAudioFile = searchFile;
            isExist = YES;
        }
    }

    if (isExist) {
        SystemSoundID shake_sound_male_id = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:self.scanAudioFile],&shake_sound_male_id);
        AudioServicesPlayAlertSound(shake_sound_male_id);
    }
}

- (BOOL)canCameraPermission
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
            NSDictionary *event = @{
                                    @"type": @"onScanError",
                                    @"params": @{
                                            @"code": @(-1),
                                            @"errMsg": @"Cannot Access Camera"
                                            }
                                    };
            [self sendEventWithParams:event];
            return NO;
        } else {
            return YES;
        }
    }

    return NO;
}

- (void)sendEventWithParams:(NSDictionary *)params {
    if (!_onChange) {
        return;
    }
    self.onChange(params);
}

#pragma mark - RN-API

- (void)setIsStartScan:(BOOL)isStartScan
{
    _isStartScan = isStartScan;
    if (isStartScan) {
        if (self.canCameraPermission || [self canCameraPermission]) {
            self.canCameraPermission = YES;
            [self.scanNative startScan];
        }
    } else {
        [self.scanNative setTorch:NO];
        [self.scanNative stopScan];
    }
}

- (void)setIsOpenFlash:(BOOL)isOpenFlash
{
    [self.scanNative setTorch:isOpenFlash];
}

- (void)setNeedRereadQR:(NSDictionary *)dic
{
    if (dic) {
        self.isNeedRereadQR = [[dic objectForKey:@"reread"] boolValue];
        self.rereadQRTime = [[dic objectForKey:@"time"] doubleValue];
    }
}

@end
