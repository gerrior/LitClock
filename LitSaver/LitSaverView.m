#import "LitSaverView.h"

#import "LitClockBoss.h"
#import "LitClockView.h"

@interface LitSaverView ()
@property(nonatomic) LitClockBoss *clockBoss;
@end

@implementation LitSaverView
  
- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
    [self setAnimationTimeInterval:30.0];
    NSView *holderView = [[NSView alloc] initWithFrame:frame];
    [holderView setWantsLayer:YES];
    self.clockBoss = [[LitClockBoss alloc] init];
    self.clockBoss.clockHolder = holderView;
    [self addSubview:holderView];
  }
  return self;
}
  
//- (void)startAnimation {
//  [super startAnimation];
//}
//  
//- (void)stopAnimation {
//  [super stopAnimation];
//}
  
//- (void)drawRect:(NSRect)rect {
//  [super drawRect:rect];
//  [self.clockBoss update];
//}

- (void)animateOneFrame {
  [self.clockBoss update];
}
  
- (BOOL)hasConfigureSheet {
  return NO;
}
  
- (NSWindow*)configureSheet {
  return nil;
}
  
  @end
