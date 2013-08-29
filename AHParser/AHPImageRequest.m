//
//  AHPImageRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/28/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import "AHPImageRequest.h"

@implementation AHPImageRequest

+(NSData*) imageRequestWithPath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://us.media.blizzard.com/wow/icons/56/%@.jpg",path]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(response)
    {
        //NSLog(@"%@",response);
        return response;
    }
    else
    {
        NSLog(@"Error retrieving Thumbnail for %@",path);
        return nil;
    }
}

@end
