#import "AppDelegate.h"

#import "LitClockBoss.h"

@interface AppDelegate ()

@property(weak) IBOutlet NSWindow *window;
@property(nonatomic) LitClockBoss *clockBoss;
@property(nonatomic) IBOutlet NSView *holderView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.clockBoss = [[LitClockBoss alloc] init];
  self.clockBoss.clockHolder = self.holderView;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

@end
