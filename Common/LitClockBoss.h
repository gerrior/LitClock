#import <Foundation/Foundation.h>

#import "XXView.h"

@class LitClockView;

@interface LitClockBoss : NSObject
@property(nonatomic) XXView *clockHolder;

- (void)update;

@end
