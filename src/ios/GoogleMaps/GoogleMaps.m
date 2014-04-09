//
//  GoogleMaps.m
//  SimpleMap
//
//  Created by masashi on 10/31/13.
//
//

#import "GoogleMaps.h"

@implementation GoogleMaps

- (void)pluginInitialize
{
  self.licenseLayer = nil;
}

/**
 * Intialize the map
 */
- (void)getMap:(CDVInvokedUrlCommand *)command {
  
  if (!self.mapCtrl) {
    dispatch_queue_t gueue = dispatch_queue_create("plugins.google.maps.init", NULL);
    
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGRect pluginRect;
    int marginBottom = 0;
    if ([PluginUtil isIOS7] == false) {
      marginBottom = 20;
    }
    int direction = self.viewController.interfaceOrientation;
    if (direction == UIInterfaceOrientationLandscapeLeft ||
        direction == UIInterfaceOrientationLandscapeRight) {
      pluginRect = CGRectMake(10, 10, screenSize.size.height - 20, screenSize.size.width - 50 - marginBottom);
    } else {
      pluginRect = CGRectMake(10, 10, screenSize.size.width - 20, screenSize.size.height - 50 - marginBottom);
    }


    
    
    // Create a map view
    dispatch_async(gueue, ^{
      NSDictionary *options = [command.arguments objectAtIndex:0];
      self.mapCtrl = [[GoogleMapsViewController alloc] initWithOptions:options];
      self.mapCtrl.webView = self.webView;
    });
    
    // Create an instance of Map Class
    dispatch_async(gueue, ^{
      Map *mapClass = [[NSClassFromString(@"Map")alloc] initWithWebView:self.webView];
      mapClass.commandDelegate = self.commandDelegate;
      [mapClass setGoogleMapsViewController:self.mapCtrl];
      [self.mapCtrl.plugins setObject:mapClass forKey:@"Map"];
    });
    
    
    
    // Create the footer background
    dispatch_async(gueue, ^{
      dispatch_sync(dispatch_get_main_queue(), ^{
        UIView *footer = [[UIView alloc]init];
        footer.frame = CGRectMake(10, pluginRect.size.height + 10, pluginRect.size.width, 30);
        footer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        footer.backgroundColor = [UIColor lightGrayColor];
        [self.mapCtrl.view addSubview:footer];
      });
    });

    // Create the close button
    dispatch_async(gueue, ^{
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        closeButton.frame = CGRectMake(10, pluginRect.size.height + 10, 50, 30);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onCloseBtn_clicked:) forControlEvents:UIControlEventTouchDown];
      
        [self.mapCtrl.view addSubview:closeButton];
      });

    });
    
    
    // Create the legal notices button
    dispatch_async(gueue, ^{
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        UIButton *licenseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        licenseButton.frame = CGRectMake(pluginRect.size.width - 90, pluginRect.size.height + 10, 100, 30);
        licenseButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [licenseButton setTitle:@"Legal Notices" forState:UIControlStateNormal];
        [licenseButton addTarget:self action:@selector(onLicenseBtn_clicked:) forControlEvents:UIControlEventTouchDown];
        [self.mapCtrl.view addSubview:licenseButton];
      });
    });
  }
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



- (void)exec:(CDVInvokedUrlCommand *)command {
  
  [self.commandDelegate runInBackground:^{
    
    CDVPluginResult* pluginResult = nil;
    NSString *classAndMethod = [command.arguments objectAtIndex:0];
    
    NSArray *target = [classAndMethod componentsSeparatedByString:@"."];
    NSString *className = [target objectAtIndex:0];
    CDVPlugin<MyPlgunProtocol> *pluginClass = nil;
    NSString *methodName;
    
    if ([target count] == 2) {
      methodName = [NSString stringWithFormat:@"%@:", [target objectAtIndex:1]];
      
      pluginClass = [self.mapCtrl.plugins objectForKey:className];
      if (!pluginClass) {
        pluginClass = [[NSClassFromString(className)alloc] initWithWebView:self.webView];
        if (pluginClass) {
          pluginClass.commandDelegate = self.commandDelegate;
          [pluginClass setGoogleMapsViewController:self.mapCtrl];
          [self.mapCtrl.plugins setObject:pluginClass forKey:className];
        }
      }
      if (!pluginClass) {
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:[NSString stringWithFormat:@"Class not found: %@", className]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
        
      } else {
        SEL selector = NSSelectorFromString(methodName);
        if ([pluginClass respondsToSelector:selector]){
          [pluginClass performSelectorOnMainThread:selector withObject:command waitUntilDone:YES];
        } else {
          pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:[NSString stringWithFormat:@"method not found: %@ in %@ class", [target objectAtIndex:1], className]];
          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
      }
    } else {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:[NSString stringWithFormat:@"class not found: %@", className]];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  }];
}

/**
 * Get license information
 */
-(void)getLicenseInfo:(CDVInvokedUrlCommand *)command
{
  NSString *txt = [GMSServices openSourceLicenseInfo];
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:txt];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Close the map window
 */
- (void)onCloseBtn_clicked:(UIButton*)button{
  [self.mapCtrl.view removeFromSuperview];
}

/**
 * Show the licenses
 */
- (void)onLicenseBtn_clicked:(UIButton*)button{

  if (self.licenseLayer == nil) {
    //Create the dialog
    CGRect dialogRect = self.mapCtrl.view.frame;
    dialogRect.origin.x = dialogRect.size.width / 10;
    dialogRect.origin.y = dialogRect.origin.x;
    dialogRect.size.width -= dialogRect.origin.x * 2;
    dialogRect.size.height -= dialogRect.origin.y * 2;
    if ([PluginUtil isIOS7] == false) {
      dialogRect.size.height -= 20;
    }
    
    self.licenseLayer = [[UIView alloc] initWithFrame:self.mapCtrl.view.frame];
    self.licenseLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.licenseLayer setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.25f]];
    
    UIView *licenseDialog = [[UIView alloc] initWithFrame:dialogRect];
    [licenseDialog setBackgroundColor:[UIColor whiteColor]];
    [licenseDialog.layer setBorderColor:[UIColor blackColor].CGColor];
    [licenseDialog.layer setBorderWidth:1.0];
    [licenseDialog.layer setCornerRadius:10];
    licenseDialog.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
    [self.licenseLayer addSubview:licenseDialog];

    CGRect scrollViewRect = CGRectMake(5, 5, dialogRect.size.width - 10, dialogRect.size.height - 30);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: scrollViewRect];
    [scrollView.layer setBorderColor:[UIColor blackColor].CGColor];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [licenseDialog addSubview:scrollView];
    
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[scrollView bounds]];
    [webView setBackgroundColor:[UIColor whiteColor]];
    webView.scalesPageToFit = NO;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    int fontSize = 13;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
      fontSize = 18;
    }
    NSMutableString *licenceTxt = [NSMutableString
                                      stringWithFormat:@"<html><body style='font-size:%dpx;white-space:pre-line'>%@</body></html>",
                                      fontSize,
                                      [GMSServices openSourceLicenseInfo]];
    
    [webView loadHTMLString:licenceTxt baseURL:nil];
    scrollView.contentSize = [webView bounds].size;
    [scrollView addSubview:webView];
    
    //close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeButton.frame = CGRectMake(0, dialogRect.size.height - 30, dialogRect.size.width, 30);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewContentModeTopLeft;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(onLicenseCloseBtn_clicked:) forControlEvents:UIControlEventTouchDown];
    [licenseDialog addSubview:closeButton];
  }
  
  [self.mapCtrl.view addSubview:self.licenseLayer];
}

/**
 * Close the map window
 */
- (void)onLicenseCloseBtn_clicked:(UIButton*)button{
  [self.licenseLayer removeFromSuperview];
}

/**
 * Show the map window
 */
- (void)showDialog:(CDVInvokedUrlCommand *)command {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self.webView addSubview:self.mapCtrl.view];
    
    
      CGRect screenSize = [[UIScreen mainScreen] bounds];
      CGRect pluginRect;
      
      int direction = self.mapCtrl.interfaceOrientation;
      if (direction == UIInterfaceOrientationLandscapeLeft ||
          direction == UIInterfaceOrientationLandscapeRight) {
        pluginRect = CGRectMake(0, 0, screenSize.size.height, screenSize.size.width);
      } else {
        pluginRect = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
      }
      [self.mapCtrl.view setFrame:pluginRect];
    });
  });
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Show the map window
 */
- (void)closeDialog:(CDVInvokedUrlCommand *)command {
  [self.mapCtrl.view removeFromSuperview];
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Return the current position based on GPS
 */
-(void)getMyLocation:(CDVInvokedUrlCommand *)command
{
  
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  locationManager.distanceFilter = kCLDistanceFilterNone;
  
  NSMutableDictionary *latLng = [NSMutableDictionary dictionary];
  [latLng setObject:[NSNumber numberWithFloat:locationManager.location.coordinate.latitude] forKey:@"lat"];
  [latLng setObject:[NSNumber numberWithFloat:locationManager.location.coordinate.longitude] forKey:@"lng"];

  NSMutableDictionary *json = [NSMutableDictionary dictionary];
  [json setObject:latLng forKey:@"latLng"];
  [json setObject:[NSNumber numberWithFloat:[locationManager.location speed]] forKey:@"speed"];
  [json setObject:[NSNumber numberWithFloat:[locationManager.location altitude]] forKey:@"altitude"];
  
  //todo: calcurate the correct accuracy based on horizontalAccuracy and verticalAccuracy
  [json setObject:[NSNumber numberWithFloat:[locationManager.location horizontalAccuracy]] forKey:@"accuracy"];
  [json setObject:[NSNumber numberWithDouble:[locationManager.location.timestamp timeIntervalSince1970]] forKey:@"time"];
  [json setObject:[NSNumber numberWithInteger:[locationManager.location hash]] forKey:@"hashCode"];

  locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  [locationManager startUpdatingLocation];
    
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
