//
//  AHPButtonBackground.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 2/3/14.
//  Copyright (c) 2014 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPButtonBackground.h"

@implementation AHPButtonBackground

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
    UIColor *systemBlue = [UIColor colorWithRed:0 green:.5 blue:1.0 alpha:1];
    
    CGRect gitRekt = self.bounds;
    CGRect borderRect = CGRectInset(gitRekt, 2.0, 2.0);
    
    CGPathRef clippingPath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:4.0].CGPath;
    
    CGContextAddPath(context, clippingPath);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, systemBlue.CGColor);
    CGContextStrokePath(context);
    
    /*
    CGContextSetStrokeColor(context, systemBlue.CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
    */
}


@end