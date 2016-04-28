#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>
#import <UIKit/UIKit.h>
#import "AppInfo.h"
#import "NSStrinAdditions.h"
@interface AccountViewController : UIViewController
@property AppInfo *appInfo;
@property bool userLoggedIn;
@property bool trackingLocation;
@property bool imagePreview;
@property IBOutlet UIScrollView *scrollView;
@property IBOutlet UIButton *imageButton;
@property IBOutlet UIButton *imagePreviewButton;
@property IBOutlet UIImageView *imageView;
@property IBOutlet UIImageView *imageViewPreview;
@property IBOutlet UIButton *logOutButton;
@property IBOutlet UIButton *logInButton;
@property IBOutlet UIButton *signUpButton;
@property IBOutlet UIButton *saveButton;
@property IBOutlet UIButton *toggleMapButton;
@property IBOutlet UIButton *mapButton;
@property IBOutlet UITextField *email;
@property IBOutlet UITextField *password;
@property IBOutlet UILabel *nameLabel;
@property IBOutlet UITextField *firstName;
@property IBOutlet UITextField *lastName;
@property IBOutlet UILabel *phoneLabel;
@property IBOutlet UITextField *phone;
@property IBOutlet UILabel *addressLabel;
@property IBOutlet UITextField *street;
@property IBOutlet UITextField *city;
@property IBOutlet UITextField *state;
@property IBOutlet UITextField *zip;
@property IBOutlet UILabel *churchLabel;
@property IBOutlet UITextField *church;
@property IBOutlet UIView *message;
@property IBOutlet UILabel *messageLabel;
@property IBOutlet UILabel *coordinatesLabel;
@property CLLocationManager *locationManager;
@property NSString *latitude;
@property NSString *longitude;
@end