#import "ObjectTesting.h"
#import <Foundation/Foundation.h>

/* This definition of CGSize/CGPoint matches what is
   done in opal. */
typedef NSSize NearlyCGSize;
typedef NSPoint NearlyCGPoint;

@interface Container : NSObject
{
  NearlyCGSize _sz;
  BOOL _wasObserved;
}
@property (assign) NearlyCGSize sz;
@property (assign) BOOL wasObserved;
@end
@implementation Container
@synthesize sz=_sz;
@synthesize wasObserved=_wasObserved;

- (void) observeValueForKeyPath: (NSString *)keyPath
		       ofObject: (id)object
			 change: (NSDictionary *)change
			context: (void *)context
{
  self->_wasObserved = YES;
}
@end

int main(int argc,char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  volatile BOOL result = NO;

  NSPoint point = {.x = 16.0, .y = 32.0};
  NSValue *pointV = [NSValue valueWithPoint: point];

  // An NSPoint should be represented with exactly the same
  // objCType as its @encode.
  result = !strcmp(@encode(NSPoint), [pointV objCType]);
  PASS(result, "@encode(NSPoint) == [pointV objCType]");

  // An NSPoint should, despite the same layout, not be
  // represented the same as an NSSize.
  result = strcmp(@encode(NSSize), [pointV objCType]);
  PASS(result, "@encode(NSSize) != [pointV objCType]");

  NearlyCGSize sz = {.width = 16.0, .height = 32.0};
  // This test documents the current behavior of the
  // compiler / ABI: a rename of an existing struct should
  // be the same as the original.
  result = !strcmp(@encode(NearlyCGSize), @encode(NSSize));
  PASS(result, "@encode(NearlyCGSize) == @encode(NSSize)");

  // This test validates that a renamed NSSize will be
  // correctly loaded as an NSSize.
  NSValue * sizeV = [NSValue valueWithBytes: &sz
				   objCType: @encode(NearlyCGSize)];
  result = !strcmp(@encode(NearlyCGSize), [sizeV objCType]);
  PASS(result, "@encode(NearlyCGSize) == [sizeV objCType]");

  // When the setter is directly used to change a struct value,
  // value should be observed with KVO and applied.
  Container * c = [Container new];
  result = ![c wasObserved];
  PASS(result, "!_wasObserved");

  [c addObserver: c
      forKeyPath: @"sz"
	 options: NSKeyValueObservingOptionOld
	 context: nil];
  result = ![c wasObserved];
  PASS(result, "!_wasObserved");

  [c setSz: sz];
  result = [c wasObserved];
  PASS(result, "_wasObserved");
  
  result = [c sz].width == sz.width && [c sz].height == sz.height;
  PASS(result, "[c sz] == sz");

  [c release];

  // Rebuild the object and check that using KVC to set a size
  // works, and that it triggers a KVO notification. Ensure that
  // the new value is set and correct.
  c = [Container new];
  [c addObserver: c
      forKeyPath: @"sz"
	 options: NSKeyValueObservingOptionOld
	 context: nil];

  [c setValue: sizeV
       forKey: @"sz"];
  result = [c wasObserved];
  PASS(result, "_wasObserved");
  
  result = [c sz].width == sz.width && [c sz].height == sz.height;
  PASS(result, "[c sz] == sz");


  [pool release];
  return (0);
}
