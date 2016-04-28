#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#import "ViewController.h"
#import "AppDelegate.h"
@interface ViewController ()
@end
@implementation ViewController
#pragma mark - View Controller
- (void)viewDidLoad {
    [super viewDidLoad];
    self.trackingLocation = NO;
    self.appInfo = [[AppInfo alloc] init];
    [self setupLoactionManager];
    self.infoViewVisible = NO;
    self.userInfoViewVisible = NO;
    self.believerArray = [[NSMutableArray alloc] init];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
- (void)viewDidAppear:(BOOL)animated{
    [self checkIfUserLoggedIn];
    [self loadLocation];
    [self loadTrackingLocationMode];
    [self checkLocationTrackingMode];
    [self loadBelievers];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLocalNotification) name:@"received_local_notification" object:nil];
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.userInfoImageView.layer.cornerRadius = self.userInfoImageView.bounds.size.width/2;
}
-(void)receivedLocalNotification {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.beleiverId = appDelegate.beleiverId;
    if (self.beleiverId) {
        [self selecetBelieverById:self.beleiverId];
    }
}
#pragma mark - Button Clicks
- (IBAction)infoButtonClicked:(id)sender {
    [self toggleInfoView];
    [self checkIfUserLoggedIn];
    if (self.infoViewVisible) {
        [self.toggleInfoButton setAlpha:1];
    }
}
- (IBAction)websiteButtonClicked {
    [self openSafariWithURL:self.appInfo.website];
}
- (IBAction)facebookButtonClicked {
    [self openSafariWithURL:self.appInfo.facebook];
}
- (IBAction)instagramButtonClicked {
    [self openSafariWithURL:self.appInfo.instagram];
}
- (IBAction)twitterButtonClicked {
    [self openSafariWithURL:self.appInfo.twitter];
}
- (IBAction)youtubeButtonClicked {
    [self openSafariWithURL:self.appInfo.youtube];
}
- (IBAction)firebaseButtonClicked {
    [self openSafariWithURL:self.appInfo.firebaseMap];
}
- (IBAction)ywamButtonClicked {
    [self openSafariWithURL:self.appInfo.housingMap];
}
- (IBAction)addNewBelieverButtonClicked:(id)sender {
    [self checkIfUserLoggedIn];
    if (self.userLoggedIn) {
        AddNewBelieverViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewBelieverViewController"];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}
- (IBAction)toggleInfoButtonClicked:(id)sender {
    if (self.userInfoViewVisible) {
        [self toggleUserInfo];
    }
    if (self.infoViewVisible) {
        [self toggleInfoView];
    }
}
#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.believerArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableViewCellIdentifier = @"TableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
    }
    UIView *selectedbg = [[UIView alloc] initWithFrame:cell.frame];
    selectedbg.backgroundColor = self.appInfo.internationalOrange;
    cell.selectedBackgroundView = selectedbg;
    cell.backgroundColor = [UIColor colorWithWhite:.12 alpha:.9];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [self.believerArray[indexPath.row] objectForKey:@"name"];
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"❌";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.believerArray.count > indexPath.row){
        [self removeBeliever:[self.believerArray[indexPath.row] objectForKey:@"id"]];
    } else {
        [self loadBelievers];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selecetBelieverById:[self.believerArray[indexPath.row] objectForKey:@"id"]];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self selecetBelieverById:[self.believerArray[indexPath.row] objectForKey:@"id"]];
}
/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 return tableView.estimatedRowHeight;
 }
*/
#pragma mark - Helpers
- (void)selecetBelieverById:(NSString *)bid {
    self.userInfoLabel.text=@"";
    self.userInfoImageView.image=[[UIImage alloc] init];
    if (!self.userInfoViewVisible) {
        [self toggleUserInfo];
    }
    [self.activityIndicator setAlpha:1];
    [self.activityIndicator startAnimating];
    Firebase *path = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/new_believers/%@", self.appInfo.firebase, bid]];
    [path observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        NSString *address = [NSString stringWithFormat:@"%@", snapshot.value[@"address"]];
        NSString *email = [NSString stringWithFormat:@"%@", snapshot.value[@"email"]];
        NSString *is_baptized = [NSString stringWithFormat:@"%@", snapshot.value[@"is_baptized"]];
        NSString *is_churched = [NSString stringWithFormat:@"%@", snapshot.value[@"is_churched"]];
        NSString *is_saved = [NSString stringWithFormat:@"%@", snapshot.value[@"is_saved"]];
        NSString *location_latitude = [NSString stringWithFormat:@"%@", snapshot.value[@"location_latitude"]];
        NSString *location_longitude = [NSString stringWithFormat:@"%@", snapshot.value[@"location_longitude"]];
        NSString *name_first = [NSString stringWithFormat:@"%@", snapshot.value[@"name_first"]];
        NSString *name_last = [NSString stringWithFormat:@"%@", snapshot.value[@"name_last"]];
        NSString *notes = [NSString stringWithFormat:@"%@", snapshot.value[@"notes"]];
        NSString *phone = [NSString stringWithFormat:@"%@", snapshot.value[@"phone"]];
        NSString *selfie = [NSString stringWithFormat:@"%@", snapshot.value[@"selfie"]];
        NSString *timestamp = [NSString stringWithFormat:@"%@", snapshot.value[@"timestamp"]];
        //NSString *messenger_id = [NSString stringWithFormat:@"%@", snapshot.value[@"messenger_id"]];
        //NSString *messenger_name = [NSString stringWithFormat:@"%@", snapshot.value[@"messenger_name"]];
        
        NSString *name = [NSString stringWithFormat:@"%@ %@", name_first, name_last];
        self.userInfoLabel.text = [NSString stringWithFormat:@"Name: %@\rEmail: %@\rPhone: %@\rAddress: %@\rDetails: %@, %@, %@\rWhen: %@ \rWhere: %@, %@\rNotes: %@", name, email, phone, address, is_saved, is_baptized, is_churched, timestamp, location_latitude, location_longitude, notes];
        self.userInfoImageView.image = [self imageFromString:selfie];
        [self.activityIndicator setAlpha:0];
        [self.activityIndicator stopAnimating];
    }];
}
- (UIImage *)imageFromString:(NSString *)string {
    UIImage *image = [[UIImage alloc] init];
    if (string&&![string isEqualToString:@""]) {
        NSData *dataFromBase64=[NSData base64DataFromString:string];
        image = [[UIImage alloc]initWithData:dataFromBase64];
        self.userInfoImageView.layer.cornerRadius = self.userInfoImageView.bounds.size.width/2;
    }
    return image;
}
- (void)openSafariWithURL:(NSString*)string {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
#pragma mark - Toggle
- (void)toggleInfoView {
    if (self.infoViewVisible) {
        self.infoViewVisible = NO;
        if (self.userInfoViewVisible) {
            [self.toggleInfoButton setAlpha:1];
        } else {
            [self.toggleInfoButton setAlpha:0];
        }
        [UIView animateWithDuration:0.125 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.infoView setAlpha:0];
            if (!self.userInfoViewVisible) {
                [self.tableView setAlpha:1];
                [self.background setAlpha:.5];
                [self.backgroundLogo setAlpha:1];
            }
        } completion:^(BOOL finished) {}];
    } else {
        self.infoViewVisible = YES;
        [self.toggleInfoButton setAlpha:1];
        [UIView animateWithDuration:0.125 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.infoView setAlpha:.9];
            [self.tableView setAlpha:.25];
            [self.background setAlpha:.25];
            [self.backgroundLogo setAlpha:.25];
        } completion:^(BOOL finished) {}];
    }
}
- (void)toggleUserInfo {
    if (self.userInfoViewVisible) {
        self.userInfoViewVisible = NO;
        [self.toggleInfoButton setAlpha:0];
        [UIView animateWithDuration:0.125 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.userInfoView setAlpha:0];
            [self.userInfoImageView setAlpha:0];
            [self.toggleInfoButton setAlpha:0];
            if (!self.infoViewVisible) {
                [self.tableView setAlpha:1];
                [self.background setAlpha:.5];
                [self.backgroundLogo setAlpha:1];
            }
        } completion:^(BOOL finished) {}];
    } else {
        self.userInfoViewVisible = YES;
        [self.toggleInfoButton setAlpha:1];
        [UIView animateWithDuration:0.125 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.userInfoView setAlpha:.9];
            [self.userInfoImageView setAlpha:1];
            [self.toggleInfoButton setAlpha:1];
            [self.tableView setAlpha:.25];
            [self.background setAlpha:.25];
            [self.backgroundLogo setAlpha:.25];
        } completion:^(BOOL finished) {}];
    }
}
#pragma mark - Remove
- (void)removeBeliever: (NSString *)bid {
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    Firebase *path1 = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/new_believers/%@", self.appInfo.firebase, bid]];
    [path1 removeValue];
    NSString *string = [ NSString stringWithFormat: @"%@%@",self.appInfo.firebase,
                        [
                         [
                          [
                           [
                            NSString stringWithFormat: @"/users/%@/new_believers/%@", ref.authData.uid, bid
                            ] stringByReplacingOccurrencesOfString:@" " withString:@"%20"
                           ] stringByReplacingOccurrencesOfString:@":" withString:@"%3A"
                          ] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"
                         ]
                        ];
    Firebase *path2 = [[Firebase alloc] initWithUrl:string];
    [path2 removeValue];
    [self loadBelievers];
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *notifications = [app scheduledLocalNotifications];
    for (int i=0; i<[notifications count]; i++) {
        UILocalNotification* event = [notifications objectAtIndex:i];
        NSDictionary *userInfo = event.userInfo;
        NSString *beleiverId=[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"id"]];
        if ([beleiverId isEqualToString:bid]) {
            [app cancelLocalNotification:event];
            break;
        }
    }
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
#pragma mark - Load
- (void)loadBelievers {
    [self.believerArray removeAllObjects];
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *reference = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@/new_believers", self.appInfo.firebase, ref.authData.uid]];
        [reference observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value  != [NSNull null]) {
                NSDictionary *dictionary = snapshot.value;
                for (NSObject *object in dictionary) {
                    NSString *believerId = [NSString stringWithFormat:@"%@", object];
                    NSString *believerName = [NSString stringWithFormat:@"%@", [dictionary objectForKey:object]];
                    [self.believerArray addObject: @{@"id":believerId,@"name":believerName}];

                }
            }
            
            [self.believerArray sortUsingDescriptors:
             @[
               [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
               ]];
            
            [self.tableView reloadData];
        }];
    } else {
        [self.tableView reloadData];
    }
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
                    //self.coordinatesLabel.text = [NSString stringWithFormat:@"%@ %@",self.latitude,self.longitude];
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
#pragma mark - Check
- (void)checkIfUserLoggedIn {
    Firebase *ref = [[Firebase alloc] initWithUrl:self.appInfo.firebase];
    if (ref.authData) {
        Firebase *email = [[Firebase alloc] initWithUrl: [NSString stringWithFormat: @"%@/users/%@", self.appInfo.firebase, ref.authData.uid]];
        [email observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value != [NSNull null]) {
                self.userLoggedIn = YES;
                self.addNewBelieverButton.tintColor = self.appInfo.internationalOrange;
            }
        }];
    } else {
        self.userLoggedIn = NO;
        self.addNewBelieverButton.tintColor = [UIColor darkGrayColor];
    }
}
- (void)checkLocationTrackingMode {
    if (self.trackingLocation) {
        //self.coordinatesLabel.alpha = 1;
    } else {
        //self.coordinatesLabel.alpha = .75;
        //self.coordinatesLabel.text = @"🚫 GPS OFF";
    }
}
#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)currentLocation fromLocation:(CLLocation *)oldLocation {
    if (self.trackingLocation) {
        if (currentLocation != nil) {
            self.longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            self.latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
            //self.coordinatesLabel.text = [NSString stringWithFormat:@"%@ %@",self.latitude,self.longitude];
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
@end