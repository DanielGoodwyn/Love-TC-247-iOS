#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#import "AccountViewController.h"
@interface AccountViewController ()
@end
@implementation AccountViewController
#pragma mark - View Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.appInfo = [[AppInfo alloc] init];
    [self setupLoactionManager];
    self.userLoggedIn = NO;
    self.trackingLocation = NO;
    self.imagePreview = NO;
    [self loadTrackingLocationMode];
    [self loadInfo];
    [self checkLocationTrackingMode];
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.imageViewPreview.layer.cornerRadius = self.imageViewPreview.bounds.size.width/2;
}
#pragma mark - Button Clicks
- (IBAction)homeButtonClicked:(id)sender {
    [self dismiss];
}
- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self signup];
    }];
}
- (IBAction)signUpButtonClicked:(id)sender {
    [self signup];
}
- (IBAction)logInButtonClicked:(id)sender {
    [self login];
}
- (IBAction)logOutButtonClicked:(id)sender {
    [self logout];
}
- (IBAction)saveButtonClicked:(id)sender {
    [self saveInfo];
}
- (IBAction)mapButtonClicked:(id)sender {
    if (self.trackingLocation) {
        [self openSafariWithURL:[NSString stringWithFormat:@"https://www.google.com/maps/place/%@,%@",self.latitude,self.longitude]];
    }
}
- (IBAction)toggleMapButtonClicked:(id)sender {
    [self toggleMapMode];
}
#pragma mark - Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.25 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(0,textField.frame.origin.y-70);
    } completion:^(BOOL finished) {}];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.userLoggedIn) {
        if (textField.tag == 0) {
            [self.firstName becomeFirstResponder];
        } else if (textField.tag == 2) {
            [self.lastName becomeFirstResponder];
        } else if (textField.tag == 3) {
            [self.phone becomeFirstResponder];
        } else if (textField.tag == 4) {
            [self.street becomeFirstResponder];
        } else if (textField.tag == 5) {
            [self.city becomeFirstResponder];
        } else if (textField.tag == 6) {
            [self.state becomeFirstResponder];
        } else if (textField.tag == 7) {
            [self.zip becomeFirstResponder];
        } else if (textField.tag == 8) {
            [self.church becomeFirstResponder];
        } else if (textField.tag == 9) {
            [self saveInfo];
            [self dismiss];
        }
    } else {
        if (textField.tag == 0) {
            [self.password becomeFirstResponder];
        } else if (textField.tag == 1) {
            [self signup];
        }
    }
    return YES;
}
#pragma mark - User
-(void)signup{
    if (self.userLoggedIn) {
        self.password.enabled = NO;
        self.password.alpha = .1;
        [self saveInfo];
    } else {
        self.password.enabled = YES;
        self.password.alpha = 1;
        Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
        [ref createUser:self.email.text password:self.password.text withValueCompletionBlock:^(NSError *error, NSDictionary *dictionary) {
            if (error) {
                [self showMessageWithString:error.description];
                [self login];
            } else {
                [self showMessageWithString:@"signed up."];
                self.trackingLocation = NO;
                [self saveTrackingLocationMode];
                [self login];
            }
        }];
    }
}
-(void)login{
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    [ref authUser:self.email.text password:self.password.text withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            [self showMessageWithString:error.description];
        } else {
            [self showMessageWithString:@"logged in."];
            [[[[ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] childByAppendingPath:@"info/email"] setValue:self.email.text];
        }
        [self loadInfo];
    }];
}
-(void)logout{
    self.email.text = @"";
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    [ref unauth];
    [self showMessageWithString:@"logged out."];
    [self loadInfo];
}
#pragma mark - Toggle
- (void)toggleMapMode {
    if (self.trackingLocation) {
        self.trackingLocation = NO;
    } else {
        self.trackingLocation = YES;
    }
    [self checkLocationTrackingMode];
    [self saveTrackingLocationMode];
}
#pragma mark - Check
- (void)checkLocationTrackingMode {
    if (self.trackingLocation) {
        self.coordinatesLabel.alpha = 1;
        [self.toggleMapButton setTitle:@"❌" forState:UIControlStateNormal];
        self.mapButton.alpha = 1;
        [self.locationManager startUpdatingLocation];
    } else {
        self.coordinatesLabel.alpha = .75;
        self.coordinatesLabel.text = @"🚫 GPS OFF";
        [self.toggleMapButton setTitle:@"📡" forState:UIControlStateNormal];
        self.mapButton.alpha = .25;
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        [self.locationManager stopMonitoringSignificantLocationChanges];
        [self.locationManager stopMonitoringVisits];
    }
}
#pragma mark - Helpers
- (void)openSafariWithURL:(NSString*)string {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
-(void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)showMessageWithString:(NSString *)string {
    self.messageLabel.text = string;
    self.message.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelay:1];
    self.message.alpha = 0.0f;
    [UIView commitAnimations];
}
#pragma mark - Save
- (void)saveInfo {
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *firebase = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info", self.appInfo.firebase, ref.authData.uid]];
        NSDictionary *dictionary = @{
                                     @"email" : self.email.text,
                                     @"name_first" : self.firstName.text,
                                     @"name_last" : self.lastName.text,
                                     @"phone": self.phone.text,
                                     @"address_street": self.street.text,
                                     @"address_city": self.city.text,
                                     @"address_state": self.state.text,
                                     @"address_zip": self.zip.text,
                                     @"church": self.church.text,
                                     @"tracking_location_mode": [NSNumber numberWithBool:self.trackingLocation]
                                     };
        [firebase setValue: dictionary];
    }
}
- (void)saveLocation {
    if (self.trackingLocation) {
        Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
        if (ref.authData) {
            Firebase *latitude = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info/location_latitude", self.appInfo.firebase, ref.authData.uid]];
            [latitude setValue: self.latitude];
            Firebase *longitude = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info/location_longitude", self.appInfo.firebase, ref.authData.uid]];
            [longitude setValue: self.longitude];
        }
    }
    [self checkLocationTrackingMode];
}
- (void)saveTrackingLocationMode {
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *trackingLocationMode = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info/tracking_location_mode", self.appInfo.firebase, ref.authData.uid]];
        [trackingLocationMode setValue: [NSNumber numberWithBool:self.trackingLocation]];
    }
    [self checkLocationTrackingMode];
}
#pragma mark - Load
- (void)loadInfo {
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *userInfo = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info", self.appInfo.firebase, ref.authData.uid]];
        [userInfo observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value != [NSNull null]) {
                self.imageView.alpha = 1;
                self.imageButton.alpha = 1;
                self.imagePreviewButton.alpha = 1;
                self.userLoggedIn = YES;
                self.signUpButton.alpha = 0;
                self.logInButton.alpha = 0;
                self.logOutButton.alpha = 1;
                self.password.enabled = NO;
                self.password.alpha = .1;
                self.password.text = @"";
                self.nameLabel.alpha = 1;
                self.firstName.enabled = YES;
                self.firstName.alpha = 1;
                self.lastName.enabled = YES;
                self.lastName.alpha = 1;
                self.phoneLabel.alpha = 1;
                self.phone.enabled = YES;
                self.phone.alpha = 1;
                self.addressLabel.alpha = 1;
                self.street.enabled = YES;
                self.street.alpha = 1;
                self.city.enabled = YES;
                self.city.alpha = 1;
                self.state.enabled = YES;
                self.state.alpha = 1;
                self.zip.enabled = YES;
                self.zip.alpha = 1;
                self.churchLabel.alpha = 1;
                self.church.enabled = YES;
                self.church.alpha = 1;
                self.email.text = [snapshot.value valueForKey:@"email"];
                self.firstName.text = [snapshot.value valueForKey:@"name_first"];
                self.lastName.text = [snapshot.value valueForKey:@"name_last"];
                self.phone.text = [snapshot.value valueForKey:@"phone"];
                self.street.text = [snapshot.value valueForKey:@"address_street"];
                self.city.text = [snapshot.value valueForKey:@"address_city"];
                self.state.text = [snapshot.value valueForKey:@"address_state"];
                self.zip.text = [snapshot.value valueForKey:@"address_zip"];
                self.church.text = [snapshot.value valueForKey:@"church"];
                if (self.trackingLocation) {
                    self.longitude = [snapshot.value valueForKey:@"location_longitude"];
                    self.latitude = [snapshot.value valueForKey:@"location_latitude"];
                }
                self.saveButton.alpha = 1;
            }
        }];
    } else {
        self.imageView.alpha = 0;
        self.imageButton.alpha = 0;
        self.imagePreviewButton.alpha = 0;
        self.userLoggedIn = NO;
        self.signUpButton.alpha = 1;
        self.logInButton.alpha = 1;
        self.logOutButton.alpha = 0;
        self.email.text = @"";
        self.password.enabled = YES;
        self.password.alpha = 1;
        self.password.text = @"";
        self.nameLabel.alpha = 0;
        self.firstName.enabled = NO;
        self.firstName.alpha = 0;
        self.firstName.text = @"";
        self.lastName.enabled = NO;
        self.lastName.alpha = 0;
        self.lastName.text = @"";
        self.phoneLabel.alpha = 0;
        self.phone.enabled = NO;
        self.phone.alpha = 0;
        self.phone.text = @"";
        self.addressLabel.alpha = 0;
        self.street.enabled = NO;
        self.street.alpha = 0;
        self.street.text = @"";
        self.city.enabled = NO;
        self.city.alpha = 0;
        self.city.text = @"";
        self.state.enabled = NO;
        self.state.alpha = 0;
        self.state.text = @"";
        self.zip.enabled = NO;
        self.zip.alpha = 0;
        self.zip.text = @"";
        self.churchLabel.alpha = 0;
        self.church.enabled = NO;
        self.church.alpha = 0;
        self.church.text = @"";
        self.saveButton.alpha = 0;
        [self.email becomeFirstResponder];
    }
    [self checkLocationTrackingMode];
    [self loadImage];
}
- (void)loadLocation {
    [self checkLocationTrackingMode];
    if (self.trackingLocation) {
        Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
        if (ref.authData) {
            Firebase *reference = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info", self.appInfo.firebase, ref.authData.uid]];
            [reference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (snapshot.value != [NSNull null]) {
                    self.latitude = snapshot.value[@"location_latitude"];
                    self.longitude = snapshot.value[@"location_longitude"];
                    self.coordinatesLabel.text = [NSString stringWithFormat:@"%@ %@",self.latitude,self.longitude];
                }
                [self checkLocationTrackingMode];
            }];
        }
    }
}
- (void)loadTrackingLocationMode {
    [self checkLocationTrackingMode];
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *reference = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info", self.appInfo.firebase, ref.authData.uid]];
        [reference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value != [NSNull null]) {
                self.trackingLocation = [snapshot.value[@"tracking_location_mode"] boolValue];
            }
            [self checkLocationTrackingMode];
        }];
    }
}
#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)currentLocation fromLocation:(CLLocation *)oldLocation {
    if (self.trackingLocation) {
        if (currentLocation != nil) {
            self.longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            self.latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
            self.coordinatesLabel.text = [NSString stringWithFormat:@"%@ %@",self.latitude,self.longitude];
            [self saveLocation];
        }
    }
}
- (void)setupLoactionManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            }
        }
    }
    [self.locationManager startUpdatingLocation];
}
#pragma mark - Image Stuff
- (void)takePicture {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:picker animated:YES completion:^{}];
}
- (void)imagePickerController:(UIImagePickerController *)picker  didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self saveImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveImage {
    NSData *data = UIImageJPEGRepresentation(self.imageView.image, 0.75);
    NSString *string = [NSString base64StringFromData:data length:(int)[data length]];
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *firebase = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/image", self.appInfo.firebase, ref.authData.uid]];
        [firebase setValue: string];
    }
    [self loadImage];
}
- (void)loadImage {
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *firebase = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/", self.appInfo.firebase, ref.authData.uid]];
        [firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value != [NSNull null]) {
                NSData *dataFromBase64=[NSData base64DataFromString:snapshot.value[@"image"]];
                UIImage *image = [[UIImage alloc]initWithData:dataFromBase64];
                self.imageView.image = image;
                self.imageViewPreview.image = image;
                self.imageViewPreview.layer.cornerRadius = self.imageViewPreview.bounds.size.width/2;
            }
        }];
    }
}
- (IBAction)previewImageButtonClicked:(id)sender {
    [self togglePreviewImage];
}
- (void)togglePreviewImage {
    if (self.imagePreview) {
        self.imagePreview = NO;
        self.imageView.alpha = 1;
        self.imageViewPreview.alpha = 0;
        self.imagePreviewButton.bounds = self.imageView.bounds;
    } else {
        self.imagePreview = YES;
        self.imageView.alpha = 0;
        self.imageViewPreview.alpha = 1;
        self.imagePreviewButton.bounds = self.imageViewPreview.bounds;
    }
}
- (IBAction)saveImageButtonClicked:(id)sender {
    [self takePicture];
}
@end