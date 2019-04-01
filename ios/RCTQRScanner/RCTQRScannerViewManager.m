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

//RCT_EXPORT_MODULE(RCTQRScannerView)

- (RCTView *)view
{
    return [[RCTQRScannerView alloc] init];
}



@end
