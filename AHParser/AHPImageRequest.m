//
//  AHPImageRequest.m
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/28/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

/*
 While technically not a request to the WoW web API, this handles retrieving item icons from the blizzard media server. Since multiple items share the same icon, the icons are stored with path strings like "inv_bracers_15" and the items have the path string in their dictionary.
 I am currently using 56x56 icons for the table view. There are multiple sizes of each icon available, including 72x72, 18x18, and 36x36.
*/

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
        return response;
    }
    else
    {
        NSLog(@"Error retrieving Thumbnail for %@",path);
        return nil;
    }
}

@end
