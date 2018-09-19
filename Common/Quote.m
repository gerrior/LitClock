#import "Quote.h"

static BOOL AreEqualOrBothNil(id a, id b) {
  return a == b || [a isEqual:b];
}

@implementation Quote

- (BOOL)isEqual:(id)obj {
  if ([self class] != [obj class]) {
    return NO;
  }
  Quote *other = (Quote *)obj;
  return self.when == other.when &&
    AreEqualOrBothNil(self.key, other.key) &&
    AreEqualOrBothNil(self.quote, other.quote) &&
    AreEqualOrBothNil(self.work, other.work) &&
    AreEqualOrBothNil(self.author, other.author);
}

- (NSUInteger)hash {
  return  self.quote.hash;
}

- (NSString *)description {
  NSMutableArray *a = [NSMutableArray array];
  [a addObject:[NSString stringWithFormat:@"<%@ %p %02d:%02d", [self class], self,
      ((int)self.when/60)/60, ((int)self.when/60)%60]];
  if (self.quote.length) {
    [a addObject:[NSString stringWithFormat:@"\"%@\"", self.quote]];
  }
  if (self.key.length) {
    [a addObject:[NSString stringWithFormat:@"\"%@\"", self.key]];
  }
  if (self.work.length) {
    [a addObject:[NSString stringWithFormat:@"\"%@\"", self.work]];
  }
  if (self.author.length) {
    [a addObject:[NSString stringWithFormat:@"\"%@\"", self.author]];
  }
  return [a componentsJoinedByString:@" "];
}

@end

