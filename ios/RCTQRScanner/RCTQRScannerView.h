//
//  RCTQRScannerView.h
//  RCTQRScanner
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/1.
//  Copyright © 2019 Eafy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTView.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTQRScannerView : RCTView

@property (nonatomic,copy) RCTBubblingEventBlock onChange;
@property (nonatomic,assign) CGRect cropRect;
@property (nonatomic,copy) NSString *scanAudioFile;

- (void)sendEventWithParams:(NSDictionary *)params;
- (void)setIsOpenFlash:(BOOL)isOpenFlash;
- (void)setNeedRereadQR:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
