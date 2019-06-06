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

#import "VTMagic.h"
#import "UIColor+VTMagic.h"
#import "UIScrollView+VTMagic.h"
#import "UIViewController+VTMagic.h"
#import "VTContentView.h"
#import "VTEnumType.h"
#import "VTMagicController.h"
#import "VTMagicMacros.h"
#import "VTMagicProtocol.h"
#import "VTMagicView.h"
#import "VTMenuBar.h"

FOUNDATION_EXPORT double VTMagicVersionNumber;
FOUNDATION_EXPORT const unsigned char VTMagicVersionString[];

