#import "CamerawesomePlugin.h"
#import "CameraPreview.h"

FlutterEventSink orientationEventSink;
FlutterEventSink videoRecordingEventSink;
FlutterEventSink imageStreamEventSink;

@interface CamerawesomePlugin ()

@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property int64_t textureId;
@property CameraPreview *camera;

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry messenger:(NSObject<FlutterBinaryMessenger> *)messenger;

@end

@implementation OrientationStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    orientationEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    orientationEventSink = nil;
    return nil;
}
@end

@implementation ImageStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    imageStreamEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    imageStreamEventSink = nil;
    return nil;
}
@end

@implementation VideoRecordingStreamHandler
- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    videoRecordingEventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    videoRecordingEventSink = nil;
    return nil;
}
@end

@implementation CamerawesomePlugin {
    dispatch_queue_t _dispatchQueue;
}
- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _registry = registry;
    _messenger = messenger;

    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    CamerawesomePlugin *instance = [[CamerawesomePlugin alloc] initWithRegistry:[registrar textures] messenger:[registrar messenger]];
    
    OrientationStreamHandler *orientationStreamHandler =
            [[OrientationStreamHandler alloc] init];
    FlutterEventChannel *orientationChannel = [FlutterEventChannel eventChannelWithName:@"camerawesome/orientation"
    binaryMessenger:[registrar messenger]];
    [orientationChannel setStreamHandler:orientationStreamHandler];
    
    VideoRecordingStreamHandler *videoRecordingStreamHandler =
            [[VideoRecordingStreamHandler alloc] init];
    FlutterEventChannel *videoRecordingChannel = [FlutterEventChannel eventChannelWithName:@"camerawesome/video-recording"
    binaryMessenger:[registrar messenger]];
    [videoRecordingChannel setStreamHandler:videoRecordingStreamHandler];
    
    ImageStreamHandler *imageStreamHandler =
            [[ImageStreamHandler alloc] init];
    FlutterEventChannel *imageStreamChannel = [FlutterEventChannel eventChannelWithName:@"camerawesome/images"
    binaryMessenger:[registrar messenger]];
    [imageStreamChannel setStreamHandler:imageStreamHandler];
    
    // TODO: Change to "camerawesome/methods"
    FlutterMethodChannel *methodChannel = [FlutterMethodChannel methodChannelWithName:@"camerawesome" binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:methodChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (_dispatchQueue == nil) {
        _dispatchQueue = dispatch_queue_create("camerawesome.dispatchqueue", NULL);
    }
    [_camera setResult:result];
    
    dispatch_async(_dispatchQueue, ^{
        [self handleMethodCallAsync:call result:result];
    });
}

- (void)handleMethodCallAsync:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"init" isEqualToString:call.method]) {
        [self _handleSetup:call result:result];
    } else if ([@"checkPermissions" isEqualToString:call.method]) {
        [self _handleCheckPermissions:call result:result];
    } else if ([@"requestPermissions" isEqualToString:call.method]) {
        // Not possible on iOS
        result(FlutterMethodNotImplemented);
        return;
    } else if ([@"start" isEqualToString:call.method]) {
        [self _handleStart:call result:result];
    } else if ([@"stop" isEqualToString:call.method]) {
        [self _handleStop:call result:result];
    } else if ([@"refresh" isEqualToString:call.method]) {
        [self _handleRefresh:call result:result];
    } else if ([@"availableSizes" isEqualToString:call.method]) {
        [self _handleSizes:call result:result];
    } else if ([@"previewTexture" isEqualToString:call.method]) {
        [self _handleGetTextures:call result:result];
    } else if ([@"setPreviewSize" isEqualToString:call.method]) {
        [self _handlePreviewSize:call result:result];
    } else if ([@"getEffectivPreviewSize" isEqualToString:call.method]) {
        [self _handleGetEffectivPreviewSize:call result:result];
    } else if ([@"setPhotoSize" isEqualToString:call.method]) {
        [self _handlePhotoSize:call result:result];
    } else if ([@"takePhoto" isEqualToString:call.method]) {
        [self _handleTakePhoto:call result:result];
    } else if ([@"recordVideo" isEqualToString:call.method]) {
        [self _handleRecordVideo:call result:result];
    } else if ([@"stopRecordingVideo" isEqualToString:call.method]) {
        [self _handleStopRecordingVideo:call result:result];
    } else if ([@"setRecordingAudioMode" isEqualToString:call.method]) {
        [self _handleRecordingAudioMode:call result:result];
    } else if ([@"handleAutoFocus" isEqualToString:call.method]) {
        [self _handleAutoFocus:call result:result];
    } else if ([@"setFlashMode" isEqualToString:call.method]) {
        [self _handleFlashMode:call result:result];
    } else if ([@"setSensor" isEqualToString:call.method]) {
        [self _handleSetSensor:call result:result];
    } else if ([@"setCaptureMode" isEqualToString:call.method]) {
        [self _handleSetCaptureMode:call result:result];
    } else if ([@"setZoom" isEqualToString:call.method]) {
        [self _handleSetZoom:call result:result];
    } else if ([@"getMaxZoom" isEqualToString:call.method]) {
        [self _handleGetMaxZoom:call result:result];
    } else if ([@"dispose" isEqualToString:call.method]) {
        [self _handleDispose:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
        return;
    };
}

- (void)_handleRecordingAudioMode:(FlutterMethodCall*)call result:(FlutterResult)result {
    bool value = [call.arguments[@"enableAudio"] boolValue];
    [_camera setRecordingAudioMode:value];
}

- (void)_handleGetEffectivPreviewSize:(FlutterMethodCall*)call result:(FlutterResult)result {
    CGSize previewSize = [_camera getEffectivPreviewSize];
    result(@{
        @"width": [NSNumber numberWithInt:previewSize.width],
        @"height": [NSNumber numberWithInt:previewSize.height],
    });
}

- (void)_handleSetZoom:(FlutterMethodCall*)call result:(FlutterResult)result {
    float value = [call.arguments[@"zoom"] floatValue];
    [_camera setZoom:value];
}

- (NSInteger)_handleGetMaxZoom:(FlutterMethodCall*)call result:(FlutterResult)result {
    return [_camera getMaxZoom];
}

- (void)_handleDispose:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_camera dispose];
    _dispatchQueue = nil;
    result(nil);
}

- (void)_handleTakePhoto:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *path = call.arguments[@"path"];
    
    if (path == nil || path.length <= 0) {
        result([FlutterError errorWithCode:@"PATH_NOT_SET" message:@"a file path must be set" details:nil]);
        return;
    }
    
    [_camera takePictureAtPath:path];
}

- (void)_handleRecordVideo:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *path = call.arguments[@"path"];
    
    if (path == nil || path.length <= 0) {
        result([FlutterError errorWithCode:@"PATH_NOT_SET" message:@"a file path must be set" details:nil]);
        return;
    }
    
    [_camera recordVideoAtPath:path];
}

- (void)_handleStopRecordingVideo:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_camera stopRecordingVideo];
}

- (void)_handleSetSensor:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *sensorName = call.arguments[@"sensor"];
    // TODO: Return a list of all available cameras to front & then choice in a list the device ID wanted
    CameraSensor sensor = ([sensorName isEqualToString:@"FRONT"]) ? Front : Back;

    [_camera setSensor:sensor];
}

- (void)_handleSetCaptureMode:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *captureModeName = call.arguments[@"captureMode"];
    CaptureModes captureMode = ([captureModeName isEqualToString:@"PHOTO"]) ? Photo : Video;
    [_camera setCaptureMode:captureMode];
}

- (void)_handleAutoFocus:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_camera instantFocus];
}

- (void)_handleCheckPermissions:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(@([CameraPermissions checkPermissions]));
}

- (void)_handleSizes:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(kCameraQualities);
}

- (void)_handlePreviewSize:(FlutterMethodCall*)call result:(FlutterResult)result {
    float width = [call.arguments[@"width"] floatValue];
    float height = [call.arguments[@"height"] floatValue];
    
    if (width <= 0 || height <= 0) {
        result([FlutterError errorWithCode:@"NO_SIZE_SET" message:@"width and height must be set" details:nil]);
        return;
    }
    
    if (self.camera == nil) {
        result([FlutterError errorWithCode:@"CAMERA_MUST_BE_INIT" message:@"init must be call before start" details:nil]);
        return;
    }
    
    [self.camera setPreviewSize:CGSizeMake(width, height)];
    
    result(nil);
}

- (void)_handlePhotoSize:(FlutterMethodCall*)call result:(FlutterResult)result {
    float width = [call.arguments[@"width"] floatValue];
    float height = [call.arguments[@"height"] floatValue];
    
    if (width <= 0 || height <= 0) {
        result([FlutterError errorWithCode:@"NO_SIZE_SET" message:@"width and height must be set" details:nil]);
        return;
    }
    
    if (self.camera == nil) {
        result([FlutterError errorWithCode:@"CAMERA_MUST_BE_INIT" message:@"init must be call before start" details:nil]);
        return;
    }
    
    // TODO: Set size inside camera
    
    result(nil);
}

- (void)_handleStart:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (self.camera == nil) {
        result([FlutterError errorWithCode:@"CAMERA_MUST_BE_INIT" message:@"init must be call before start" details:nil]);
        return;
    }
    
    [_camera start];
    
    result(@(YES));
}

- (void)_handleStop:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (self.camera == nil) {
        result([FlutterError errorWithCode:@"CAMERA_MUST_BE_INIT" message:@"init must be call before start" details:nil]);
        return;
    }
    
    [_camera stop];
    
    result(@(YES));
}

- (void)_handleRefresh:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_camera refresh];
}

- (void)_handleSetup:(FlutterMethodCall*)call result:(FlutterResult)result  {
    NSString *sensorName = call.arguments[@"sensor"];
    NSString *captureModeName = call.arguments[@"captureMode"];
    BOOL streamImages = call.arguments[@"streamImages"];
    CaptureModes captureMode = ([captureModeName isEqualToString:@"PHOTO"]) ? Photo : Video;
    
    if (![CameraPermissions checkPermissions]) {
        result([FlutterError errorWithCode:@"MISSING_PERMISSION" message:@"you got to accept all permissions" details:nil]);
        return;
    }
    
    if (sensorName == nil || sensorName.length <= 0) {
        result([FlutterError errorWithCode:@"SENSOR_ERROR" message:@"a sensor FRONT or BACK must be provided" details:nil]);
        return;
    }

    CameraSensor sensor = ([sensorName isEqualToString:@"FRONT"]) ? Front : Back;
    self.camera = [[CameraPreview alloc] initWithCameraSensor:sensor
                                              streamImages:streamImages
                                               captureMode:captureMode
                                                    result:result
                                             dispatchQueue:_dispatchQueue
                                                 messenger:_messenger
                                          orientationEvent:orientationEventSink
                                       videoRecordingEvent:videoRecordingEventSink
                                          imageStreamEvent:imageStreamEventSink];
    [self->_registry textureFrameAvailable:_textureId];
    
    __weak typeof(self) weakSelf = self;
    self.camera.onFrameAvailable = ^{
        [weakSelf.registry textureFrameAvailable:weakSelf.textureId];
    };
    
    // Assign texture id
    _textureId = [_registry registerTexture:self.camera];
    result(@(YES));
}

- (void)_handleFlashMode:(FlutterMethodCall*)call result:(FlutterResult)result  {
    NSString *flashMode = call.arguments[@"mode"];
    
    if (flashMode == nil || flashMode.length <= 0) {
        result([FlutterError errorWithCode:@"FLASH_MODE_ERROR" message:@"a flash mode NONE, AUTO, ALWAYS must be provided" details:nil]);
        return;
    }

    CameraFlashMode flash;
    if ([flashMode isEqualToString:@"NONE"]) {
        flash = None;
    } else if ([flashMode isEqualToString:@"ON"]) {
        flash = On;
    } else if ([flashMode isEqualToString:@"AUTO"]) {
        flash = Auto;
    } else if ([flashMode isEqualToString:@"ALWAYS"]) {
        flash = Always;
    } else {
        flash = None;
    }
    
    [_camera setFlashMode:flash];
    result(@(YES));
}

- (void)_handleGetTextures:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(@(_textureId));
}

@end
