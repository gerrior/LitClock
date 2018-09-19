#import "LitClockBoss.h"

#import "LitClockModel.h"
#import "LitClockView.h"
#import "Quote.h"

#import <QuartzCore/QuartzCore.h>

@interface LitClockBoss () <CAAnimationDelegate>
@property(nonatomic) LitClockModel *model;
@property(nonatomic) NSTimeInterval timeSinceLastReestablish;
@property(nonatomic) LitClockView *clockView;
@property(nonatomic) LitClockView *otherView;
@property(nonatomic) Quote *quote;
@property(nonatomic) NSTimer *tickle;
@end

@implementation LitClockBoss

- (instancetype)init {
  self = [super init];
  if (self) {
    self.model = [[LitClockModel alloc] init];
    [self reestablishTickleTimer];
#if TARGET_OS_IPHONE
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(update) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
#endif
  }
  return self;
}

- (void)reestablishTickleTimer {
  self.timeSinceLastReestablish = [NSDate timeIntervalSinceReferenceDate];
  [self.tickle invalidate];
  self.tickle = [NSTimer scheduledTimerWithTimeInterval:IntervalToNextMinute()
                                                 target:self
                                               selector:@selector(establishTickleTimer)
                                               userInfo:nil
                                                repeats:NO];
}

- (void)establishTickleTimer {
  [self.tickle invalidate];
  self.tickle = [NSTimer scheduledTimerWithTimeInterval:TimerInterval()
                                                 target:self
                                               selector:@selector(tickle:)
                                               userInfo:nil
                                                repeats:YES];
}

- (void)setClockHolder:(XXView *)clockHolder {
  if (_clockHolder != clockHolder) {
    _clockHolder = clockHolder;
    if (clockHolder) {
      self.clockView = [[LitClockView alloc] initWithFrame:[clockHolder bounds]];
      [self.clockView setAutoresizingMask:0x3F];
      [clockHolder addSubview:self.clockView];
    }
  }
}

- (void)setClockView:(LitClockView *)clockView {
  _clockView = clockView;
  if (_clockView) {
    [self update];
  }
}

- (void)tickle:(NSTimer *)timer {
  [self update];
  static double kSecondsPerDay = 24*60*60;
  if (kSecondsPerDay < [NSDate timeIntervalSinceReferenceDate] - self.timeSinceLastReestablish) {
    [self reestablishTickleTimer];
  }
}

- (void)update {
  Quote *quote = [self.model quoteForNow];
  if (![quote isEqual:self.clockView.quote]) {
    if (nil == self.clockView.quote) {
      // just assign. Don't animate
      self.clockView.quote = quote;
    } else {
      [self animatePanLeft:quote];
    }
  }
}

// Notes: I tried multiple ways to write this so it woruld correctly in all of iOS, macOS, tvOS, and screensaver.
// animating the position worked on mac and screnaver, but not the iOS derivatives: leaving view jumps up.
// CATransition worked, but faded to white as it moved.
// affineTranfrom isn't animatable.
- (void)animatePanLeft:(Quote *)quote {
  static const NSTimeInterval kAnimationDuration = 0.5;
  static NSString *const kAnimationProperty = @"transform";
  CGRect frame = self.clockView.frame;
  LitClockView *otherView = [[LitClockView alloc] initWithFrame:frame];
  self.otherView = otherView;
  [otherView setAutoresizingMask:0x3F];
  otherView.quote = quote;
  
  [self.clockHolder addSubview:otherView];
  
  CATransform3D offLeft = CATransform3DMakeTranslation(-self.clockHolder.frame.size.width, 0, 0);
  CATransform3D offRight = CATransform3DMakeTranslation(self.clockHolder.frame.size.width, 0, 0);
  
  CABasicAnimation *newAnim = [CABasicAnimation animationWithKeyPath:kAnimationProperty];
  newAnim.duration = kAnimationDuration;
  newAnim.fromValue = [NSValue valueWithCATransform3D:offRight];
  newAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
  [otherView.layer addAnimation:newAnim forKey:kAnimationProperty];
  otherView.frame = self.clockView.frame;
  
  CABasicAnimation *oldAnim = [CABasicAnimation animationWithKeyPath:kAnimationProperty];
  oldAnim.duration = kAnimationDuration;
  oldAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
  oldAnim.toValue = [NSValue valueWithCATransform3D:offLeft];
  oldAnim.delegate = self;
  [self.clockView.layer addAnimation:oldAnim forKey:kAnimationProperty];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  [self.clockView removeFromSuperview];
  self.clockView = self.otherView;
}

@end
