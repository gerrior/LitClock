#import "LitClockModel.h"
#import "Quote.h"

// Uncomment the next line to advance every 6 seconds, not 60.
//#define FASTCLOCK 1  // For testing


static NSTimeInterval ParseDate(NSString *s) {
  NSTimeInterval t = 0;
  NSInteger h, m;
  NSScanner *scanner = [NSScanner scannerWithString:s];
  if ([scanner scanInteger:&h] &&
    [scanner scanString:@":" intoString:NULL] &&
    [scanner scanInteger:&m]) {
    t = h * 60*60 + m*60;
  } else {
    NSLog(@"unexpected");
  }
  return t;
}

static NSString *Sanitize(NSString *s) {
  if ([s hasPrefix:@"\""]) {
    if ([s hasSuffix:@"\""]) {
      NSRange r = NSMakeRange(1, MAX(0, (NSInteger)s.length - 2) );
      s = [s substringWithRange:r];
      s = [s stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
      s = [s stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    } else {
      // Note: I've fixed up the input file so this doesn't get hit.
      NSLog(@"unexpected");
    }
  }
  return s;
}

static NSArray *ConstructLitClockModel(void) {
  NSBundle *mainBundle = [NSBundle bundleForClass:[Quote class]];
  NSURL *litDataURL = [mainBundle URLForResource:@"litclock" withExtension:@"txt"];
  NSError *error = nil;
  NSString *litRaw = [NSString stringWithContentsOfURL:litDataURL encoding:NSUTF8StringEncoding error:&error];
  NSArray *lines = [litRaw componentsSeparatedByString:@"\n"];
  NSMutableArray *model = [NSMutableArray array];
  for (NSString *line in lines) {
    NSArray *fields = [line componentsSeparatedByString:@"|"];
    if (3 <= fields.count) {
      Quote *quote = [[Quote alloc] init];
      quote.when = ParseDate(fields[0]);
      quote.key = Sanitize(fields[1]);
      quote.quote = Sanitize(fields[2]);
      if (4 <= fields.count) {
        quote.work = Sanitize(fields[3]);
      }
      if (5 <= fields.count) {
        quote.author = Sanitize(fields[4]);
      }
      [model addObject:quote];
    }
  }
  // print all the times that have no quote
  return model;
}

static NSDate *Now(void) {
#if FASTCLOCK
  return [NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSinceReferenceDate] * 10];
#else
  return [NSDate date];
#endif
}

// plus 0.1 milliseconds into the next minute.
NSTimeInterval IntervalToNextMinute(void) {
  NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
  NSDate *date = Now();
  NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond | NSCalendarUnitNanosecond;
  NSDateComponents *parts = [calendar components:units fromDate:date];
  NSTimeInterval secondsIntoMinute = MAX(0, MIN(60, parts.second + parts.nanosecond / 1.0e9 + 1.0/1.0e4));
#if FASTCLOCK
  return fmod((60.0 - secondsIntoMinute), 6.0);
#else
  return 60.0 - secondsIntoMinute;
#endif
}


NSTimeInterval SecondOfDay(void) {
  NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
  NSDate *date = Now();
  NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond;
  NSDateComponents *parts = [calendar components:units fromDate:date];
  return parts.minute*60 + parts.hour*60*60 + parts.second;
}

NSTimeInterval TimerInterval(void) {
#if FASTCLOCK
  return 6;
#else
  return 60;
#endif
}


@interface LitClockModel ()
@property(nonatomic) NSArray<Quote *> *model;
@end

@implementation LitClockModel

- (instancetype)init {
  self = [super init];
  if (self) {
    _model = ConstructLitClockModel();
    if (nil == _model) {
      return nil;
    }
  }
  return self;
}


// If called multiple times in a minute, return the same value each time.
- (Quote *)quoteForNow {
  static NSTimeInterval lastWhen;
  static Quote *lastQuote;
  NSTimeInterval when = ((NSInteger)SecondOfDay() / 60) * 60;  // round down to minute.
  if (when == lastWhen && nil != lastQuote) {
    return lastQuote;
  }
  lastWhen = when;
  lastQuote = [self quoteForWhen:when];
  return lastQuote;
}

// If called multiple times in a minute, then cycle through each of the quotes for that minute
// in turn.
- (Quote *)quoteForWhen:(NSTimeInterval)when {
  NSUInteger count = [self.model count];
  NSUInteger lo = 0;
  for (;lo < count; ++lo) {
    Quote *quote = self.model[lo];
    if (when <= quote.when) {
      break;
    }
  }
  NSUInteger hi = lo+1;
  for (;hi < count; ++hi) {
    Quote *quote = self.model[hi];
    if (when < quote.when) {
      break;
    }
  }
  if (hi == lo + 1) {
    return self.model[lo];
  }
  NSUInteger index = [self range:NSMakeRange(lo, hi - lo) forWhen:when];
  if (index < count) {
    return self.model[index];
  }
  return nil;
}

- (NSUInteger)range:(NSRange)r forWhen:(NSTimeInterval)when {
  if (r.length <= 1) {
    return r.location;
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *dict = [[defaults dictionaryForKey:@"LitClockView"] mutableCopy];
  if (nil == dict) {
    dict = [NSMutableDictionary dictionary];
  }
  NSString *key = [NSString stringWithFormat:@"%ld", (long)(when/60)];
  NSNumber *n = dict[key];
  NSUInteger offset = [n unsignedIntegerValue];
  offset++;
  if (r.length <= offset) {
    offset = 0;
  }
  dict[key] = @(offset);
  [defaults setObject:dict forKey:@"LitClockView"];
  return r.location+offset;
}

@end
