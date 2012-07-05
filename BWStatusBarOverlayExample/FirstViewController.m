//
//  FirstViewController.m
//  BWStatusBarOverlayExample
//
//  Created by Bruno Wernimont on 3/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"

#import "BWStatusBarOverlay.h"
#include <stdlib.h>

@interface FirstViewController ()

@end

@implementation FirstViewController


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)randomMessage {
    int r = rand() % 74;
    return @"Download files 1 of 2";
    return [NSString stringWithFormat:@"Random number %d", r];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [BWStatusBarOverlay setActionBlock:^{
        NSLog(@"you pressed me");
    }];    
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressChangeStatusBarStyle:(id)sender {
    UIStatusBarStyle statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    if (UIStatusBarStyleDefault == statusBarStyle) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        [BWStatusBarOverlay setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [BWStatusBarOverlay setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressChangeProgression:(id)sender {
    [BWStatusBarOverlay setProgress:0.7 animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressShowSimple:(id)sender {
    [BWStatusBarOverlay showWithMessage:[self randomMessage] loading:YES animated:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressShowWithFade:(id)sender {
    [BWStatusBarOverlay setAnimation:BWStatusBarOverlayAnimationTypeFade];
    [BWStatusBarOverlay showWithMessage:[self randomMessage] loading:YES animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressShowWithFromTop:(id)sender {
    [BWStatusBarOverlay setAnimation:BWStatusBarOverlayAnimationTypeFromTop];
    [BWStatusBarOverlay showWithMessage:[self randomMessage] loading:YES animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressHideSimple:(id)sender {
    [BWStatusBarOverlay dismissAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressChangeAnimatedText:(id)sender {
    [BWStatusBarOverlay setMessage:[self randomMessage] animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressShowSuccess:(id)sender {
    [BWStatusBarOverlay showSuccessWithMessage:@"Success" duration:2 animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressShowError:(id)sender {
    [BWStatusBarOverlay showErrorWithMessage:@"Error" duration:2 animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)didPressChangeText:(id)sender {
    [BWStatusBarOverlay setMessage:[self randomMessage] animated:NO];
}


@end
