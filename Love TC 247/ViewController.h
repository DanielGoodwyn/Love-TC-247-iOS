#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <UIKit/UIKit.h>
#import "AppInfo.h"
#import "NSStrinAdditions.h"
#import "AddNewBelieverViewController.h"
@interface ViewController : UIViewController
#pragma mark - info
@property AppInfo *appInfo;
#pragma mark - IBOutlets
@property IBOutlet UIView *infoView;
@property IBOutlet UITableView *tableView;
@property IBOutlet UIImageView *background;
@property IBOutlet UIImageView *backgroundLogo;
//@property IBOutlet UILabel *coordinatesLabel;
@property IBOutlet UIBarButtonItem *addNewBelieverButton;
@property IBOutlet UIImageView *userInfoImageView;
@property IBOutlet UIActivityIndicatorView *activityIndicator;
@property IBOutlet UIView *userInfoView;
@property IBOutlet UILabel *userInfoLabel;
@property IBOutlet UIView *toggleInfoButton;
#pragma mark - arrays
@property NSMutableArray *believerArray;
#pragma mark - bools
@property bool infoViewVisible;
@property bool userInfoViewVisible;
#pragma mark - NSStrings
@property NSString *beleiverId;
#pragma mark - Location Stuff
@property bool userLoggedIn;
@property bool trackingLocation;
@property CLLocationManager *locationManager;
@property NSString *latitude;
@property NSString *longitude;
@end