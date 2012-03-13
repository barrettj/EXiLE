//
//  BJAppDelegate.m
//  EXiLE-Demo
//
//  Created by Barrett Jacobsen on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BJAppDelegate.h"

#import "BJViewController.h"

#import "EXiLE.h"

@implementation BJAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // setup a block so you can be notified when a localization is missing
    EXILE.onUnlocalizedString = ^(NSString *unlocalizedString, NSString *localizationKey) {
        //NSLog(@"Unlocalized '%@' - %@", unlocalizedString, localizationKey);
        NSLog(@"\"%@\" = \"%@\";", localizationKey, unlocalizedString);
    };
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[BJViewController alloc] initWithNibName:@"BJViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
