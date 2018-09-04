#import "LitClockModel.h"
#import "Quote.h"


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

NSArray *LitClockModel(void) {
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
  return model;
}
