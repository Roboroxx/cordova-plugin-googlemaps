//
//  DummyView.m
//  DevApp
//
//  Created by masashi on 8/13/14.
//
//

#import "MyPluginLayer.h"

@implementation MyPluginLayer

UIView *gmsVector = nil;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  float left = [[self.embedRect objectForKey:@"left"] floatValue] - self.webView.scrollView.contentOffset.x;
  float top = [[self.embedRect objectForKey:@"top"] floatValue] - self.webView.scrollView.contentOffset.y;
  float width = [[self.embedRect objectForKey:@"width"] floatValue];
  float height = [[self.embedRect objectForKey:@"height"] floatValue];
  
  BOOL isMapAction = NO;
  if (point.x >= left && point.x <= (left + width) &&
      point.y >= top && point.y <= (top + height)) {
    isMapAction = YES;
  } else {
    isMapAction = NO;
  }
  
  if (isMapAction == YES) {
    if (gmsVector == nil) {
      for (UIView *view in self.map.subviews) {
        if ([[NSString stringWithFormat:@"%@", view.class] isEqualToString:@"GMSVectorMapView"]) {
          gmsVector = view;
          break;
        }
      }
    
    }
    return gmsVector;
  }
  
  return self.webView;
}

@end
