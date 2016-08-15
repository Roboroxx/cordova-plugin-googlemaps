//
//  MyPluginLayerDebugView.m
//  DevApp
//
//  Created by Katsumata Masashi on 9/22/14.
//
//

#import "MyPluginLayerDebugView.h"

@implementation MyPluginLayerDebugView


-  (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    self.drawRects = [[NSMutableDictionary alloc] init];
    self.HTMLNodes = [[NSMutableDictionary alloc] init];
    self.mapCtrls = [[NSMutableDictionary alloc] init];
    self.opaque = NO;
    self.debuggable = YES;

    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (!self.debuggable) {
        return;
    }

    float offsetX = self.webView.scrollView.contentOffset.x;
    float offsetY = self.webView.scrollView.contentOffset.y;
    
    float webviewWidth = self.webView.frame.size.width;
    float webviewHeight = self.webView.frame.size.height;
  
  
  
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, 0, 1.0, 0, 0.4);
    CGFloat zoomScale = self.webView.scrollView.zoomScale;
  
    offsetY *= zoomScale;
    offsetX *= zoomScale;
    webviewWidth *= zoomScale;
    webviewHeight *= zoomScale;
  
    NSEnumerator *mapIDs = [self.drawRects keyEnumerator];
    GoogleMapsViewController *mapCtrl;
    id mapId;
    NSString *rectStr;
    //NSLog(@"--> point = %f, %f", point.x, point.y);
    while(mapId = [mapIDs nextObject]) {
        rectStr = [self.drawRects objectForKey:mapId];
        //NSLog(@"%@ = %@", mapId, rectStr);
        rect = CGRectFromString(rectStr);
        rect.origin.x *= zoomScale;
        rect.origin.y *= zoomScale;
        rect.size.width *= zoomScale;
        rect.size.height *= zoomScale;
        mapCtrl = [self.mapCtrls objectForKey:mapId];
      
        // Is the map is displayed?
        if (rect.origin.y + rect.size.height < offsetY ||
            rect.origin.x + rect.size.width < offsetX ||
            rect.origin.y > offsetY + webviewHeight ||
            rect.origin.x > offsetX + webviewWidth ||
            mapCtrl.view.hidden == YES) {
            continue;
        }
        CGContextFillRect(context, rect);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

@end
