//
//  ViewController.m
//  GoodNight
//
//  Created by Anthony Agatiello on 6/22/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (instancetype)init
{
    self = [AppDelegate initWithIdentifier:@"mainViewController"];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.timeFormatter = [[NSDateFormatter alloc] init];
        self.timeFormatter.timeStyle = NSDateFormatterShortStyle;
        self.timeFormatter.dateStyle = NSDateFormatterNoStyle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timePicker = [[UIDatePicker alloc] init];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.minuteInterval = 15;
    self.timePicker.backgroundColor = [UIColor whiteColor];
    [self.timePicker addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.endTimeTextField.inputView = self.timePicker;
    self.startTimeTextField.inputView = self.timePicker;
    
    self.timePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolbarDoneButtonClicked:)];
    [self.timePickerToolbar setItems:@[doneButton]];
    
    self.endTimeTextField.inputAccessoryView = self.timePickerToolbar;
    self.startTimeTextField.inputAccessoryView = self.timePickerToolbar;
    
    self.endTimeTextField.delegate = self;
    self.startTimeTextField.delegate = self;

    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)updateUI {
    self.enabledSwitch.on = [userDefaults boolForKey:@"enabled"];
    self.orangeSlider.value = [userDefaults floatForKey:@"maxOrange"];
    self.colorChangingEnabledSwitch.on = [userDefaults boolForKey:@"colorChangingEnabled"];
    
    float orange = 1.0f - self.orangeSlider.value;
    
    self.orangeSlider.tintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    
    self.enabledSwitch.onTintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    self.colorChangingEnabledSwitch.onTintColor = [UIColor colorWithRed:0.9f green:((2.0f-orange)/2.0f)*0.9f blue:(1.0f-orange)*0.9f alpha:1.0];
    
    NSDate *date = [self dateForHour:[userDefaults integerForKey:@"autoStartHour"] andMinute:[userDefaults integerForKey:@"autoStartMinute"]];
    self.startTimeTextField.text = [self.timeFormatter stringFromDate:date];
    date = [self dateForHour:[userDefaults integerForKey:@"autoEndHour"] andMinute:[userDefaults integerForKey:@"autoEndMinute"]];
    self.endTimeTextField.text = [self.timeFormatter stringFromDate:date];}

- (IBAction)enabledSwitchChanged {
    [userDefaults setBool:self.enabledSwitch.on forKey:@"enabled"];
        
    if (self.enabledSwitch.on) {
        [GammaController enableOrangenessWithDefaults:NO transition:YES];
    }
    else {
        [GammaController disableOrangeness];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            [self.startTimeTextField becomeFirstResponder];
        }
        if (indexPath.row == 2) {
            [self.endTimeTextField becomeFirstResponder];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)button {
    [self.startTimeTextField resignFirstResponder];
    [self.endTimeTextField resignFirstResponder];
    
    [AppDelegate updateNotifications];
}

- (void)timePickerValueChanged:(UIDatePicker *)picker {
    UITextField *currentField = nil;
    NSString *defaultsKeyPrefix = nil;
    if ([self.startTimeTextField isFirstResponder]) {
        currentField = self.startTimeTextField;
        defaultsKeyPrefix = @"autoStart";
    }
    else if ([self.endTimeTextField isFirstResponder]) {
        currentField = self.endTimeTextField;
        defaultsKeyPrefix = @"autoEnd";
    }
    else {
        return;
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:picker.date];
    currentField.text = [self.timeFormatter stringFromDate:picker.date];
    
    [userDefaults setInteger:components.hour forKey:[defaultsKeyPrefix stringByAppendingString:@"Hour"]];
    [userDefaults setInteger:components.minute forKey:[defaultsKeyPrefix stringByAppendingString:@"Minute"]];
    
    [userDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    [GammaController autoChangeOrangenessIfNeededWithTransition:NO];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSDate *date = nil;
    
    if (textField == self.startTimeTextField) {
        date = [self dateForHour:[userDefaults integerForKey:@"autoStartHour"] andMinute:[userDefaults integerForKey:@"autoStartMinute"]];
    }
    else if (textField == self.endTimeTextField) {
        date = [self dateForHour:[userDefaults integerForKey:@"autoEndHour"] andMinute:[userDefaults integerForKey:@"autoEndMinute"]];
    }
    else {
        return;
    }
    [(UIDatePicker *)textField.inputView setDate:date animated:NO];
}

- (NSDate *)dateForHour:(NSInteger)hour andMinute:(NSInteger)minute{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.hour = hour;
    comps.minute = minute;
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (void)userDefaultsChanged:(NSNotification *)notification {
    [self updateUI];
}

- (IBAction)maxOrangeSliderChanged {
    [userDefaults setFloat:self.orangeSlider.value forKey:@"maxOrange"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController enableOrangenessWithDefaults:NO transition:NO];
    }
}

- (IBAction)colorChangingEnabledSwitchChanged {
    self.enabledSwitch.enabled = !self.colorChangingEnabledSwitch.on;
    [userDefaults setBool:self.colorChangingEnabledSwitch.on forKey:@"colorChangingEnabled"];
    [userDefaults setObject:[NSDate distantPast] forKey:@"lastAutoChangeDate"];
    [GammaController autoChangeOrangenessIfNeededWithTransition:YES];
    
    [AppDelegate updateNotifications];
}

- (IBAction)resetSlider {
    self.orangeSlider.value = 0.4;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.enabledSwitch.on) {
        [GammaController setGammaWithTransitionFrom:[userDefaults floatForKey:@"maxOrange"] to:self.orangeSlider.value];
    }
    
    [userDefaults setFloat:self.orangeSlider.value forKey:@"maxOrange"];
}

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    NSString *title = nil;
    
    if (![userDefaults boolForKey:@"enabled"]) {
        title = @"Enable";
    }
    else if ([userDefaults boolForKey:@"enabled"]) {
        title = @"Disable";
    }
    
    UIPreviewAction *enableDisableAction = [UIPreviewAction actionWithTitle:title style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self enableOrDisableBasedOnDefaults];
    }];
    UIPreviewAction *cancelButton = [UIPreviewAction actionWithTitle:@"Cancel" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {}];
    
    return @[enableDisableAction, cancelButton];
}

- (void)enableOrDisableBasedOnDefaults {
    if (![userDefaults boolForKey:@"enabled"]) {
        [GammaController enableOrangenessWithDefaults:YES transition:YES];
    }
    else if ([userDefaults boolForKey:@"enabled"]) {
        [GammaController disableOrangeness];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = @"";
    if (tableView) {
        if (section == 1) {
            headerText = [NSString stringWithFormat:@"Temperature (%dK)", ((int)(self.orangeSlider.value * 45 + 20) * 100)];
        }
        if (section == 2) {
            headerText = @"Automatic Mode";
        }
    }
    return headerText;
}

@end