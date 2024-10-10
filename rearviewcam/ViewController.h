//
//  ViewController.h
//  rearviewcam
//
//  Created by Sam Gardner on 1/31/24.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController

@property IBOutlet UILabel *infoLabel;
@property IBOutlet UIView *rearviewview;
@property AVCaptureVideoPreviewLayer *rearview;


@end

