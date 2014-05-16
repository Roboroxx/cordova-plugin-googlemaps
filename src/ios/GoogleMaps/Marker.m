//
//  Marker.m
//  SimpleMap
//
//  Created by masashi on 11/8/13.
//
//

#import "Marker.h"

@implementation Marker
-(void)setGoogleMapsViewController:(GoogleMapsViewController *)viewCtrl
{
  self.mapCtrl = viewCtrl;
  self.iconCache = [NSMutableDictionary dictionary];
}

/**
 * @param marker options
 * @return marker key
 */
-(void)createMarker:(CDVInvokedUrlCommand *)command
{
  NSDictionary *json = [command.arguments objectAtIndex:1];
  NSDictionary *latLng = [json objectForKey:@"position"];
  float latitude = [[latLng valueForKey:@"lat"] floatValue];
  float longitude = [[latLng valueForKey:@"lng"] floatValue];
  
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
  GMSMarker *marker = [GMSMarker markerWithPosition:position];
  if ([[json valueForKey:@"visible"] boolValue]) {
    marker.map = self.mapCtrl.map;
  }
  if ([json valueForKey:@"title"]) {
    [marker setTitle: [json valueForKey:@"title"]];
  }
  if ([json valueForKey:@"snippet"]) {
    [marker setSnippet: [json valueForKey:@"snippet"]];
  }
  if ([json valueForKey:@"draggable"]) {
    [marker setDraggable:[[json valueForKey:@"draggable"] boolValue]];
  }
  if ([json valueForKey:@"flat"]) {
    [marker setFlat:[[json valueForKey:@"flat"] boolValue]];
  }
  if ([json valueForKey:@"rotation"]) {
    CLLocationDegrees degrees = [[json valueForKey:@"rotation"] doubleValue];
    [marker setRotation:degrees];
  }
  if ([json valueForKey:@"opacity"]) {
    [marker setOpacity:[[json valueForKey:@"opacity"] floatValue]];
  }
  
  NSString *id = [NSString stringWithFormat:@"marker_%d",  marker.hash];
  [self.mapCtrl.overlayManager setObject:marker forKey: id];
  
  // Create icon
  NSObject *iconProperty = [json valueForKey:@"icon"];
  [self setIcon_:marker iconProperty:iconProperty];
  
  NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
  [result setObject:id forKey:@"id"];
  [result setObject:[NSString stringWithFormat:@"%d", marker.hash] forKey:@"hashCode"];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Show the infowindow of the current marker
 * @params MarkerKey
 */
-(void)showInfoWindow:(CDVInvokedUrlCommand *)command
{
  
  NSString *hashCode = [command.arguments objectAtIndex:1];
  
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:hashCode];
  if (marker) {
    self.mapCtrl.map.selectedMarker = marker;
  }
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  
}
/**
 * Hide current infowindow
 * @params MarkerKey
 */
-(void)hideInfoWindow:(CDVInvokedUrlCommand *)command
{
  self.mapCtrl.map.selectedMarker = nil;
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
/**
 * @params MarkerKey
 * @return current marker position with array(latitude, longitude)
 */
-(void)getPosition:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  NSNumber *latitude = @0.0;
  NSNumber *longitude = @0.0;
  if (marker) {
    latitude = [NSNumber numberWithFloat: marker.position.latitude];
    longitude = [NSNumber numberWithFloat: marker.position.longitude];
  }
  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  [json setObject:latitude forKey:@"lat"];
  [json setObject:longitude forKey:@"lng"];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * @params MarkerKey
 * @return boolean
 */
-(void)isInfoWindowShown:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  Boolean isOpen = false;
  if (self.mapCtrl.map.selectedMarker == marker) {
    isOpen = YES;
  }
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isOpen];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set title to the specified marker
 * @params MarkerKey
 */
-(void)setTitle:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  marker.title = [command.arguments objectAtIndex:2];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set title to the specified marker
 * @params MarkerKey
 */
-(void)setSnippet:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  marker.snippet = [command.arguments objectAtIndex:2];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Remove the specified marker
 * @params MarkerKey
 */
-(void)remove:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  marker.map = nil;
  [self.mapCtrl removeObjectForKey:markerKey];
  marker = nil;
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
/**
 * Set anchor
 * @params MarkerKey
 */
-(void)setAnchor:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  float anchorU = [[command.arguments objectAtIndex:2] floatValue];
  float anchorV = [[command.arguments objectAtIndex:3] floatValue];
  [marker setInfoWindowAnchor:CGPointMake(anchorU, anchorV)];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set opacity
 * @params MarkerKey
 */
-(void)setOpacity:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  marker.opacity = [[command.arguments objectAtIndex:2] floatValue];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
/**
 * Set draggable
 * @params MarkerKey
 */
-(void)setDraggable:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  Boolean isEnabled = [[command.arguments objectAtIndex:2] boolValue];
  [marker setDraggable:isEnabled];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set visibility
 * @params MarkerKey
 */
-(void)setVisible:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  Boolean isVisible = [[command.arguments objectAtIndex:2] boolValue];
  
  if (isVisible) {
    marker.map = self.mapCtrl.map;
  } else {
    marker.map = nil;
  }
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set position
 * @params key
 */
-(void)setPosition:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl getMarkerByKey: markerKey];
 
  float latitude = [[command.arguments objectAtIndex:2] floatValue];
  float longitude = [[command.arguments objectAtIndex:3] floatValue];
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude, longitude);
  [marker setPosition:position];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Set flattable
 * @params MarkerKey
 */
-(void)setFlat:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  Boolean isFlat = [[command.arguments objectAtIndex:2] boolValue];
  [marker setFlat: isFlat];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * set icon
 * @params MarkerKey
 */
-(void)setIcon:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  
  // Create icon
  NSObject *iconProperty = [command.arguments objectAtIndex:2];
  [self setIcon_:marker iconProperty:iconProperty];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
/**
 * set rotation
 */
-(void)setRotation:(CDVInvokedUrlCommand *)command
{
  NSString *markerKey = [command.arguments objectAtIndex:1];
  GMSMarker *marker = [self.mapCtrl.overlayManager objectForKey:markerKey];
  
  CLLocationDegrees degrees = [[command.arguments objectAtIndex:2] doubleValue];
  [marker setRotation:degrees];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * @private
 * Load the icon; then set to the marker
 */
-(void)setIcon_:(GMSMarker *)marker iconProperty:(NSObject *)iconProperty {
  NSString *iconPath = nil;
  NSDictionary *iconJSON = nil;
  CGFloat width = 0;
  CGFloat height = 0;
  CGFloat anchorX = 0;
  CGFloat anchorY = 0;
  if ([iconProperty isKindOfClass:[NSString class]]) {
    iconPath = (NSString *)iconProperty;
  } else {
  
    iconJSON = (NSDictionary *)iconProperty;
    if (iconJSON) {
      // The url property
      iconPath = [iconJSON valueForKey:@"url"];
      
      // The size property
      if ([iconJSON valueForKey:@"size"]) {
        NSDictionary *size = [iconJSON valueForKey:@"size"];
        width = [[size objectForKey:@"width"] floatValue];
        height = [[size objectForKey:@"height"] floatValue];
      }
      
    }
  }

  if (iconPath) {
    NSRange range = [iconPath rangeOfString:@"http"];
    if (range.location == NSNotFound) {
      Boolean isTextMode = true;
          
      UIImage *image;
      if ([iconPath rangeOfString:@"data:image/"].location != NSNotFound &&
          [iconPath rangeOfString:@";base64,"].location != NSNotFound) {
        
        /**
         * Base64 icon
         */
        isTextMode = false;
        NSArray *tmp = [iconPath componentsSeparatedByString:@","];
        
        NSData *decodedData;
        if ([PluginUtil isIOS7]) {
          decodedData = [[NSData alloc] initWithBase64EncodedString:tmp[1] options:0];
        } else {
          decodedData = [NSData dataFromBase64String:tmp[1]];
        }
        image = [[UIImage alloc] initWithData:decodedData];
        
      } else {
        /**
         * Load the icon from local path
         */
        image = [UIImage imageNamed:iconPath];
        
        if (width && height) {
          image = [image resize:width height:height];
        }
      }
      
      marker.icon = image;
      
      // The anchor property
      if (iconJSON) {
        if ([iconJSON valueForKey:@"anchor"]) {
          NSArray *points = [iconJSON valueForKey:@"anchor"];
          anchorX = [[points objectAtIndex:0] floatValue] / image.size.width;
          anchorY = [[points objectAtIndex:1] floatValue] / image.size.height;
          marker.groundAnchor = CGPointMake(anchorX, anchorY);
        }
      }
    } else {
      /***
       * Load the icon from over the internet
       */
      NSData *imgData = [self.iconCache objectForKey:iconPath];
      if (imgData != nil) {
        UIImage* image = [UIImage imageWithData:imgData];
        if (width && height) {
          image = [image resize:width height:height];
        }
        marker.icon = image;
      } else {
        dispatch_queue_t gueue = dispatch_queue_create("GoogleMap_addMarker", NULL);
        dispatch_sync(gueue, ^{
          NSURL *url = [NSURL URLWithString:iconPath];
          NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:nil];
          
          [self.iconCache setObject:data forKey:iconPath];
          
          UIImage* image = [UIImage imageWithData:data];
          if (width && height) {
            image = [image resize:width height:height];
          }
          marker.icon = image;
          
          
          // The anchor property
          if (iconJSON) {
            if ([iconJSON valueForKey:@"anchor"]) {
              NSArray *points = [iconJSON valueForKey:@"anchor"];
              CGFloat anchorX = [[points objectAtIndex:0] floatValue] / image.size.width;
              CGFloat anchorY = [[points objectAtIndex:1] floatValue] / image.size.height;
              marker.groundAnchor = CGPointMake(anchorX, anchorY);
            }
          }
        });
        
      }
    }
  }
  
}
@end
