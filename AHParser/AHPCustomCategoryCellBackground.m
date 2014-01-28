//
//  AHPCustomCategoryCellBackground.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 1/27/14.
//  Copyright (c) 2014 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPCustomCategoryCellBackground.h"

@implementation AHPCustomCategoryCellBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locationsTop[] = {0.0, 0.25};
    CGFloat locationsBot[] = {1.0, 0.75};
    
    CGColorRef startColor = [UIColor colorWithRed:253.0/255.0 green:225.0/255.0 blue:8.0/255.0 alpha:1].CGColor;
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
    
    CGGradientRelease(gradientBot);
    CGGradientRelease(gradientTop);
    CGColorSpaceRelease(colorSpace);
}


@end
