//
//  RCTQRScannerNative.h
//  RCTQRScanner
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/1.
//  Copyright © 2019 Eafy. All rights reserved.
//

@import UIKit;
@import Foundation;
@import AVFoundation;

@interface QRScannerResult : NSObject

- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type;

@property (nonatomic,copy) NSString *strScanned;   //条码字符串
@property (nonatomic,strong) UIImage *imgScanned;  //扫码图像
@property (nonatomic, copy) NSString* strBarCodeType;  //扫码码的类型：AVMetadataObjectType

@end

@interface QRScannerNative : NSObject

/**
 初始化采集相机

 @param preView 视频显示区域
 @param objType 识别码类型：如果为nil，默认支持很多类型。(二维码QR：AVMetadataObjectTypeQRCode,条码如：AVMetadataObjectTypeCode93Code
 @param block 识别结果
 @return QRScannerResult的实例
 */
- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType success:(void(^)(NSArray<QRScannerResult*> *array))block;

/**
 初始化采集相机

 @param preView 视频显示区域
 @param objType 识别码类型：如果为nil，默认支持很多类型。(二维码QR：AVMetadataObjectTypeQRCode,条码如：AVMetadataObjectTypeCode93Code
 cropRect 识别区域(视图比例)，值CGRectZero全屏识别
 @param block 识别结果
 @return QRScannerResult的实例
 */
- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect success:(void(^)(NSArray<QRScannerResult*> *array))block;

#pragma mark - Public API

/**
 开始扫码
 */
- (void)startScan;

/*!
 *  停止扫码
 */

/**
 停止扫码
 */
- (void)stopScan;

/**
 是否开始闪光灯

 @param torch YES：开启
 */
- (void)setTorch:(BOOL)torch;

/**
 自动根据闪关灯状态去改变
 */
- (void)changeTorch;

/**
 修改扫码类型：二维码、条形码

 @param objType <#objType description#>
 */
- (void)changeScanType:(NSArray*)objType;

/**
 设置扫码成功后是否拍照

 @param isNeedCaputureImg YES:拍照， NO:不拍照
 */
- (void)setNeedCaptureImage:(BOOL)isNeedCaputureImg;

/**
 设置是否重读扫描j

 @param reread 是否重读
 @param time 间隔时间
 */
- (void)setNeedRereadQR:(BOOL)reread waitTime:(NSTimeInterval)time;

#pragma mark --镜头
/**
 获取摄像机最大拉远镜头

 @return 放大系数
 */
- (CGFloat)getVideoMaxScale;

/**
 拉近拉远镜头

 @param scale 系数
 */
- (void)setVideoScale:(CGFloat)scale;

#pragma mark --识别图片
/**
 识别QR二维码图片,ios8.0以上支持

 @param image 图片
 @param block 返回识别结果
 */
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<QRScannerResult*> *array))block;

#pragma mark --生成条码
/**
 生成QR二维码

 @param text 字符串
 @param size 二维码大小
 @return 返回二维码图像
 */
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size;

/**
 生成QR二维码

 @param text 字符串
 @param size 大小
 @param qrColor 二维码前景色
 @param bkColor 二维码背景色
 @return 二维码图像
 */
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor;

/**
 生成条形码

 @param text 字符串
 @param size 大小
 @return 返回条码图像
 */
+ (UIImage*)createBarCodeWithString:(NSString*)text QRSize:(CGSize)size;

@end

