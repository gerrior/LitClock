#import "LitClockView.h"

#import "LitClockModel.h"

#import "Quote.h"


static NSTimeInterval SecondOfDay(void) {
  NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
  NSDate *date = [NSDate date];
  NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond;
  NSDateComponents *parts = [calendar components:units fromDate:date];
  return parts.minute*60 + parts.hour*60*60 + parts.second;
}


@interface LitClockView ()
@property(nonatomic)NSArray *model;
@property(nonatomic)NSTimeInterval currentTime;
@property(nonatomic)NSTimer *tickle;
@end

@implementation LitClockView

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    self.currentTime = SecondOfDay();
    self.model = LitClockModel();
  }
  return self;
}

- (void)awakeFromNib {
  self.currentTime = SecondOfDay();
  self.model = LitClockModel();
  self.tickle = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(tickle:) userInfo:nil repeats:YES];
}

- (void)tickle:(NSTimer *)timer {
  [self setNeedsDisplay:YES];
 // [self drawDockImage];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  NSRect bounds = self.bounds;
  [[NSColor blackColor] set];
  NSRectFill(bounds);
  Quote *quote = [self quoteForNow];
  bounds = CGRectInset(bounds, 4, 4);
  NSAttributedString *as = [self attributedStringForQuote:quote rect:bounds fontScale:1000];
  [as drawInRect:bounds];
}

- (Quote *)quoteForNow {
  NSTimeInterval when = ((NSInteger)SecondOfDay() / 60) * 60;  // round down to minute.
  for (Quote *quote in self.model) {
    if (when <= quote.when) {
      return quote;
    }
  }
  return nil;
}

- (NSAttributedString *)candidateStringForQuote:(Quote *)quote fontScale:(float)fontScale {
  NSFont *font = [NSFont fontWithName:@"Palatino" size:fontScale * 0.5];
  NSFont *fontBold = [NSFont fontWithName:@"Palatino Bold" size:fontScale * 0.55];
  NSFont *fontSmall = [NSFont fontWithName:@"Palatino" size:fontScale * 0.3];
  NSFont *fontSmallItalic = [NSFont fontWithName:@"Palatino Italic" size:(fontScale *  0.3)];
  NSRange r = [quote.quote rangeOfString:quote.key options:NSCaseInsensitiveSearch];
  NSString *prefix = quote.quote;
  NSString *bold = @"";
  NSString *suffix = @"";
  if (0 != r.length) {
    prefix = [quote.quote substringToIndex:r.location];
    bold = [quote.quote substringWithRange:r];
    suffix = [quote.quote substringFromIndex:r.location + r.length];
  }
  NSString *work = @"";
  if (quote.work.length) {
    work = [@"\n – " stringByAppendingString:quote.work];
  }
  NSString *author = @"";
  if (quote.author.length) {
    author = [@" – " stringByAppendingString:quote.author];
  }
  NSDictionary *quoteDict = @{NSForegroundColorAttributeName: [NSColor lightGrayColor],
    NSFontAttributeName: font};
  NSDictionary *boldDict = @{NSForegroundColorAttributeName: [NSColor whiteColor],
    NSFontAttributeName: fontBold };
  NSDictionary *workDict = @{NSForegroundColorAttributeName: [NSColor grayColor],
    NSFontAttributeName: fontSmall };
  NSDictionary *authorDict = @{NSForegroundColorAttributeName: [NSColor grayColor],
   NSFontAttributeName: fontSmallItalic};
  NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:prefix attributes:quoteDict];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:bold attributes:boldDict]];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:suffix attributes:quoteDict]];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:work attributes:workDict]];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:author attributes:authorDict]];
  return as;
}

- (NSAttributedString *)attributedStringForQuote:(Quote *)quote rect:(NSRect)bounds fontScale:(float)fontScaleInitial {
  int lo = 4;
  int hi = fontScaleInitial;
  int fontScale = fontScaleInitial;
  CGSize bigSize = bounds.size;
  bigSize.height *= 20;
  NSAttributedString *as = [self candidateStringForQuote:quote fontScale:fontScale];
  CGSize textSize = [as boundingRectWithSize:bigSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
  while (!(bounds.size.width == textSize.width && textSize.height == bounds.size.height) && 2 < hi - lo) {
      if (textSize.height < bounds.size.height) {
        lo += (hi-lo)/2;
      } else {
        hi -= (hi-lo)/2;
      }
      fontScale = lo + (hi-lo)/2;
      as = [self candidateStringForQuote:quote fontScale:fontScale];
      textSize = [as boundingRectWithSize:bigSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;;
  }
  if (bounds.size.height < textSize.height) {
    fontScale--;
    as = [self candidateStringForQuote:quote fontScale:fontScale];
  }
  return as;
}

- (void)drawDockImage {
    // without the copy, successive draws would dirty the image.
    NSImage *iconImage = [[NSImage imageNamed:@"Blank.icns"] copy];
    [iconImage lockFocus];
    NSRect bounds = NSMakeRect(3, 3, 118, 95);
    [self drawRect:bounds];
    [iconImage unlockFocus];
    [NSApp setApplicationIconImage:iconImage];
}

@end

