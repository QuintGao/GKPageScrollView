#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIViewController+WMPageController.h"
#import "WMPageController.h"
#import "WMMenuItem.h"
#import "WMMenuView.h"
#import "WMProgressView.h"
#import "WMScrollView.h"

FOUNDATION_EXPORT double WMPageControllerVersionNumber;
FOUNDATION_EXPORT const unsigned char WMPageControllerVersionString[];

