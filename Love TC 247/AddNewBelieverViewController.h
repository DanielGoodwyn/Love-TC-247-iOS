#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <UIKit/UIKit.h>
#import "AppInfo.h"
#import "NSStrinAdditions.h"
@interface AddNewBelieverViewController : UIViewController
@property AppInfo *appInfo;
@property bool userLoggedIn;
@property bool trackingLocation;
@property bool isSaved;
@property bool wantsBaptism;
@property bool wantsChurch;
@property bool reminderOn;
@property NSString *username;
@property NSString *userid;
@property IBOutlet UINavigationBar *navbar;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UITextField *firstName;
@property IBOutlet UITextField *lastName;
@property IBOutlet UITextField *phone;
@property IBOutlet UITextField *email;
@property IBOutlet UITextField *address;
@property IBOutlet UISegmentedControl *isSavedSegmentedController;
@property IBOutlet UISegmentedControl *wantsBaptismController;
@property IBOutlet UISegmentedControl *wantsChurchController;
@property IBOutlet UITextView *notes;
@property IBOutlet UISwitch *reminderOnSwitch;
@property IBOutlet UIDatePicker *reminderDatePicker;
@property IBOutlet UIImageView *imageView;
@property IBOutlet UIButton *selfieButton;
@property IBOutlet UIButton *saveButton;
@property IBOutlet UILabel *coordinatesLabel;
@property IBOutlet UISwitch *trackingLocationSwitch;
@property CLLocationManager *locationManager;
@property NSString *latitude;
@property NSString *longitude;
@end