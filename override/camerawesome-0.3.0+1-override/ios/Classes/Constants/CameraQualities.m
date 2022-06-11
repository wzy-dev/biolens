//
//  CameraQualities.m
//  camerawesome
//
//  Created by Dimitri Dessus on 24/07/2020.
//

#import "CameraQualities.h"

@implementation CameraQualities

+ (NSString *)selectVideoCapturePresset:(CGSize)size session:(AVCaptureSession *)session {
    if (!CGSizeEqualToSize(CGSizeZero, size)) {
        NSString *bestPresset = [CameraQualities selectPresetForSize:size];
        if ([session canSetSessionPreset:bestPresset]) {
            return bestPresset;
        }
    }
    
    return [self computeBestPressetWithSession:session];
}

+ (NSString *)selectVideoCapturePresset:(AVCaptureSession *)session {
    return [self computeBestPressetWithSession:session];
}

+ (CGSize)getSizeForPresset:(NSString *)presset {
    if (presset == AVCaptureSessionPreset3840x2160) {
        return CGSizeMake(3840, 2160);
    } else if (presset == AVCaptureSessionPreset1920x1080) {
        return CGSizeMake(1920, 1080);
    } else if (presset == AVCaptureSessionPreset1280x720) {
        return CGSizeMake(1280, 720);
    } else if (presset == AVCaptureSessionPreset1280x720) {
        return CGSizeMake(1280, 720);
    } else if (presset == AVCaptureSessionPreset640x480) {
        return CGSizeMake(640, 480);
    } else if (presset == AVCaptureSessionPreset352x288) {
        return CGSizeMake(352, 288);
    } else {
        // Default to HD
        return CGSizeMake(1280, 720);
    }
}

+ (NSString *)computeBestPressetWithSession:(AVCaptureSession *)session {
    for (NSDictionary *quality in kCameraQualities) {
        CGSize qualitySize = CGSizeMake([quality[@"width"] floatValue], [quality[@"height"] floatValue]);
        NSString *currentPresset = [CameraQualities selectPresetForSize:qualitySize];
        
        if ([session canSetSessionPreset:currentPresset]) {
            return currentPresset;
        }
    }
    
    // Default to HD
    return AVCaptureSessionPreset1280x720;
}

+ (NSString *)selectPresetForSize:(CGSize)size {
    if (size.width == 3840 && size.height == 2160) {
        if (@available(iOS 9.0, *)) {
            return AVCaptureSessionPreset3840x2160;
        } else {
            return AVCaptureSessionPreset1920x1080;
        }
    } else if (size.width == 1920 && size.height == 1080) {
        return AVCaptureSessionPreset1920x1080;
    } else if (size.width == 1280 && size.height == 720) {
        return AVCaptureSessionPreset1280x720;
    } else if (size.width == 640 && size.height == 480) {
        return AVCaptureSessionPreset640x480;
    } else if (size.width == 352 && size.height == 288) {
        return AVCaptureSessionPreset352x288;
    } else {
        // Default to HD
        return AVCaptureSessionPreset1280x720;
    }
}

@end
