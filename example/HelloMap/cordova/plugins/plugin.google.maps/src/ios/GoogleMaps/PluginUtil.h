//
//  PluginUtil.h
//  SimpleMap
//
//  Created by masashi on 11/15/13.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

@interface NSArray (GoogleMapsPlugin)
- (UIColor*)parsePluginColor;
@end


@interface UIImage (GoogleMapsPlugin)
- (UIImage*)imageByApplyingAlpha:(CGFloat) alpha;
- (UIImage *)resize:(CGFloat)width height:(CGFloat)height;
@end



@interface PluginUtil : NSObject
+ (BOOL)isIOS7;
@end