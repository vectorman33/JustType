//
//  JTTextField.m
//  JustType
//
//  Created by Andrea Koglin on 27.12.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>
#import "JTTextField.h"
#import "NSString+JTExtension.h"
#import "JTTextFieldMediatorDelegate.h"
#import "JTDashedBorderedView.h"

UIKIT_STATIC_INLINE void mySelectionDidChange(id self, SEL _cmd, id<UITextInput> textInput);

@interface JTTextField ()

@property (nonatomic, retain) JTTextController *textController;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *pressGesture;
@property (nonatomic, assign) id<UITextFieldDelegate> actualDelegate;
@property (nonatomic, retain) JTTextFieldMediatorDelegate *mediatorDelegate;

@end


@implementation JTTextField
@synthesize textController = _textController;
@synthesize tapGesture = _tapGesture;
@synthesize pressGesture = _pressGesture;
@synthesize highlightView = _highlightView;
@synthesize actualDelegate = _actualDelegate;
@synthesize mediatorDelegate = _mediatorDelegate;
@synthesize useSyntaxHighlighting = _useSyntaxHighlighting;
@synthesize useSyntaxCompletion = _useSyntaxCompletion;

#pragma mark - Object lifecycle
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        
        _textController = [[JTTextController alloc] init];
        _textController.delegate = self;
        
        self.useSyntaxHighlighting = YES;
        self.useSyntaxCompletion = YES;
        
        JTDashedBorderedView *highlightView = [[JTDashedBorderedView alloc] initWithFrame:CGRectZero];
        highlightView.backgroundColor = [UIColor clearColor];
        [self setHighlightView:highlightView];

        _mediatorDelegate = [[JTTextFieldMediatorDelegate alloc] init];
        _mediatorDelegate.textField = self;
        [super setDelegate:_mediatorDelegate];

        [self addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(didSingleTap:)];
        tapGesture.cancelsTouchesInView = YES;
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        self.tapGesture = tapGesture;
        
        UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] init];
        [pressGesture addTarget:self action:@selector(didSingleTap:)];
        pressGesture.cancelsTouchesInView = YES;
        pressGesture.delegate = self;
        [self addGestureRecognizer:pressGesture];
        self.pressGesture = pressGesture;

    }
    return self;
}

- (void)dealloc {
    [self.tapGesture.view removeGestureRecognizer:self.tapGesture];
    [self.pressGesture.view removeGestureRecognizer:self.pressGesture];
    
    [self removeTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    _textController.delegate = nil;
    _textController = nil;
    _mediatorDelegate = nil;
}

#pragma mark - text controller delegate actions
- (NSString *)textContent {
    return self.text;
}

- (void)replaceHighlightingWithRange:(NSRange)newRange {
    if (self.useSyntaxHighlighting) {
        CGRect highlightRect = [self firstRectForRange:[self.textController textRangeFromRange:newRange]];
        highlightRect.origin.x -= 2;
        highlightRect.size.width += 4;
        self.highlightView.frame = highlightRect;
        [self.highlightView setNeedsDisplay];
    }
}

#pragma mark - editing actions
- (void)didChangeText:(id)sender {
    [self.textController didChangeText];
}

#pragma mark - Gesture recognizer actions
- (void)didSingleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textController didChangeSelection];
        });
    }
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - overwritten methods
- (id<UITextFieldDelegate>)delegate {
    return self.mediatorDelegate;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    self.actualDelegate = delegate;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textController didChangeText];
    });
    return YES;
}

#pragma mark - getters & setters
- (void)setUseSyntaxCompletion:(BOOL)useSyntaxCompletion {
    [self.textController setUseSyntaxCompletion:useSyntaxCompletion];
}

- (BOOL)isSyntaxCompletionUsed {
    return [self.textController isSyntaxCompletionUsed];
}

- (void)setHighlightView:(UIView *)highlightView {
    if (_highlightView != highlightView) {
        highlightView.userInteractionEnabled = NO;
        [self addSubview:highlightView];
        _highlightView = highlightView;
    }
}

@end
