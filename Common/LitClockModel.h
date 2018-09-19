#import <Foundation/Foundation.h>

@class Quote;

@interface LitClockModel : NSObject

- (Quote *)quoteForNow;

- (Quote *)quoteForWhen:(NSTimeInterval)when;

@end

NSTimeInterval TimerInterval(void);

NSTimeInterval SecondOfDay(void);

// plus 0.1 milliseconds into the next minute.
NSTimeInterval IntervalToNextMinute(void);
