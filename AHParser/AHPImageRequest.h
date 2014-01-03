//
//  AHPImageRequest.h
//  AHParser
//
//  Created by Steven Jordan Kozmary on 8/28/13.
//  Copyright (c) 2013 Steven Jordan Kozmary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHPImageRequest : NSObject

//This function takes an icon path and fetches it from the blizzard media server. It will return an NSData object that will then need to be converted into an image with [UIImage imageWithData: ]. The data that is returned will convert into a 56x56 image.
//path needs to be the "icon" value from the item or pet dictionary for which you are fetching the thumbnail.
+(NSData*)imageRequestWithPath:(NSString *) path;

@end
