#import "AppInfo.h"
@implementation AppInfo
-(id)init{
    if (self = [super init]) {
        self.firebase = @"https://love-tc.firebaseio.com";
        self.firebaseMap = @"https://www.google.com/maps/";
        self.housingMap = @"https://www.google.com/maps/";
        self.website = @"http://www.lovetc247.com/";
        self.facebook = @"https://www.facebook.com/lovetwincities247";
        self.instagram = @"https://www.instagram.com/trinity_works/";
        self.twitter = @"https://www.twitter.com/lovetc247";
        self.youtube = @"https://www.youtube.com/channel/UC8QPRNDj-EFzItD0GVOvtaQ";
        self.internationalOrange = [UIColor colorWithRed:1 green:79./255. blue:0 alpha:1];
    }
    return self;
}
@end