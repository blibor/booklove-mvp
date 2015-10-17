//
//  DonateViewController.m
//  Wisdom
//
//  Created by Sztanyi Szabolcs on 07/10/15.
//  Copyright © 2015 Zappdesigntemplates. All rights reserved.
//

#import "DonateViewController.h"

@implementation DonateViewController

- (IBAction)donateButtonPressed
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://smile.amazon.com/about"]];

    [TRACKER trackDonateButtonPressed];
}

- (IBAction)closeButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [TRACKER trackDonateViewClosed];
}

#pragma mark - view methods
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
