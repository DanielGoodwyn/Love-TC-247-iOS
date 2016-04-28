#import <Firebase/Firebase.h>
#import <UIKit/UIKit.h>
#import "AppInfo.h"
@interface FeedViewController : UIViewController
@property AppInfo *appInfo;
@property IBOutlet UIView *infoView;
@property IBOutlet UIImageView *background;
@property IBOutlet UIImageView *backgroundLogo;
@property bool infoViewVisible;
@end