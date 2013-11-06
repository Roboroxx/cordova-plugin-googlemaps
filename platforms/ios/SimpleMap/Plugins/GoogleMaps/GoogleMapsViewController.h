//
//  GoogleMapsViewController.h
//  SimpleMap
//
//  Created by masashi on 11/6/13.
//
//

#import <GoogleMaps/GoogleMaps.h>
#import <UIKit/UIKit.h>

@interface GoogleMapsViewController : UIViewController<GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView* map;
@property (nonatomic, strong) UIWebView* webView;

@end
