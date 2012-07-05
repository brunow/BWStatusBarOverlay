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

#import "BWStatusBarOverlay.h"

#import <QuartzCore/QuartzCore.h>

#define ROTATION_ANIMATION_DURATION [UIApplication sharedApplication].statusBarOrientationAnimationDuration
#define STATUS_BAR_HEIGHT CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define STATUS_BAR_WIDTH CGRectGetWidth([UIApplication sharedApplication].statusBarFrame)
#define STATUS_BAR_ORIENTATION [UIApplication sharedApplication].statusBarOrientation
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define TEXT_LABEL_FONT [UIFont boldSystemFontOfSize:12]


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface BWStatusBarOverlay ()

- (void)animatateview:(UIView *)view show:(BOOL)show completion:(BWStatusBarBasicBlock)completion;

- (void)animatateview:(UIView *)view
    withAnimationType:(BWStatusBarOverlayAnimationType)animationType
                 show:(BOOL)show
           completion:(BWStatusBarBasicBlock)completion;

- (void)fromTopAnimatateview:(UIView *)view show:(BOOL)show completion:(BWStatusBarBasicBlock)completion;

- (void)fadeAnimatateview:(UIView *)view show:(BOOL)show completion:(BWStatusBarBasicBlock)completion;

- (void)initializeToDefaultState;

- (void)rotateStatusBarWithFrame:(NSValue *)frameValue;

- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue;

- (void)showMessage:(NSString *)message
         withStatus:(BWStatusBarOverlayStatus)status
           duration:(NSTimeInterval)duration
           animated:(BOOL)animated;

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BWStatusBarOverlay

@synthesize progress     = _progress;
@synthesize activityView = _activityView;
@synthesize textLabel    = _textLabel;
@synthesize animation    = _animation;
@synthesize actionBlock  = _actionBlock;
@synthesize contentView  = _contentView;
@synthesize statusLabel  = _statusLabel;


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (BWStatusBarOverlay *)shared {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        self.animation = BWStatusBarOverlayAnimationTypeFade;
        
        _contentView = [[UIView alloc] initWithFrame:self.frame];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.contentView];
        
        _progressView = [[UIView alloc] initWithFrame:self.frame];
        _progressView.frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.frame));
        [self.contentView addSubview:_progressView];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityView.frame = CGRectMake(4, 4, CGRectGetHeight(self.frame) - 4 * 2, CGRectGetHeight(self.frame) - 4 * 2);
        self.activityView.hidesWhenStopped = YES;
        
        if ([self.activityView respondsToSelector:@selector(setColor:)]) { // IOS5 or greater
            [self.activityView.layer setValue:[NSNumber numberWithFloat:0.7f] forKeyPath:@"transform.scale"];
        }
        
        [self.contentView addSubview:self.activityView];
        
        _statusLabel = [[UILabel alloc] initWithFrame:self.activityView.frame];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:self.statusLabel];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.frame = CGRectMake(CGRectGetWidth(self.activityView.frame) + 10,
                                          0,
                                          CGRectGetWidth(self.frame) - (CGRectGetWidth(self.activityView.frame) * 2) - (10 * 2),
                                          CGRectGetHeight(self.frame));
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = TEXT_LABEL_FONT;
        self.textLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressOnView:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willRotateScreen:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self initializeToDefaultState];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showWithMessage:(NSString *)message animated:(BOOL)animated {
    [self showWithMessage:message loading:NO animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoadingWithMessage:(NSString *)message animated:(BOOL)animated {
    [self showWithMessage:message loading:YES animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated {
    [self initializeToDefaultState];
    self.textLabel.text = message;
    self.hidden = NO;
    
    if (YES == loading) {
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
    }
    
    if (animated) {
        [self animatateview:self.contentView show:YES completion:nil];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setMessage:(NSString *)message animated:(BOOL)animated {
    if (animated) {
        [self animatateview:self.textLabel show:NO completion:^{
            self.textLabel.text = message;
            [self animatateview:self.textLabel show:YES completion:nil];
        }];
    } else {
        self.textLabel.text = message;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgress:(float)progress animated:(BOOL)animated {
    _progress = progress;
    
    CGRect frame = _progressView.frame;
    CGFloat width = CGRectGetWidth(self.bounds);
    frame.size.width = width * _progress;
    
    if (animated) {
        [UIView animateWithDuration:0.33 animations:^{
            _progressView.frame = frame;
        }];
    } else {
        _progressView.frame = frame;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(BOOL)show animated:(BOOL)animated {
    if (show) {
        [self.activityView startAnimating];
    } else if (NO == animated) {
        [self.activityView stopAnimating];
    }
    
    if (animated) {
        [self animatateview:self.activityView show:show completion:^{
            if (NO == show) {
                [self.activityView stopAnimating];
            }
        }];
    } else {
        self.activityView.hidden = !show;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showSuccessWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [self showMessage:message
           withStatus:BWStatusBarOverlayStatusSuccess
             duration:duration
             animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showErrorWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [self showMessage:message
           withStatus:BWStatusBarOverlayStatusError
             duration:duration
             animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAnimated:(BOOL)animated {
    if (animated) {
        [self animatateview:self.contentView show:NO completion:^{
            self.hidden = YES;
        }];
    } else {
        self.hidden = YES;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAnimated {
    [self dismissAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismiss {
    [self dismissAnimated:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self.contentView setBackgroundColor:backgroundColor];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    if (animated) {
        [self animatateview:self.contentView show:NO completion:^{
            [self setStatusBarStyle:statusBarStyle];
            [self animatateview:self.contentView show:YES completion:nil];
        }];
    } else {
        [self setStatusBarStyle:statusBarStyle];
    }
} 


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters and setters


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor {
    _progressView.backgroundColor = progressBackgroundColor;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)progressBackgroundColor {
    return _progressView.backgroundColor;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class methods


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] showWithMessage:message loading:loading animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showWithMessage:(NSString *)message animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] showWithMessage:message animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showLoadingWithMessage:(NSString *)message animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] showLoadingWithMessage:message animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setMessage:(NSString *)message animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] setMessage:message animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showSuccessWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] showSuccessWithMessage:message duration:duration animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showErrorWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] showErrorWithMessage:message duration:duration animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setAnimation:(BWStatusBarOverlayAnimationType)animation {
    [[BWStatusBarOverlay shared] setAnimation:animation];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)dismissAnimated:(BOOL)animated {
    [[BWStatusBarOverlay shared] dismissAnimated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)dismissAnimated {
    [[BWStatusBarOverlay shared] dismissAnimated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)dismiss {
    [[BWStatusBarOverlay shared] dismiss];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setProgress:(float)progress animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] setProgress:progress animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showActivity:(BOOL)show animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] showActivity:show animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setBackgroundColor:(UIColor *)backgroundColor {
    [[BWStatusBarOverlay shared] setBackgroundColor:backgroundColor];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    [[BWStatusBarOverlay shared] setStatusBarStyle:statusBarStyle animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setActionBlock:(BWStatusBarBasicBlock)actionBlock {
    [[BWStatusBarOverlay shared] setActionBlock:actionBlock];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setProgressBackgroundColor:(UIColor *)backgroundColor {
    [[BWStatusBarOverlay shared] setProgressBackgroundColor:backgroundColor];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gesture recognizer


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didPressOnView:(UIGestureRecognizer *)gestureRecognizer {
    if (nil != _actionBlock) {
        _actionBlock();
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateScreen:(NSNotification *)notification {
    NSValue *frameValue = [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    
    if (NO == self.hidden) {
        [self rotateStatusBarAnimatedWithFrame:frameValue];
    } else {
        [self rotateStatusBarWithFrame:frameValue];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    if (UIStatusBarStyleBlackOpaque == statusBarStyle ||
        UIStatusBarStyleBlackTranslucent == statusBarStyle ||
        IS_IPAD) {
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"status-bar-pattern-black.jpg"]]];
        self.textLabel.textColor = [UIColor whiteColor];
        [self setProgressBackgroundColor:[UIColor colorWithRed:48/255.0f green:159/255.0f blue:211/255.0f alpha:1]];
        [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        
    } else {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"status-bar-pattern-default.jpg"]]];
        self.textLabel.textColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1];
        [self setProgressBackgroundColor:[UIColor colorWithRed:48/255.0f green:159/255.0f blue:211/255.0f alpha:1]];
        [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
    [self setProgressBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"status-bar-progress.png"]]];
    self.statusLabel.textColor = self.textLabel.textColor;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMessage:(NSString *)message
         withStatus:(BWStatusBarOverlayStatus)status
           duration:(NSTimeInterval)duration
           animated:(BOOL)animated {
    
    if (YES == self.hidden) {
        [self setMessage:message animated:NO];
        [self initializeToDefaultState];
        [self.activityView stopAnimating];
        self.hidden = NO;
        
        if (animated) {
            [self animatateview:self.contentView show:YES completion:nil];
        }
    } else {
        [self setMessage:message animated:animated];
        [self showActivity:NO animated:animated];
        [self fadeAnimatateview:_progressView show:NO completion:nil];
    }
    
    [self performSelector:(animated) ? @selector(dismissAnimated) : @selector(hide)
               withObject:nil
               afterDelay:duration];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue {
    [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self rotateStatusBarWithFrame:frameValue];
        [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
            self.alpha = 1;
        }];
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)rotateStatusBarWithFrame:(NSValue *)frameValue {
    CGRect frame = [frameValue CGRectValue];
    UIInterfaceOrientation orientation = STATUS_BAR_ORIENTATION;
    
    if (UIDeviceOrientationPortrait == orientation) {
        self.transform = CGAffineTransformIdentity;
    } else if (UIDeviceOrientationPortraitUpsideDown == orientation) {
        self.transform = CGAffineTransformMakeRotation(M_PI);
    } else if (UIDeviceOrientationLandscapeRight == orientation) {
        self.transform = CGAffineTransformMakeRotation(M_PI * (-90.0f) / 180.0f);
    } else {
        self.transform = CGAffineTransformMakeRotation(M_PI * 90.0f / 180.0f);
    }
    
    self.frame = frame;
    [self setProgress:self.progress animated:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)animatateview:(UIView *)view show:(BOOL)show completion:(BWStatusBarBasicBlock)completion {
    [self animatateview:view withAnimationType:self.animation show:show completion:completion];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)animatateview:(UIView *)view
    withAnimationType:(BWStatusBarOverlayAnimationType)animationType
                 show:(BOOL)show
           completion:(BWStatusBarBasicBlock)completion {
    
    if (BWStatusBarOverlayAnimationTypeFade == animationType) {
        [self fadeAnimatateview:view show:show completion:completion];
        
    } else if (BWStatusBarOverlayAnimationTypeFromTop == animationType) {
        [self fromTopAnimatateview:view show:show completion:completion];
        
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadeAnimatateview:(UIView *)view show:(BOOL)show completion:(BWStatusBarBasicBlock)completion {
    if (show) {
        view.alpha = 0;
        view.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.alpha = (show) ? 1 : 0;
    } completion:^(BOOL finished) {
        if (NO == show) {
            view.hidden = YES;
            view.alpha = 1;
        }
        
        if (nil != completion)
            completion();
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fromTopAnimatateview:(UIView *)view show:(BOOL)show completion:(BWStatusBarBasicBlock)completion {
    __block CGRect frame = view.frame;
    CGFloat previousY = view.frame.origin.y;
    
    if (show) {
        view.hidden = NO;
        view.alpha = 0;
        frame.origin.y = -CGRectGetHeight(self.frame);
        view.frame = frame;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        frame.origin.y += (show ? 1 : -1) * CGRectGetHeight(self.frame);
        view.frame = frame;
        view.alpha = (show) ? 1 : 0;
    } completion:^(BOOL finished) {
        if (NO == show) {
            frame.origin.y = previousY;
            view.frame = frame;
            view.hidden = YES;
            view.alpha = 1;
        }
        
        if (nil != completion)
            completion();
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeToDefaultState {
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    [self rotateStatusBarWithFrame:[NSValue valueWithCGRect:statusBarFrame]];
    [self setProgress:0];
    _progressView.hidden = NO;
    
    [self setStatusBarStyle:[UIApplication sharedApplication].statusBarStyle animated:NO];
}


@end
