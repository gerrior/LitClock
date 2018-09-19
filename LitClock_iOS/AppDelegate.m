#import "AppDelegate.h"

#import "ViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [application setIdleTimerDisabled:YES];
  CGRect bounds = [[UIScreen mainScreen] bounds];
  self.window = [[UIWindow alloc] initWithFrame:bounds];
  ViewController *vc = [[ViewController alloc] init];
  [self.window setRootViewController:vc];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
