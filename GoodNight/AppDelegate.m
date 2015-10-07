//
//  AppDelegate.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "GammaController.h"
#include <dlfcn.h>

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
                                         @"lastOnDate": [NSDate distantPast],
                                         @"lastOffDate": [NSDate distantPast]};
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:900];
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if ([shortcutItem.type isEqualToString:[NSString stringWithFormat:@"%@.enable", bundleIdentifier]]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"rgbEnabled"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"dimEnabled"]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enabled"];
            [GammaController setGammaWithOrangeness:[[NSUserDefaults standardUserDefaults] floatForKey:@"maxOrange"]];
            [application performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:0.5];
            exit(0);
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enabled"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You may only use one adjustment at a time. Please disable any other adjustments before enabling this one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if ([shortcutItem.type isEqualToString:[NSString stringWithFormat:@"%@.disable", bundleIdentifier]]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enabled"];
        [GammaController setGammaWithOrangeness:0];
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"App woke with fetch request");
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"colorChangingEnabled"]) {
        completionHandler(UIBackgroundFetchResultNewData);
        return;
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
    
    const NSInteger turnOnHour = 19;
    const NSInteger turnOffHour = 7;
    const NSInteger minCheckTimeHours = 12;
    const NSTimeInterval minCheckTime = minCheckTimeHours * 60 * 60;
    
    NSLog(@"Current hour: %ld", (long)components.hour);
    
    if (components.hour >= turnOnHour || components.hour < turnOffHour) {
        if ([[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastOnDate"]] >= minCheckTime) {
            NSLog(@"Setting color orange");
            [self wakeUpScreenIfNeeded];
            [GammaController setGammaWithOrangeness:[[NSUserDefaults standardUserDefaults] floatForKey:@"maxOrange"]];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastOnDate"];
        }
    }
    else {
        if ([[NSDate date] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastOnDate"]] >= minCheckTime) {
            NSLog(@"Setting color normal");
            [self wakeUpScreenIfNeeded];
            [GammaController setGammaWithOrangeness:0];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastOffDate"];
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)wakeUpScreenIfNeeded {
    void *SpringBoardServices = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
    NSParameterAssert(SpringBoardServices);
    mach_port_t (*SBSSpringBoardServerPort)() = dlsym(SpringBoardServices, "SBSSpringBoardServerPort");
    NSParameterAssert(SBSSpringBoardServerPort);
    mach_port_t sbsMachPort = SBSSpringBoardServerPort();
    BOOL isLocked, passcodeEnabled;
    void *(*SBGetScreenLockStatus)(mach_port_t port, BOOL *isLocked, BOOL *passcodeEnabled) = dlsym(SpringBoardServices, "SBGetScreenLockStatus");
    NSParameterAssert(SBGetScreenLockStatus);
    SBGetScreenLockStatus(sbsMachPort, &isLocked, &passcodeEnabled);
    NSLog(@"Lock status: %d", isLocked);
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    
    if (isLocked) {
        [[UIApplication sharedApplication] performSelector:@selector(requestDeviceUnlock)];
    }
    
    #pragma clang diagnostic pop
    
    dlclose(SpringBoardServices);
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
