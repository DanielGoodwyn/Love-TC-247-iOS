#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#import "AddNewBelieverViewController.h"
@interface AddNewBelieverViewController ()
@end
@implementation AddNewBelieverViewController
#pragma mark - View Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.appInfo = [[AppInfo alloc] init];
    [self setupLoactionManager];
    self.userLoggedIn = NO;
    self.trackingLocation = YES;
    self.reminderOn = YES;
    self.longitude = @"";
    self.latitude = @"";
    [self loadUser];
    [self loadTrackingLocationMode];
    [self checkLocationTrackingMode];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    NSDateComponents *hourComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    hourComponent.hour = -1;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    NSDate *finalNextDate = [theCalendar dateBySettingHour:11 minute:30 second:0 ofDate:nextDate options:0];
    self.reminderDatePicker.date = finalNextDate;
}
- (void)viewDidAppear:(BOOL)animated{
    [self.firstName becomeFirstResponder];
}
- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)selfieButtonClicked:(id)sender {
    [self takePicture];
}
- (IBAction)saveButtonClicked:(id)sender {
    [self saveNewBeliever];
}
- (IBAction)doneButtonClicked:(id)sender {
    [self saveNewBeliever];
}
- (IBAction)backgroundViewTapped:(id)sender {
    [self resignFirstResponders];
}
#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.25 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(0,textView.frame.origin.y-70);
    } completion:^(BOOL finished) {}];
}
#pragma mark - Text Field Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.25 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (textField.tag==0) {
            self.scrollView.contentOffset = CGPointMake(0,textField.frame.origin.y-20);
        } else {
            self.scrollView.contentOffset = CGPointMake(0,textField.frame.origin.y-70);
        }
    } completion:^(BOOL finished) {}];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        [self.lastName becomeFirstResponder];
    } else if (textField.tag == 1) {
        [self.phone becomeFirstResponder];
    } else if (textField.tag == 2) {
        [self.email becomeFirstResponder];
    } else if (textField.tag == 3) {
        [self.address becomeFirstResponder];
    } else if (textField.tag == 4) {
        [self.address resignFirstResponder];
        [UIView animateWithDuration:0.25 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.scrollView.contentOffset = CGPointMake(0,textField.frame.origin.y-20);
        } completion:^(BOOL finished) {}];
    }
    return YES;
}
#pragma mark - Delegates
- (IBAction)isSavedControlClicked:(id)sender {
    [self resignFirstResponders];
}
- (IBAction)wantsBaptismControlClicked:(id)sender {
    [self resignFirstResponders];
}
- (IBAction)wantsChurchControlClicked:(id)sender {
    [self resignFirstResponders];
}
- (IBAction)reminderSwitchDown:(id)sender {
    [self resignFirstResponders];
}
- (IBAction)reminderSwitchValueChanged:(id)sender {
    if (self.reminderOnSwitch.isOn) {
        self.reminderOn = YES;
    } else {
        self.reminderOn = NO;
    }
}
#pragma mark - Check
- (void)checkLocationTrackingMode {
    if (self.trackingLocationSwitch.on) {
        self.trackingLocation = YES;
    } else {
        self.trackingLocation = NO;
    }
    if (self.trackingLocation) {
        self.coordinatesLabel.alpha = 1;
        [self.locationManager startUpdatingLocation];
    } else {
        self.latitude = @"";
        self.longitude = @"";
        self.coordinatesLabel.alpha = .75;
        self.coordinatesLabel.text = @"🚫 GPS OFF";
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        [self.locationManager stopMonitoringSignificantLocationChanges];
        [self.locationManager stopMonitoringVisits];
    }
}
- (IBAction)locationTrackingSwitchClicked:(id)sender {
    [self checkLocationTrackingMode];
}
#pragma mark - Save
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
- (void)saveNewBeliever {
    NSString *timestamp = [[NSDate date] description];
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.75);
    NSString *imageString = [NSString base64StringFromData:imageData length:(int)[imageData length]];
    Firebase *believer = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/new_believers/%@_%@", self.appInfo.firebase, self.userid, timestamp]];
    NSDictionary *believerDictionary = @{
                                         @"name_first" : self.firstName.text,
                                         @"name_last" : self.lastName.text,
                                         @"phone": self.phone.text,
                                         @"email" : self.email.text,
                                         @"address": self.address.text,
                                         @"notes": self.notes.text,
                                         @"messenger_name": self.username,
                                         @"messenger_id": self.userid,
                                         @"timestamp": timestamp,
                                         @"is_saved": [self.isSavedSegmentedController titleForSegmentAtIndex:self.isSavedSegmentedController.selectedSegmentIndex],
                                         @"is_baptized": [self.wantsBaptismController titleForSegmentAtIndex:self.wantsBaptismController.selectedSegmentIndex],
                                         @"is_churched": [self.wantsChurchController titleForSegmentAtIndex:self.wantsChurchController.selectedSegmentIndex],
                                         @"selfie": imageString,
                                         @"location_longitude": self.longitude,
                                         @"location_latitude": self.latitude
                                         };
    [believer setValue: believerDictionary];
    Firebase *path = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/new_believers/", self.appInfo.firebase, self.userid]];
    Firebase *newBeliever = [path childByAppendingPath: [NSString stringWithFormat: @"%@_%@", self.userid, timestamp]];
    [newBeliever setValue: [NSString stringWithFormat:@"%@ %@", self.firstName.text, self.lastName.text]];
    [self dismissViewControllerAnimated:YES completion:nil];    
    if (self.reminderOn) {
        NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat: @"%@_%@", self.userid, timestamp], @"id", nil];
        UIApplication *application = [UIApplication sharedApplication];
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = self.reminderDatePicker.date;
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.repeatInterval = 0;
        notification.alertTitle = @"Reminder";
        notification.alertBody = [NSString stringWithFormat: @"Don't forget to follow up with %@.", self.firstName.text];
        notification.alertAction = @"see contact";
        notification.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
        notification.hasAction = YES;
        notification.userInfo = dictionary;
        [application scheduleLocalNotification:notification];
    }
}
#pragma mark - Load
- (void)loadUser {
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *user = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/info/name_first", self.appInfo.firebase, ref.authData.uid]];
        [user observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value != [NSNull null]) {
                self.username = snapshot.value;
                self.userid = ref.authData.uid;
                self.navbar.topItem.title = [NSString stringWithFormat:@"%@ - Add New Beleiver", self.username];
            }
            self.userLoggedIn = YES;
            if (self.userLoggedIn) {
            }
        }];
    } else {
        self.userLoggedIn = NO;
    }
}
/*- (void)loadLocation {
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
}*/
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
    if (self.trackingLocationSwitch.on) {
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
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Helpers
- (void)resignFirstResponders {
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
    [self.phone resignFirstResponder];
    [self.email resignFirstResponder];
    [self.address resignFirstResponder];
    [self.notes resignFirstResponder];
}
@end