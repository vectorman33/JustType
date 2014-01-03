//
//  JTKeyboardListener.h
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTKeyboardListener : NSObject <UIGestureRecognizerDelegate>

+ (id)sharedInstance;

@property (nonatomic, assign, getter = isVisualHelpEnabled) BOOL enableVisualHelp;

- (void)observeKeyboardGestures:(BOOL)activate;

- (BOOL)keyboardIsAvailable;

@end
