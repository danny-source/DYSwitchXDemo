//
//  ViewController.m
//  DYSwitchXDemo
//
//  Created by danny on 2015/6/27.
//  Copyright (c) 2015年 danny. All rights reserved.
//

#import "ViewController.h"
#import "DYSwitchX.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)switchValueChanged:(DYSwitchX *)sender {
    NSLog(@"%@",(sender.isOn?@"YES":@"NO"));
}

@end
