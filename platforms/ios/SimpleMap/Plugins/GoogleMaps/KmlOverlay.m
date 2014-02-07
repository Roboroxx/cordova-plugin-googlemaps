//
//  GroundOverlay.m
//  SimpleMap
//
//  Created by Katsumata Masashi on 12/4/13.
//
//

#import "KmlOverlay.h"


@implementation KmlOverlay

-(void)setGoogleMapsViewController:(GoogleMapsViewController *)viewCtrl
{
  self.mapCtrl = viewCtrl;
}

-(void)createKmlOverlay:(CDVInvokedUrlCommand *)command
{

/*
  NSDictionary* dummyDict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"val", @"key", nil];
  NSDictionary* dummyDict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"val", @"key", nil];
  NSArray* args = [NSArray arrayWithObjects:@"a", dummyDict1, dummyDict2, @"b", nil];
  NSArray* jsonArr = [NSArray arrayWithObjects:@"callbackId", @"className", @"methodName", args, nil];
  CDVInvokedUrlCommand* command2 = [CDVInvokedUrlCommand commandFromJson:jsonArr];
  
  NSLog(@"createKmlOverlay");
  
  NSString *className = @"Polyline";
  CDVPlugin<MyPlgunProtocol> *pluginClass = [self.mapCtrl.plugins objectForKey:className];
  if (!pluginClass) {
    pluginClass = [[NSClassFromString(className)alloc] initWithWebView:self.webView];
    if (pluginClass) {
      pluginClass.commandDelegate = self.commandDelegate;
      [pluginClass setGoogleMapsViewController:self.mapCtrl];
      [self.mapCtrl.plugins setObject:pluginClass forKey:className];
    }
  }
  SEL selector = NSSelectorFromString(@"createPolyline:");
  NSLog(@"class=%hhd", [pluginClass respondsToSelector:selector]);
  if ([pluginClass respondsToSelector:selector]){
    [pluginClass performSelectorOnMainThread:selector withObject:command2 waitUntilDone:YES];
  }
  NSLog(@"done");
return;
*/
  NSDictionary *json = [command.arguments objectAtIndex:1];
  
  NSString *urlStr = [json objectForKey:@"url"];
  
  //--------------------------------
  // Parse the kml file
  //--------------------------------
  NSError *error = nil;
  TBXML *tbxml = [[TBXML alloc] initWithXMLFile:urlStr error:&error];
  CDVPluginResult* pluginResult;
  if (error) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
  }
  NSMutableDictionary *kmlData = [self parseXML:tbxml.rootXMLElement];
  
  //--------------------------------
  // Separate styles and placemarks
  //--------------------------------
  NSMutableDictionary *kmlTag = kmlData[@"children"][0];
  NSMutableDictionary *documentTag = kmlTag[@"children"];
  
  NSMutableDictionary *styles = [NSMutableDictionary dictionary];
  NSMutableArray *placeMarks = [NSMutableArray array];
  NSDictionary *tag;
  NSString *tagName;
  NSString *styleId;
  
  for (tag in documentTag) {
    tagName = tag[@"_tag"];
    if ([tagName isEqualToString:@"style"]) {
      styleId = tag[@"_id"];
      if (styleId != nil) {
        styles[styleId] = tag[@"children"];
      }
    }

    if ([tagName isEqualToString:@"placemark"]) {
      [placeMarks addObject:tag];
    }
  }
  NSLog(@"---implement start");
  for (tag in placeMarks) {
    [self implementPlaceMarkToMap:tag styles:styles];
  }
  NSLog(@"%@", styles);
  
  //CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: key];
  
}

-(void)implementPlaceMarkToMap:(NSDictionary *)placeMarker styles:(NSMutableDictionary *)styles {
  NSArray *children = [placeMarker objectForKey:@"children"];
  
  NSDictionary *childNode, *node;
  NSMutableDictionary *options = [NSMutableDictionary dictionary];
  NSString *tagName, *tagName2;
  NSArray *tmpArray;
  NSString *objectName = nil;
  
  [options setObject:[NSNumber numberWithBool:true] forKey:@"visible"];
  
  for (childNode in children) {
    tagName = [childNode objectForKey:@"_tag"];
    
    if ([tagName isEqualToString:@"linestring"]) {
      objectName = @"Polyline";
      [options setObject:[NSNumber numberWithBool:true] forKey:@"geodesic"];
      tmpArray = [childNode objectForKey:@"children"];
      for (node in tmpArray) {
        tagName2 = [node objectForKey:@"_tag"];
        if ([tagName2 isEqualToString:@"coordinates"]) {
          [options setObject:[self _coordinateToLatLngArray:node] forKey:@"points"];
          break;
        }
      }
    }
  }
  //NSLog(@"%@", options);
  
}

-(NSMutableArray *)_coordinateToLatLngArray:(NSDictionary *)coordinateTag {
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9\\-\\.\\,]+" options:NSRegularExpressionCaseInsensitive error:nil];
  NSMutableArray *coordinates = [NSMutableArray array];
  NSString *coordinateStr = [coordinateTag objectForKey:@"coordinates"];
  coordinateStr = [regex stringByReplacingMatchesInString:coordinateStr options:0 range:NSMakeRange(0, [coordinateStr length]) withTemplate:@"@"];
  NSArray *lngLatArray = [coordinateStr componentsSeparatedByString:@"@"];
  NSString *lngLat;
  NSArray *lngLatAlt;
  for (lngLat in lngLatArray) {
    lngLatAlt = [lngLat componentsSeparatedByString:@","];
    NSMutableDictionary *latLng = [NSMutableDictionary dictionary];
    [latLng setObject:lngLatAlt[0] forKey:@"lng"];
    [latLng setObject:lngLatAlt[1] forKey:@"lat"];
    [coordinates addObject:latLng];
  }
  return coordinates;
}

/**
 * Remove the kml overlay
 * @params key
 */
-(void)remove:(CDVInvokedUrlCommand *)command
{
  NSString *key = [command.arguments objectAtIndex:1];
  GMSGroundOverlay *layer = [self.mapCtrl getGroundOverlayByKey:key];
  layer.map = nil;
  [self.mapCtrl removeObjectForKey:key];
  layer = nil;
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(NSMutableDictionary *)parseXML:(TBXMLElement *)rootElement
{

  TBXMLElement *childNode = rootElement->firstChild;
  NSString *tagName = [[TBXML elementName:rootElement] lowercaseString];
  NSMutableDictionary *result = [NSMutableDictionary dictionary];
  NSMutableArray *children = [NSMutableArray array];
  result[@"_tag"] = tagName;
  NSString *attrName;
  
  if (childNode) {
    while(childNode) {
      NSMutableDictionary *tmp = [self parseXML:childNode];
      TBXMLAttribute *attribute = childNode->firstAttribute;
      while (attribute) {
        attrName = [NSString stringWithFormat:@"_%@", [[TBXML attributeName:attribute] lowercaseString]];
        tmp[attrName] = [TBXML attributeValue:attribute];
        attribute = attribute->next;
      }
      
      [children addObject: tmp];
      childNode = childNode->nextSibling;
    }
  } else if ([TBXML textForElement:rootElement] != nil) {
      result[tagName] = [TBXML textForElement:rootElement];
  }
  if ([children count] > 0) {
    result[@"children"] = children;
  }
  return result;
}

@end
