//
//  ViewController.m
//  GoodNight-Mac
//
//  Created by Anthony Agatiello on 11/17/16.
//  Copyright © 2016 ADA Tech, LLC. All rights reserved.
//

#import "TemperatureViewController.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation TemperatureViewController

- (void)setGammaWithRed:(float)r green:(float)g blue:(float)b {
    float red[256];
    float green[256];
    float blue[256];
    
    red[0] = 0.0;
    red[1] = r;
    
    green[0] = 0.0;
    green[1] = g;
    
    blue[0] = 0.0;
    blue[1] = b;
    
    CGSetDisplayTransferByTable(CGMainDisplayID(), 2, red, green, blue);
}

- (void)setGammaWithOrangeness:(float)percentOrange {
    if (percentOrange > 1 || percentOrange < 0) {
        return;
    }
    
    float hectoKelvin = percentOrange * 45 + 20;
    float red = 255.0;
    float green = -155.25485562709179 + -0.44596950469579133 * (hectoKelvin - 2) + 104.49216199393888 * log(hectoKelvin - 2);
    float blue = -254.76935184120902 + 0.8274096064007395 * (hectoKelvin - 10) + 115.67994401066147 * log(hectoKelvin - 10);
    
    if (percentOrange == 1) {
        green = 255.0;
        blue = 255.0;
    }
    
    red /= 255.0;
    green /= 255.0;
    blue /= 255.0;
    
    [self setGammaWithRed:red green:green blue:blue];
}

- (IBAction)sliderValueDidChange:(NSSlider *)slider {
    [self.darkroomButton setTitle:@"Enable Darkroom"];
    [self setGammaWithOrangeness:self.temperatureSlider.floatValue];
    
    self.temperatureLabel.stringValue = [NSString stringWithFormat:@"Temperature: %dK", (int)((self.temperatureSlider.floatValue * 45 + 20) * 10) * 10];
    
    if (self.temperatureSlider.floatValue == 1) {
        [self resetTemperature:nil];
    }
}

- (IBAction)toggleDarkroom:(NSButton *)button {
    [self resetTemperature:nil];

    if ([self.darkroomButton.title isEqualToString:@"Enable Darkroom"]) {
        [self setGammaWithRed:1 green:0 blue:0];
        [self.darkroomButton setTitle:@"Disable Darkroom"];
    }
    else {
        [self.darkroomButton setTitle:@"Enable Darkroom"];
    }
}

- (IBAction)resetTemperature:(NSButton *)button {
    self.temperatureSlider.floatValue = 1;
    self.temperatureLabel.stringValue = @"Temperature: 6500K";
    CGDisplayRestoreColorSyncSettings();
}

@end
