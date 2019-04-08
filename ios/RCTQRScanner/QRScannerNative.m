//
//  QRScannerNative.m
//  RCTQRScanner
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/1.
//  Copyright © 2019 Eafy. All rights reserved.
//

#import "QRScannerNative.h"

@implementation QRScannerResult

- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type
{
    if (self = [super init]) {
        self.strScanned = str;
        self.imgScanned = img;
        self.strBarCodeType = type;
    }

    return self;
}

@end

@interface QRScannerNative()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,assign) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,strong)  AVCaptureStillImageOutput *stillImageOutput;   //拍照

@property (nonatomic,assign) BOOL isNeedCaputureImage;
@property (nonatomic,strong) NSMutableArray<QRScannerResult*> *arrayResult;  //扫码结果
@property (nonatomic,strong) NSArray* arrayBarCodeType;    //扫码类型
@property (nonatomic,weak) UIView *videoPreView;     //视频预览显示视图
@property (nonatomic,copy) void (^blockScanResult)(NSArray<QRScannerResult*> *array);
@property (nonatomic,assign) BOOL bNeedScanResult;
@property (nonatomic,assign) BOOL isNeedRereadQR;
@property (nonatomic,assign) NSTimeInterval waitRereadTime;

@end

@implementation QRScannerNative


- (void)setNeedCaptureImage:(BOOL)isNeedCaputureImg
{
    _isNeedCaputureImage = isNeedCaputureImg;
}

- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect success:(void(^)(NSArray<QRScannerResult*> *array))block
{
    if (self = [super init]) {
        [self initParaWithPreView:preView ObjectType:objType cropRect:cropRect success:block];
    }
    return self;
}

- (instancetype)initWithPreView:(UIView*)preView ObjectType:(NSArray*)objType success:(void(^)(NSArray<QRScannerResult*> *array))block
{
    if (self = [super init]) {
        
        [self initParaWithPreView:preView ObjectType:objType cropRect:CGRectZero success:block];
    }
    
    return self;
}


- (void)initParaWithPreView:(UIView*)videoPreView ObjectType:(NSArray*)objType cropRect:(CGRect)cropRect success:(void(^)(NSArray<QRScannerResult*> *array))block
{
    self.arrayBarCodeType = objType;
    self.blockScanResult = block;
    self.videoPreView = videoPreView;
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!_device) {
        return;
    }
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if ( !_input  )
        return ;
    
    
    self.bNeedScanResult = YES;
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    if ( !CGRectEqualToRect(cropRect,CGRectZero) )
    {
        _output.rectOfInterest = cropRect;
    }
    
    /*
    // Setup the still image file output
     */
//    AVCapturePhotoOutput
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
   // _session.
    
   // videoScaleAndCropFactor
    
    if ([_session canAddInput:_input])
    {
        [_session addInput:_input];
    }
    
    if ([_session canAddOutput:_output])
    {
        [_session addOutput:_output];
    }

    if ([_session canAddOutput:_stillImageOutput])
    {
        [_session addOutput:_stillImageOutput];
    }
    
 
 
    
    // 条码类型 AVMetadataObjectTypeQRCode
   // _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    if (!objType) {
        objType = [self defaultMetaDataObjectTypes];
    }
    
    _output.metadataObjectTypes = objType;
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //_preview.frame =CGRectMake(20,110,280,280);
    
    CGRect frame = videoPreView.frame;
    frame.origin = CGPointZero;
    _preview.frame = frame;
    
    [videoPreView.layer insertSublayer:self.preview atIndex:0];
    
 
    
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
//    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
     CGFloat scale = videoConnection.videoScaleAndCropFactor;
    NSLog(@"%f",scale);
//    CGFloat zoom = maxScale / 50;
//    if (zoom < 1.0f || zoom > maxScale)
//    {
//        return;
//    }
//    videoConnection.videoScaleAndCropFactor += zoom;
//    CGAffineTransform transform = videoPreView.transform;
//    videoPreView.transform = CGAffineTransformScale(transform, zoom, zoom);

    
    
    //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if (_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        [_input.device lockForConfiguration:nil];
        [_input.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [_input.device unlockForConfiguration];
    }
}

- (CGFloat)getVideoMaxScale
{
    [_input.device lockForConfiguration:nil];
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
    [_input.device unlockForConfiguration];
    
    return maxScale;
}

- (void)setVideoScale:(CGFloat)scale
{
    [_input.device lockForConfiguration:nil];
    
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    
    CGFloat zoom = scale / videoConnection.videoScaleAndCropFactor;
    
    videoConnection.videoScaleAndCropFactor = scale;
    
    [_input.device unlockForConfiguration];
    
    CGAffineTransform transform = _videoPreView.transform;
    
    _videoPreView.transform = CGAffineTransformScale(transform, zoom, zoom);
}

- (void)setScanRect:(CGRect)scanRect
{
    //识别区域设置
    if (_output) {
        _output.rectOfInterest = [self.preview metadataOutputRectOfInterestForRect:scanRect];
    }
    
}

- (void)changeScanType:(NSArray*)objType
{    
    _output.metadataObjectTypes = objType;
}

- (void)startScan
{
    if ( _input && !_session.isRunning )
    {
        [_session startRunning];
        self.bNeedScanResult = YES;
        
        [_videoPreView.layer insertSublayer:self.preview atIndex:0];
        
       // [_input.device addObserver:self forKeyPath:@"torchMode" options:0 context:nil];
    }
    self.bNeedScanResult = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( object == _input.device ) {
        
        NSLog(@"flash change");
    }
}

- (void)stopScan
{
    self.bNeedScanResult = NO;
    if ( _input && _session.isRunning )
    {
        self.bNeedScanResult = NO;
        [_session stopRunning];
        
       // [self.preview removeFromSuperlayer];
    }
}

- (void)setTorch:(BOOL)torch {   
    
    [self.input.device lockForConfiguration:nil];
    self.input.device.torchMode = torch ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    [self.input.device unlockForConfiguration];
}

- (void)changeTorch
{
    AVCaptureTorchMode torch = self.input.device.torchMode;
   
    switch (_input.device.torchMode) {
        case AVCaptureTorchModeAuto:
            break;
        case AVCaptureTorchModeOff:
            torch = AVCaptureTorchModeOn;
            break;
        case AVCaptureTorchModeOn:
            torch = AVCaptureTorchModeOff;
            break;
        default:
            break;
    }
    
    [_input.device lockForConfiguration:nil];
    _input.device.torchMode = torch;
    [_input.device unlockForConfiguration];
}


-(UIImage *)getImageFromLayer:(CALayer *)layer size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, [[UIScreen mainScreen]scale]);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}

- (void)captureImage
{
    AVCaptureConnection *stillImageConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         [self stopScan];
         
         if (imageDataSampleBuffer)
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             
             UIImage *img = [UIImage imageWithData:imageData];
             
             for (QRScannerResult* result in self->_arrayResult) {
                 result.imgScanned = img;
             }
         }
         
         if (self->_blockScanResult) {
             self->_blockScanResult(self->_arrayResult);
         }
     }];
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput2:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
   
    
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects)
    {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] )
        {
            
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            NSLog(@"type:%@",current.type);
            NSLog(@"result:%@",scannedResult);
            
            
            
         
            
            //测试可以同时识别多个二维码
        }
    }
    
   
    
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!self.bNeedScanResult) {
        return;
    }
    
    self.bNeedScanResult = NO;
    
    if (!_arrayResult) {
        
        self.arrayResult = [NSMutableArray arrayWithCapacity:1];
    }
    else
    {
        [_arrayResult removeAllObjects];
    }
    
    //识别扫码类型
    for(AVMetadataObject *current in metadataObjects)
    {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] )
        {
            self.bNeedScanResult = NO;
            
            NSLog(@"type:%@",current.type);
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            
            if (scannedResult && ![scannedResult isEqualToString:@""])
            {
                QRScannerResult *result = [QRScannerResult new];
                result.strScanned = scannedResult;
                result.strBarCodeType = current.type;
                
                [_arrayResult addObject:result];
            }
            //测试可以同时识别多个二维码
        }
    }
    
    if (_arrayResult.count < 1)
    {
        self.bNeedScanResult = YES;
        return;
    }
    
    if (_isNeedCaputureImage)
    {
        [self captureImage];
    }
    else
    {
        if (self.isNeedRereadQR) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.waitRereadTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.bNeedScanResult = YES;
            });
        } else {
            [self stopScan];
        }

        if (_blockScanResult) {
            _blockScanResult(_arrayResult);
        }
    }
}

- (void)setNeedRereadQR:(BOOL)reread waitTime:(NSTimeInterval)time
{
    self.isNeedRereadQR = reread;
    if (time > 0) {
        self.waitRereadTime = time;
    } else {
        self.waitRereadTime = 0.5;
    }
}


/**
 @brief  默认支持码的类别
 @return 支持类别 数组
 */
- (NSArray *)defaultMetaDataObjectTypes
{
    NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeAztecCode] mutableCopy];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_0)
    {
        [types addObjectsFromArray:@[
                                     AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode
                                     ]];
    }
    
    return types;
}

#pragma mark --识别条码图片
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<QRScannerResult*> *array))block;
{
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 8.0 )
    {
        if (block) {
            QRScannerResult *result = [[QRScannerResult alloc]init];
            result.strScanned = @"只支持ios8.0之后系统";
            block(@[result]);
        }
        return;
    }
    
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSMutableArray<QRScannerResult*> *mutableArray = [[NSMutableArray alloc]initWithCapacity:1];
    for (int index = 0; index < [features count]; index ++)
    {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        NSLog(@"result:%@",scannedResult);
        
        QRScannerResult *item = [[QRScannerResult alloc]init];
        item.strScanned = scannedResult;
        item.strBarCodeType = CIDetectorTypeQRCode;
        item.imgScanned = image;
        [mutableArray addObject:item];
    }
    if (block) {
        block(mutableArray);
    }
}

#pragma mark --生成条码

//下面引用自 https://github.com/yourtion/Demo_CustomQRCode
#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *aImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return aImage;
}

#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return qrFilter.outputImage;
}


#pragma mark - 生成二维码，背景色及二维码颜色设置

+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size
{
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    
 
    
    CIImage *qrImage = qrFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;

    
    
}
//引用自:http://www.jianshu.com/p/e8f7a257b612
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor
{
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:qrColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:bkColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

+ (UIImage*)createBarCodeWithString:(NSString*)text QRSize:(CGSize)size
{
    
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    
     CIImage *barcodeImage = [filter outputImage];
    
    // 消除模糊
    
    CGFloat scaleX = size.width / barcodeImage.extent.size.width; // extent 返回图片的frame
    
    CGFloat scaleY = size.height / barcodeImage.extent.size.height;
    
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
    
}




@end
