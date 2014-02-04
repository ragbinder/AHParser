//
//  AHPCustomCellBackground.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 1/24/14.
//  Copyright (c) 2014 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPCustomCellBackground.h"

@implementation AHPCustomCellBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locationsTop[] = {0.0, 0.3};
    CGFloat locationsBot[] = {1.0, 0.7};
    
    //CGColorRef startColor = [UIColor colorWithRed:253.0/255.0 green:225.0/255.0 blue:8.0/255.0 alpha:1].CGColor;
    CGColorRef startColor = [UIColor colorWithRed:0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1].CGColor;

    CGColorRef endColor = [UIColor clearColor].CGColor;
    
    NSArray *colors = @[(__bridge id)startColor,(__bridge id)endColor];
    
    CGGradientRef gradientTop = CGGradientCreateWithColors(colorSpace,(__bridge CFArrayRef) colors, locationsTop);
    CGGradientRef gradientBot = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locationsBot);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect),CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect),CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradientTop, startPoint, endPoint, 0);
    CGContextDrawLinearGradient(context, gradientBot, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradientTop);
    CGGradientRelease(gradientBot);
    CGColorSpaceRelease(colorSpace);
}

@end
