#ifndef SSKMultiplatform
#define SSKMultiplatform

#pragma mark - Types

#if TARGET_OS_IPHONE
#define SSKWindowType UIWindow
#define SSKViewControllerType UIViewController
#define SSKFontType UIFont
#define SSKEdgeInsetsType UIEdgeInsets
#else
#define SSKWindowType NSWindow
#define SSKViewControllerType NSViewController
#define SSKFontType NSFont
#define SSKEdgeInsetsType NSEdgeInsets
#endif

static inline SSKEdgeInsetsType SSKEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
{
    SSKEdgeInsetsType edgeInsets;
    
    edgeInsets.top = top;
    edgeInsets.left = left;
    edgeInsets.bottom = bottom;
    edgeInsets.right = right;
    
    return edgeInsets;
}

#pragma mark - Platform information

/**
 *  Enum describing various platforms that a SpriteKit game can run on
 */
typedef enum : NSUInteger {
    SSKPlatformTypePhone,
    SSKPlatformTypePad,
    SSKPlatformTypeDesktop
} SSKPlatformType;

/**
 *  Get the current platform type that the game is currently running on
 */
static inline SSKPlatformType SSKCurrentPlatform()
{
#if TARGET_OS_IPHONE
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? SSKPlatformTypePhone : SSKPlatformTypePad;
#else
    return SSKPlatformTypeDesktop;
#endif
}

#pragma mark - Device orientation information

/**
 *  Enum providing a simplified, platform-agnostic way to handle device orientation
 */
typedef enum : NSUInteger {
    SSKDeviceOrientationPortrait,
    SSKDeviceOrientationLandscape
} SSKDeviceOrientation;

/**
 *  Get the current orientation of the device that the game is currently running on
 *
 *  @discussion For OSX, this will always return SSKDeviceOrientationLandscape
 */
static inline SSKDeviceOrientation SSKCurrentDeviceOrientation()
{
#if TARGET_OS_IPHONE
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        return SSKDeviceOrientationLandscape;
    
    return SSKDeviceOrientationPortrait;
#else
    return SSKDeviceOrientationLandscape;
#endif
}

#pragma mark - Screen scale information

/**
 *  Get the scale of the screen that the game is currently running on
 *
 *  @discussion For OSX, this will return the scale of the screen on which the
 *  application's key window is being rendered.
 */
static inline CGFloat SSKCurrentScreenScale()
{
#if TARGET_OS_IPHONE
    return [UIScreen mainScreen].scale;
#else
    return [[NSScreen mainScreen] backingScaleFactor];
#endif
}

#endif
