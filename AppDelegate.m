// Copyright 2019 The MediaPipe Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "AppDelegate.h"
#import "IQKeyboardManager/IQKeyboardManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    [IQKeyboardManager.sharedManager setEnable:YES];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for
  // certain types of temporary interruptions (such as an incoming phone call or SMS message) or
  // when the user quits the application and it begins the transition to the background state. Use
  // this method to pause ongoing tasks, disable timers, and invalidate graphics rendering
  // callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store
  // enough application state information to restore your application to its current state in case
  // it is terminated later. If your application supports background execution, this method is
  // called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the active state; here you can undo
  // many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If
  // the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also
  // applicationDidEnterBackground:.
}


@end

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color{
    self.borderColor = color.CGColor;
}

@end

@implementation UISearchBar (Additions)

- (void) setNilBackground: (BOOL) isNil {
    if(isNil) {
        self.backgroundImage = [[UIImage alloc] init];
    }
}

@end

@implementation UIView (Additions)

- (void) setDefaultBackground: (BOOL) set {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height/8)];
    imgView.image = [UIImage imageNamed:@"bg_top"];
    imgView.layer.masksToBounds = NO;
    imgView.layer.shadowOffset = CGSizeMake(0, 5);
    imgView.layer.shadowRadius = 10.0;
    imgView.layer.shadowOpacity = 0.2;
    [self insertSubview:imgView atIndex:0];
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    imgView.image = [UIImage imageNamed:@"bg"];
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self insertSubview:imgView atIndex:0];
}

- (void) setShadowColorFromUIColor:(UIColor *)color {
    self.layer.shadowColor = color.CGColor;
}

@end

@implementation UITextView (Additions)

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if(action == @selector(copy:))
        return YES;
    if(action == @selector(selectAll:))
        return YES;
    
    return NO;
}

@end

@implementation UITextField (Additions)

- (CGRect) setTextRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
