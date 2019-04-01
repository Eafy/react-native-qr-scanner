//
//  RCTQRScannerView.m
//  RCTQRScanner
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/1.
//  Copyright © 2019 Eafy. All rights reserved.
//

#import "RCTQRScannerView.h"
#import <LBXScan/LBXScanNative.h>

@interface RCTQRScannerView ()

@property (nonatomic,strong) LBXScanNative *scanNative;
@property (nonatomic,assign) CGRect cropRect;
@property (nonatomic,copy) NSString *qrAudioFile;

@end

@implementation RCTQRScannerView

- (void)setupScanReader
{
    if (!_scanNative) {
        __weak __typeof(self) weakSelf = self;
        self.scanNative = [[LBXScanNative alloc] initWithPreView:self ObjectType:nil cropRect:self.cropRect success:^(NSArray<LBXScanResult *> *array) {
            [weakSelf scanResultWithArray:array];
        }];

        self.qrAudioFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"caf"];
    }
}

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    [self playSound];
}

- (void)playSound
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.qrAudioFile]) {
        SystemSoundID shake_sound_male_id = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:self.qrAudioFile],&shake_sound_male_id);
        AudioServicesPlayAlertSound(shake_sound_male_id);
    }
}

- (void)openFlash
{
    [self.scanNative setTorch:true];
}

- (void)closeFlash
{
    [self.scanNative setTorch:false];
}

@end
