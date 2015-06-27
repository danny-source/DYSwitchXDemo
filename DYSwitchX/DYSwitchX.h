//
//  DYSwitchX.h
//  DYSwitchXDemo
//
//  Created by danny on 2015/6/27.
//  Copyright (c) 2015年 danny. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 *  ITSwitch is a replica of UISwitch for Mac OS X
 */
@interface DYSwitchX : NSControl

/**
 *  @property on - Gets or sets the switches state
 */
@property (nonatomic, getter=isOn) BOOL on;

/**
 *  @property tintColor - Gets or sets the switches tint
 */
@property (nonatomic, strong) NSColor *switchOnColor;
@property (nonatomic, strong) NSColor *switchOffColor;

@end

