#import <ConditionalMacros.h>

// Define a cross-platform view class, usable on tvOS, iOS, and macOS.
#if TARGET_OS_IPHONE
  #import <UIKit/UIKit.h>
  typedef UIView XXView;
#else
  #import <Cocoa/Cocoa.h>
  typedef NSView XXView;
#endif

