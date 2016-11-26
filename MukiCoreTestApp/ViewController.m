//
//  ViewController.m
//  MukiCoreTestApp
//
//  Created by Nikita Mosiakov on 29/08/16.
//  Copyright © 2016 Muki. All rights reserved.
//

#import "ViewController.h"

#import "MukiCupAPI.h"
#import "Utilities.h"

#define MAX_CUP_WIDTH       176.0f
#define MAX_CUP_HEIGHT      264.0f
#define CUP_IMAGE_SIZE CGSizeMake(MAX_CUP_WIDTH, MAX_CUP_HEIGHT)

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *textSender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *cupIDTextField;
@property (weak, nonatomic) IBOutlet UITextView *currentCup;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *mukiView;
@property (nonatomic) MukiCupAPI *cupAPI;
@property (nonatomic) Utilities *utilities;
@property (weak, nonatomic) IBOutlet UIStepper *fontStepper;


@end

@implementation ViewController


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark - UIViewController life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.utilities = [Utilities new];
}

- (void) viewDidLoad:(BOOL)animated{
    [self setNeedsStatusBarAppearanceUpdate];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

///////////////////////////////////////////////////////////////////////////////

#pragma mark - StringToImage

- (UIImage *)imageFromString:(NSString *)textToSend attributes:(NSDictionary *)attributes size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [textToSend drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - ImageResize

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - IBAction

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ImagePicker Controller

- (IBAction)dismiss:(id)sender
{
    [self.view endEditing:YES];
    if (_textField.text.length < 10){
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment                = NSTextAlignmentCenter;
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:80],
                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSParagraphStyleAttributeName:paragraphStyle};
        UIImage *image = [self imageFromString:_textField.text attributes:attributes size:CUP_IMAGE_SIZE];
        UIImage *resultedImage = [self.utilities scaleAndCropImage:image size:CUP_IMAGE_SIZE];
        resultedImage = [self.utilities ditheringImage:resultedImage contrastValue:3.0];
        self.imageView.image = resultedImage;
        [self.scrollView setContentOffset:CGPointMake(0, 0)animated: YES];

    } else if (_textField.text.length == 0){
        [self.scrollView setContentOffset:CGPointMake(0, 150)animated: YES];

    } else {
        NSDictionary *attributes = @{NSFontAttributeName            : [UIFont systemFontOfSize:_fontStepper.value],
                                     NSForegroundColorAttributeName : [UIColor whiteColor]};
        UIImage *image = [self imageFromString:_textField.text attributes:attributes size:CUP_IMAGE_SIZE];
        UIImage *resultedImage = [self.utilities scaleAndCropImage:image size:CUP_IMAGE_SIZE];
        resultedImage = [self.utilities ditheringImage:resultedImage contrastValue:3.0];
        self.imageView.image = resultedImage;
        [self.scrollView setContentOffset:CGPointMake(0, 0)animated: YES];

        
    }
}
- (IBAction)changeImage:(id)sender {
    NSLog (@"Hello, World!");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (IBAction)sendImage:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cupIdentifier = [defaults objectForKey:@"ID"];
    self.cupAPI = [MukiCupAPI new];
    UIImage *image = [UIImage imageNamed:@"img"];
    
    CGFloat contrastValue = 3.0;
    UIImage *resultedImage = [self.utilities scaleAndCropImage:image size:CUP_IMAGE_SIZE];
    resultedImage = [self.utilities ditheringImage:resultedImage contrastValue:contrastValue];
    
    self.imageView.image = resultedImage;
    
    [self.cupAPI sendImage:image toCup:cupIdentifier completion:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)sendText:(id)senderer {
    self.cupAPI = [MukiCupAPI new];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cupIdentifier = [defaults objectForKey:@"ID"];
    if (_textField.text.length < 10){
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment                = NSTextAlignmentCenter;
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:80],
                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSParagraphStyleAttributeName:paragraphStyle};
         UIImage *image = [self imageFromString:_textField.text attributes:attributes size:CUP_IMAGE_SIZE];
        CGFloat contrastValue = 3.0;
        UIImage *resultedImage = [self.utilities scaleAndCropImage:image size:CUP_IMAGE_SIZE];
        resultedImage = [self.utilities ditheringImage:resultedImage contrastValue:contrastValue];
        
        self.imageView.image = resultedImage;
        
        [self.cupAPI sendImage:image toCup:cupIdentifier completion:^(NSError * _Nullable error) {
            NSLog(@"%@", error); }];

    } else {
        NSDictionary *attributes = @{NSFontAttributeName            : [UIFont systemFontOfSize:_fontStepper.value],
                                     NSForegroundColorAttributeName : [UIColor whiteColor]};
        UIImage *image = [self imageFromString:_textField.text attributes:attributes size:CUP_IMAGE_SIZE];
        CGFloat contrastValue = 3.0;
        UIImage *resultedImage = [self.utilities scaleAndCropImage:image size:CUP_IMAGE_SIZE];
        resultedImage = [self.utilities ditheringImage:resultedImage contrastValue:contrastValue];
        
        self.imageView.image = resultedImage;
        
        [self.cupAPI sendImage:image toCup:cupIdentifier completion:^(NSError * _Nullable error) {
            NSLog(@"%@", error); }];

    }
}
- (IBAction)textTouch:(id)sender {
        [self.scrollView setContentOffset:CGPointMake(0, 150)animated: YES];
}

- (IBAction)picZoom:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [UIView beginAnimations:@"ScaleButton" context:NULL];
        [UIView setAnimationDuration: 0.5f];
        _imageView.transform = CGAffineTransformMakeScale(2.7,2.7);
        [UIView commitAnimations];
    }
    else
    {
        if (recognizer.state == UIGestureRecognizerStateCancelled
            || recognizer.state == UIGestureRecognizerStateFailed
            || recognizer.state == UIGestureRecognizerStateEnded)
        {
            [UIView beginAnimations:@"ScaleButton" context:NULL];
            [UIView setAnimationDuration: 0.5f];
            _imageView.transform = CGAffineTransformMakeScale(1.0,1.0);
            [UIView commitAnimations];
        }
    }
}

- (IBAction)clear:(id)sender
{
    NSDictionary *attributes = @{NSFontAttributeName            : [UIFont systemFontOfSize:_fontStepper.value],
                                 NSForegroundColorAttributeName : [UIColor blackColor], NSBackgroundColorAttributeName :[UIColor whiteColor]};
    UIImage *image = [self imageFromString:@"" attributes:attributes size:CUP_IMAGE_SIZE];
    UIImage *resultedImage = [self.utilities scaleAndCropImage:image size:CUP_IMAGE_SIZE];
    resultedImage = [self.utilities ditheringImage:resultedImage contrastValue:3.0];
    
    self.imageView.image = resultedImage;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cupIdentifier = [defaults objectForKey:@"ID"];
    self.cupAPI = [MukiCupAPI new];
    [self.cupAPI clearCupWithIdentifier:cupIdentifier completion:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)readDeviceInfo:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cupIdentifier = [self cupIdentifierFromSN];
    self.cupAPI = [MukiCupAPI new];
    [defaults setObject:cupIdentifier forKey:@"ID"];
    [defaults synchronize];
    [self.view endEditing:YES];
    [self.cupAPI readDeviceInfoWithIdentifier:cupIdentifier completion:^(DeviceInfo * _Nullable deviceInfo, NSError * _Nullable error) {
        _currentCup.text = @"";
        NSLog(@"%@", error);
        if (deviceInfo) {
            NSLog(@"%@", deviceInfo.description);
        }else {_currentCup.text = @"Connected!";}
    }];
}

////===================================================================
#pragma mark -
#pragma mark - Private methods

- (NSString *)cupIdentifierFromSN
{
    NSError *error;
    NSString *cupID = [MukiCupAPI cupIdentifierFromSerialNumber:self.cupIDTextField.text error:&error];
    NSLog(@"%@", error);
    return cupID;
}

@end
