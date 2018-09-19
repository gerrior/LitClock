#import "LitClockView.h"

#import "LitClockModel.h"

#import "Quote.h"

#if TARGET_OS_IPHONE
typedef UIColor XXColor;
typedef UIFont XXFont;
static void XXRectFill(CGRect rect) { UIRectFill(rect); }
#else
typedef NSColor XXColor;
typedef NSFont XXFont;
static void XXRectFill(NSRect rect) { NSRectFill(rect); }
#endif

@implementation LitClockView

- (void)setQuote:(Quote *)quote {
  if (![_quote isEqual:quote]) {
    _quote = quote;
    [self setNeedsDisplayInRect:self.bounds];
  }
}

// Without this, rotating the iOS version doesn't re-layout.
- (void)setFrame:(CGRect)frame {
  CGSize oldFrameSize = self.frame.size;
  [super setFrame:frame];
  if (!CGSizeEqualToSize(oldFrameSize, frame.size)) {
    [self setNeedsDisplayInRect:self.bounds];
  }
}

- (void)drawRect:(CGRect)dirtyRect {
  [super drawRect:dirtyRect];
  if (self.quote) {
    CGRect bounds = self.bounds;
    [[XXColor blackColor] set];
    XXRectFill(bounds);
    bounds = CGRectInset(bounds, 4, 4);
    NSAttributedString *as = [self attributedStringForQuote:self.quote rect:bounds fontScale:1000];
    [as drawInRect:bounds];
  }
}

// Note: the fontDescriptor API doesn't work in macOS El Capitan: it returns a generic font, not Platino Bold.
// and the request by name, 'Palatino Bold' doesn't work in iOS.
// tvOS doesn't have Palatino. Use Baskerville.
- (NSAttributedString *)candidateStringForQuote:(Quote *)quote fontScale:(float)fontScale {
  NSString *fontBaseName = @"Palatino";
  XXFont *font = [XXFont fontWithName:fontBaseName size:fontScale * 0.5];
  if (nil == font) {
    fontBaseName = @"Baskerville";
    font = [XXFont fontWithName:fontBaseName size:fontScale * 0.5];
  }
  XXFont *fontBold = [XXFont fontWithName:[fontBaseName stringByAppendingString:@"-Bold"] size:fontScale * 0.55];
  XXFont *fontSmall = [XXFont fontWithName:fontBaseName size:fontScale * 0.3];
  XXFont *fontSmallItalic = [XXFont fontWithName:[fontBaseName stringByAppendingString:@"-Italic"] size:(fontScale *  0.3)];

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
  NSDictionary *quoteDict = @{NSForegroundColorAttributeName: [XXColor lightGrayColor],
      NSFontAttributeName: font};
  NSDictionary *boldDict = @{NSForegroundColorAttributeName: [XXColor whiteColor],
      NSFontAttributeName: fontBold };
  NSDictionary *workDict = @{NSForegroundColorAttributeName: [XXColor grayColor],
      NSFontAttributeName: fontSmall };
  NSDictionary *authorDict = @{NSForegroundColorAttributeName: [XXColor grayColor],
      NSFontAttributeName: fontSmallItalic};
  NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:prefix attributes:quoteDict];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:bold attributes:boldDict]];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:suffix attributes:quoteDict]];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:work attributes:workDict]];
  [as appendAttributedString:[[NSAttributedString alloc] initWithString:author attributes:authorDict]];
  return as;
}

- (NSAttributedString *)attributedStringForQuote:(Quote *)quote rect:(CGRect)bounds fontScale:(float)fontScaleInitial {
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

@end

