//
//  AppDelegate.h
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

+ (void)updateNotifications;
+ (id)initWithIdentifier:(NSString *)identifier;

@property (strong, nonatomic) UIWindow *window;

@end