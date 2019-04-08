//
//  RCTQRScannerViewManager.m
//  RCTQRScanner
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/1.
//  Copyright © 2019 Eafy. All rights reserved.
//

#import "RCTQRScannerViewManager.h"
#import "RCTQRScannerView.h"

@implementation RCTQRScannerViewManager

RCT_EXPORT_MODULE(QRScannerView)

RCT_EXPORT_VIEW_PROPERTY(isStartScan, BOOL)
RCT_EXPORT_VIEW_PROPERTY(isOpenFlash, BOOL)
RCT_EXPORT_VIEW_PROPERTY(scanAudioFile, NSString)
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(cropRect, CGRect, RCTQRScannerView) {
    [view setCropRect:json ? [RCTConvert CGRect:json] : CGRectZero];
}

- (RCTView *)view
{
    return [[RCTQRScannerView alloc] init];
}

@end
