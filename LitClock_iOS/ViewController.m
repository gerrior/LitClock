#import "ViewController.h"

#import "LitClockBoss.h"
#import "LitClockView.h"

@interface ViewController ()
@property(nonatomic) LitClockView *clockView;
@property(nonatomic) LitClockBoss *clockBoss;
@end


@implementation ViewController

- (void)viewDidLoad {
  self.clockBoss = [[LitClockBoss alloc] init];
  self.clockBoss.clockHolder = [self view];
}

@end
