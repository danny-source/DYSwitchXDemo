//
//  DYSwitchX.m
//  DYSwitchXDemo
//
//  Created by danny on 2015/6/27.
//  Copyright (c) 2015年 danny. All rights reserved.
//

#import "DYSwitchX.h"
#import <QuartzCore/QuartzCore.h>



#pragma mark - Default Constants

#define kSwitchDefaultSwitchOffColor [NSColor colorWithCalibratedWhite:1.f alpha:1.f]
//#define kSwitchDefaultBackgroundBorderColor [NSColor colorWithCalibratedWhite:0.f alpha:0.2f]
#define kSwitchDefaultSwitchOnColor [NSColor colorWithCalibratedRed:0.27f green:0.86f blue:0.36f alpha:1.f]

#pragma mark - Static Constants
static NSTimeInterval const kAnimationDuration = 0.5f;
static CGFloat const kBorderWidth = 1.f;
static CGFloat const kEnabledOpacity = 1.f;

#pragma mark - Interface Declare

@interface DYSwitchX ()

@property (nonatomic, getter = isActive) BOOL active;
@property (nonatomic, getter = isDragged) BOOL dragged;
@property (nonatomic, getter = isDraggingIsOnOff) BOOL draggingIsOnOff;

@property (nonatomic, readonly, strong) CALayer *switchBackgroundLayer;
@property (nonatomic, readonly, strong) CALayer *switchTintLayer;
@property (nonatomic, readonly, strong) CALayer *switchThumbLayer;
@property (nonatomic, readonly, strong) CALayer *mainLayer;

@end

@implementation DYSwitchX
{
    NSPoint draggingPoint;
}
@synthesize switchOnColor = _switchOnColor;
@synthesize switchOffColor = _switchOffColor;



// ----------------------------------------------------
#pragma mark - Init
// ----------------------------------------------------

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (!self) return nil;
    
    [self initSwitchLays];
    
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self initSwitchLays];
    
    return self;
}


- (void)initSwitchLays {
    // Root layer
    _mainLayer = [CALayer layer];
    self.layer = _mainLayer;
    self.wantsLayer = YES;
    self.enabled = YES;
    
    // background layer
    _switchBackgroundLayer = [CALayer layer];
    _switchBackgroundLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    _switchBackgroundLayer.bounds = _mainLayer.bounds;
    _switchBackgroundLayer.anchorPoint = (CGPoint){ .x = 0.f, .y = 0.f };
    _switchBackgroundLayer.borderWidth = kBorderWidth;
    _switchBackgroundLayer.cornerRadius = 0.;
    
    // thumb layer
    _switchThumbLayer = [CALayer layer];
    _switchThumbLayer.frame = [self calculateThumbRect];
    _switchThumbLayer.autoresizingMask = kCALayerHeightSizable;
    _switchThumbLayer.backgroundColor = [NSColor colorWithCalibratedWhite:1.f alpha:1.f].CGColor;
    _switchThumbLayer.shadowColor = [[NSColor blackColor] CGColor];
    _switchThumbLayer.shadowOpacity = 0.5f;
    _switchThumbLayer.cornerRadius = 0.f;
    _switchThumbLayer.cornerRadius = 0.;
    //_switchThumbLayer.borderWidth = kBorderWidth;
    
    // tint layer
    _switchTintLayer = [CALayer layer];
    _switchTintLayer.frame = _switchThumbLayer.bounds;
    _switchTintLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    _switchTintLayer.shadowColor = [[NSColor blackColor] CGColor];
    _switchTintLayer.shadowOffset = (CGSize){ .width = 0.f, .height = 0.f };
    _switchTintLayer.backgroundColor = [[NSColor whiteColor] CGColor];
    _switchTintLayer.shadowOpacity = 0.55f;
    _switchTintLayer.cornerRadius = 0.f;
    
    //
    [_mainLayer addSublayer:_switchBackgroundLayer];
    //
    //Tint is sub of thumb layer
    [_switchThumbLayer addSublayer:_switchTintLayer];
    [_mainLayer addSublayer:_switchThumbLayer];
    
    // Initial
    [self refreshLayerSize];
    [self refreshLayer];
}



// ----------------------------------------------------
#pragma mark - NSView
// ----------------------------------------------------

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [self refreshLayerSize];
}

- (void)drawFocusRingMask {
    CGFloat cornerRadius = NSHeight([self bounds])/2.0;
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerRadius yRadius:cornerRadius];
    [[NSColor blackColor] set];
    [path fill];
}

- (BOOL)canBecomeKeyView {
    return [NSApp isFullKeyboardAccessEnabled];
}

- (NSRect)focusRingMaskBounds {
    return [self bounds];
}


#pragma mark - Update Layer

- (void)refreshLayer {
    [CATransaction begin];
    [CATransaction setAnimationDuration:kAnimationDuration];
    {
        
        // ------------------------------- Animate Colors
        if (([self isDragged] && [self isDraggingIsOnOff]) || (![self isDragged] && [self isOn])) {
            _switchBackgroundLayer.borderColor = [NSColor lightGrayColor].CGColor;
            _switchBackgroundLayer.backgroundColor = [self.switchOnColor CGColor];
        } else {
            _switchBackgroundLayer.borderColor = [NSColor lightGrayColor].CGColor;
            _switchBackgroundLayer.backgroundColor = _switchOffColor.CGColor;
        }
        
        // ------------------------------- Animate Enabled-Disabled state
        _mainLayer.opacity = (self.isEnabled) ? kEnabledOpacity : (kEnabledOpacity/2);
        
        self.switchThumbLayer.frame = [self calculateThumbRect];
        self.switchTintLayer.frame = self.switchThumbLayer.bounds;
    }
    [CATransaction commit];
}

- (void)refreshLayerSize {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.switchThumbLayer.frame = [self calculateThumbRect];
        self.switchTintLayer.frame = self.switchThumbLayer.bounds;
    }
    [CATransaction commit];
}


- (CGRect)calculateThumbRect {
    CGFloat height = _switchBackgroundLayer.bounds.size.height - (kBorderWidth * 2.f);
    CGFloat width = (_switchBackgroundLayer.bounds.size.width/2) - (kBorderWidth * 2.f);
    
    CGFloat x = ((!self.isDragged && !self.isOn) || (self.isDragged && !self.isDraggingIsOnOff)) ?
    kBorderWidth :
    NSWidth(_switchBackgroundLayer.bounds) - width - kBorderWidth;

    
    
    return (CGRect) {
        .size.width = width,
        .size.height = height,
        .origin.x = x,
        .origin.y = kBorderWidth,
    };
}




#pragma mark - mouse events

- (void)mouseDown:(NSEvent *)theEvent {
    if (!self.isEnabled) return;
    
    self.active = YES;
    
    [self refreshLayer];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (!self.isEnabled) return;
    
    self.dragged = YES;
    
    draggingPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSLog(@"dragging:%f",draggingPoint.x);
    //x > 1/2 On
    self.draggingIsOnOff = draggingPoint.x >= NSWidth(self.bounds) / 2.f;
    
    [self refreshLayer];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (!self.isEnabled) return;
    
    self.active = NO;
    
    BOOL isOn = (![self isDragged]) ? ![self isOn] : [self isDraggingIsOnOff];
    
    if ((isOn != [self isOn])) {
        self.on = isOn;
        [self invokeTargetAndActionSelector];
    }
    self.on = isOn;
    
    // Reset
    self.dragged = NO;
    self.draggingIsOnOff = NO;
    
    [self refreshLayer];
}

- (void)moveRight:(id)sender {
    if ([self isOn] == NO) {
        self.on = YES;
        [self invokeTargetAndActionSelector];
    }
}

- (void)moveLeft:(id)sender {
    if ([self isOn]) {
        self.on = NO;
        [self invokeTargetAndActionSelector];
    }
}

#pragma mark - Public Property


- (void)setOn:(BOOL)on {
    if (_on != on) {
        _on = on;
    }
    
    [self refreshLayer];
}



- (NSColor *)switchOnColor {
    if (!_switchOnColor) return kSwitchDefaultSwitchOnColor;
    
    return _switchOnColor;
}

- (void)setSwitchOnColor:(NSColor *)tintColor {
    _switchOnColor = tintColor;
    
    [self refreshLayer];
}

- (NSColor *)switchOffColor {
    if (!_switchOffColor) return kSwitchDefaultSwitchOffColor;
    return _switchOffColor;
}

- (void)setSwitchOffColor:(NSColor *)color {
    _switchOffColor = color;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self refreshLayer];
}


#pragma mark - Action & Target

- (void)invokeTargetAndActionSelector {
    if (self.target && self.action) {
        NSMethodSignature *signature = [[self.target class] instanceMethodSignatureForSelector:self.action];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self.target];
        [invocation setSelector:self.action];
        //target=0,action=1
/*
Indices begin with 0. The hidden arguments self (of type id) and _cmd (of type SEL) are at indices 0 and 1; method-specific arguments begin at index 2. Raises NSInvalidArgumentException if index is too large for the actual number of arguments.
 */
        [invocation setArgument:(void *)&self atIndex:2];
        
        [invocation invoke];
    }
}

@end
