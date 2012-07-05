//
// Created by Bruno Wernimont on 2012
// Copyright 2012 BWLongTextViewController
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

@class BWStatusBarOverlay;

typedef void (^BWStatusBarBasicBlock)(void);

typedef enum {
    BWStatusBarOverlayAnimationTypeNone, /* No animation */
    BWStatusBarOverlayAnimationTypeFromTop, /* Element appear from top */
    BWStatusBarOverlayAnimationTypeFade /* Element appear with alpha transition */
} BWStatusBarOverlayAnimationType;

typedef enum {
    BWStatusBarOverlayStatusSuccess, /* Show success overlay */
    BWStatusBarOverlayStatusError /* Show error overlay */
} BWStatusBarOverlayStatus;

@interface BWStatusBarOverlay : UIWindow {
    UIView *_progressView;
}

@property (nonatomic, assign) float progress;

@property (nonatomic, readonly) UIView *contentView;

/**
 TextLabel readonly property
 */
@property (nonatomic, readonly) UILabel *textLabel; 

/**
 StatusLabel used to show status
 Not implemented yet
 */
@property (nonatomic, readonly) UILabel *statusLabel;

/**
 Activity view readonly property
 */
@property (nonatomic, readonly) UIActivityIndicatorView *activityView;

/**
 Animation type from overlay
 */
@property (nonatomic, assign) BWStatusBarOverlayAnimationType animation;

/**
 Background color from progress view
 */
@property (nonatomic, assign) UIColor *progressBackgroundColor;

/**
 Block that will be execute if user press the overlay
 */
@property (nonatomic, copy) BWStatusBarBasicBlock actionBlock;

/**
 Return a shared instance of BWStatusBarOverlay class
 
 @return Return a shared instance of BWStatusBarOverlay class
 */
+ (BWStatusBarOverlay *)shared;

/**
 Show the overlay on the status bar with a message
 
 @param message Message that will appear on the label
 @param loading Show an activity view
 @param animated Show with an animation
 */
- (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated;

/**
 Show the overlay on the status bar with a message
 
 @param message Message that will appear on the label
 @param animated Show with an animation
 */
- (void)showWithMessage:(NSString *)message animated:(BOOL)animated;

/**
 Show the overlay on the status bar with a message and activity view
 
 @param message Message that will appear on the label
 @param animated Show with an animation
 */
- (void)showLoadingWithMessage:(NSString *)message animated:(BOOL)animated;

/**
 Change the text message
 
 @param message Message that will appear on the label
 @param animated Show the message with an animation
 */
- (void)setMessage:(NSString *)message animated:(BOOL)animated;

/**
 Show message with a success icon
 
 @param message Message that will appear on the label
 @param duration Time in second after the message will be hidden
 @param animated Show the message with an animation
 */
- (void)showSuccessWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;

/**
 Show message with a error icon
 
 @param message Message that will appear on the label
 @param duration Time in second after the message will be hidden
 @param animated Show the message with an animation
 */
- (void)showErrorWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;

/**
 Hide the overlay from status bar
 
 @param animated Hide with an animation
 */
- (void)dismissAnimated:(BOOL)animated;

/**
 Hide the overlay from status bar with an animation
 */
- (void)dismissAnimated;

/**
 Hide the overlay from status bar without animation
 */
- (void)dismiss;

/**
 Change the progress value
 
 @param progress Progression value between 1 and 0
 @param animated Change value with animation
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

/**
 Show the activity view
 
 @param show Show or hide activity
 @param animated Show or hide with an animation
 */
- (void)showActivity:(BOOL)show animated:(BOOL)animated;

/**
 Change the background color from overlay
 
 @param backgroundColor Background color from overlay
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor;

/**
 Change overlay style
 
 @param statusBarStyle @see UIStatusBarStyle
 @param animated Animate status bar style change
 */
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;

/* Class methods */

+ (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated;

+ (void)showWithMessage:(NSString *)message animated:(BOOL)animated;

+ (void)showLoadingWithMessage:(NSString *)message animated:(BOOL)animated;

+ (void)setMessage:(NSString *)message animated:(BOOL)animated;

+ (void)showSuccessWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;

+ (void)showErrorWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;

+ (void)dismissAnimated:(BOOL)animated;

+ (void)dismissAnimated;

+ (void)dismiss;

+ (void)setAnimation:(BWStatusBarOverlayAnimationType)animation;

+ (void)setProgress:(float)progress animated:(BOOL)animated;

+ (void)showActivity:(BOOL)show animated:(BOOL)animated;

+ (void)setBackgroundColor:(UIColor *)backgroundColor;

+ (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;

+ (void)setActionBlock:(BWStatusBarBasicBlock)actionBlock;

+ (void)setProgressBackgroundColor:(UIColor *)backgroundColor;

@end
