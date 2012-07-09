## BWStatusBarOverlay

BWStatusBarOverlay is a custom status bar overlay window. It support touch by setting a block that will be called after touch. It work well on both iPad and iPhone and of course in any orientation.

![Screenshot](https://github.com/brunow/BWStatusBarOverlay/raw/master/picture1.jpg)

![Screenshot](https://github.com/brunow/BWStatusBarOverlay/raw/master/picture2.jpg)

![Screenshot](https://github.com/brunow/BWStatusBarOverlay/raw/master/picture3.jpg)

![Screenshot](https://github.com/brunow/BWStatusBarOverlay/raw/master/picture4.jpg)

## Installation

**Copy** **BWStatusBarOverlay** dir into your project.

## How to use it

	+ (id)shared;

Show overlay

	+ (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated;
	+ (void)showWithMessage:(NSString *)message animated:(BOOL)animated;
	+ (void)showLoadingWithMessage:(NSString *)message animated:(BOOL)animated;

Show message and hide after duration

	+ (void)showSuccessWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;
	+ (void)showErrorWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated;

Customizing

	+ (void)setProgress:(float)progress animated:(BOOL)animated;
	+ (void)showActivity:(BOOL)show animated:(BOOL)animated;
	+ (void)setBackgroundColor:(UIColor *)backgroundColor;
	+ (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;
	+ (void)setAnimation:(BWStatusBarOverlayAnimationType)animation;
	+ (void)setActionBlock:(BWStatusBarBasicBlock)actionBlock;
	+ (void)setProgressBackgroundColor:(UIColor *)backgroundColor;

Hidding

	+ (void)dismissAnimated:(BOOL)animated;
	+ (void)dismissAnimated;
	+ (void)dismiss;

Animation type

	typedef enum {
	    BWStatusBarOverlayAnimationTypeNone, /* No animation */
	    BWStatusBarOverlayAnimationTypeFromTop, /* Element appear from top */
	    BWStatusBarOverlayAnimationTypeFade /* Element appear with alpha transition */
	} BWStatusBarOverlayAnimationType;

## ARC

BWStatusBarOverlay is ARC only.

## Contact

Bruno Wernimont

- Twitter - [@brunowernimont](http://twitter.com/brunowernimont)

## Thanks

Thanks to [Noomia](http://noomiastudio.com/) for the blue gradient image.