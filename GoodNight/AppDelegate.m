//
//  AppDelegate.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary *defaultsToRegister = @{@"enabled": @NO,
                                         @"maxOrange": @0.4,
                                         @"colorChangingEnabled": @YES,
                                         @"redValue": @1.0,
                                         @"greenValue": @1.0,
                                         @"blueValue": @1.0,
                                         @"dimEnabled": @NO,
                                         @"dimLevel": @1.0,
                                         @"rgbEnabled": @NO,
                                         @"lastAutoChangeDate": [NSDate distantPast],
                                         @"autoStartHour": @19,
                                         @"autoStartMinute": @0,
                                         @"autoEndHour": @7,
                                         @"autoEndMinute": @0,
                                         @"suspendEnabled": @YES,
                                         @"forceTouchEnabled": @YES,
                                         @"tempForceTouch": @YES,
                                         @"dimForceTouch": @NO,
                                         @"rgbForceTouch": @NO,
                                         @"keyEnabled": @"0"};
    
    [userDefaults registerDefaults:defaultsToRegister];
    [GammaController autoChangeOrangenessIfNeeded];
    [application setMinimumBackgroundFetchInterval:900];
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    BOOL handledShortcutItem = [ForceTouchController handleShortcutItem:shortcutItem];
    [ForceTouchController exitIfKeyEnabled];
    completionHandler(handledShortcutItem);
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [GammaController autoChangeOrangenessIfNeeded];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
