#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    }
    return YES;}
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}
- (void)applicationWillTerminate:(UIApplication *)application {}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary* userInfo = [notification userInfo];
    NSString *notificationBeleiverId = [userInfo valueForKey:@"id"];
    beleiverId = notificationBeleiverId;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"received_local_notification" object:nil];

}
@synthesize beleiverId;

@end
