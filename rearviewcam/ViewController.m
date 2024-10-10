//
//  ViewController.m
//  rearviewcam
//
//  Created by Sam Gardner on 1/31/24.
//

#import "ViewController.h"
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureInput.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *infoString = [NSString new];
    AVCaptureDeviceDiscoverySession *findACamera = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:[[NSArray alloc] initWithObjects:AVCaptureDeviceTypeExternal, nil] mediaType:nil position:AVCaptureDevicePositionUnspecified];
    if ([[findACamera devices] count] == 0) {
        infoString = @"No Devices Connected.";
    } else {
        for (AVCaptureDevice *device in [findACamera devices]) {
            if ([[device manufacturer] isEqualToString:@"MACROSILICON"]){
                // this is a capture card
                AVCaptureSession *captureSession = [AVCaptureSession new];
                AVCaptureDeviceInput *thisDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                
                [captureSession beginConfiguration];
                [captureSession addInput:thisDeviceInput];
                [captureSession commitConfiguration];
                
                self.rearview = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
                
                CGAffineTransform mirrorTransform = CGAffineTransformMakeScale(-1.0, 1.0); // Flip horizontally
                mirrorTransform = CGAffineTransformTranslate(mirrorTransform, -self.rearviewview.bounds.size.width, 0); // Translate to adjust for the flip
                [[self rearview] setAffineTransform:mirrorTransform];
                
                [[[self rearviewview] layer] addSublayer:[self rearview]];
                [[self rearview] setFrame:[[self rearviewview] bounds]];
                [[self rearview] setVideoGravity:AVLayerVideoGravityResize];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [captureSession startRunning];
                });
            } //else {
            //}
            infoString = [infoString stringByAppendingFormat:@"uniqueID: %@\nmodelID: %@\nlocalizedName: %@\nmanufacturer: %@\n\n", [device uniqueID], [device modelID], [device localizedName], [device manufacturer]];
        }
    }
    [[self infoLabel] setText:infoString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}


- (void)handleDeviceOrientationDidChange {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (self.rearview.connection.isVideoOrientationSupported) {
        AVCaptureVideoOrientation videoOrientation = [self videoOrientationFromDeviceOrientation:deviceOrientation];
        self.rearview.connection.videoOrientation = videoOrientation;
    }
    
    // Update the AVCaptureVideoPreviewLayer frame to match the new bounds of its container view
    self.rearview.frame = self.rearviewview.bounds;
}

- (AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
        default:
            return AVCaptureVideoOrientationPortrait;
    }
}


@end
