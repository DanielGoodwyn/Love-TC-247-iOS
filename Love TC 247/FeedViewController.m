#import "FeedViewController.h"
@interface FeedViewController ()
@end
@implementation FeedViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.appInfo = [[AppInfo alloc] init];
}
- (IBAction)homeButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (IBAction)infoButtonClicked:(id)sender {
    [self toggleInfoView];
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
- (void)openSafariWithURL:(NSString*)string {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}
- (void)toggleInfoView {
    if (self.infoViewVisible) {
        self.infoViewVisible = NO;
        [UIView animateWithDuration:0.125 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.infoView setAlpha:0];
            [self.background setAlpha:.5];
            [self.backgroundLogo setAlpha:1];
        } completion:^(BOOL finished) {}];
    } else {
        self.infoViewVisible = YES;
        [UIView animateWithDuration:0.125 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.infoView setAlpha:.9];
            [self.background setAlpha:.25];
            [self.backgroundLogo setAlpha:.25];
        } completion:^(BOOL finished) {}];
    }
}

@end