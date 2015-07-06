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
    NSLog(@"MAKING IMAGE REQUEST");
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://us.media.blizzard.com/wow/icons/56/%@.jpg",path]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.00];
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

+(NSManagedObject*)storeImageWithPath:(NSString *)path
                            inContext:(NSManagedObjectContext *)context
{
    NSData *thumbnailData = [AHPImageRequest imageRequestWithPath:path];
    
    NSManagedObject *newIcon = [NSEntityDescription insertNewObjectForEntityForName:@"Icon" inManagedObjectContext:context];
    [newIcon setValue:thumbnailData forKey:@"thumbnail"];
    [newIcon setValue:path forKey:@"icon"];
   
    NSError *error;
    if(![context save:&error])
    {
        NSLog(@"Error Saving Thumbnail: %@",error);
    }
    else
    {
        //NSLog(@"New thumbnail saved as: %@",path);
    }
    
    return newIcon;
}

+(BOOL)saveImageWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",name]];
    NSData *thedata = [self imageRequestWithPath:name];
    
    if(thedata){
        if([thedata writeToFile:localFilePath atomically:YES]) {
            return YES;
        }
    }
    
    return NO;
}

+(UIImage *)localImageWithName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",name]];
    
    UIImage *image = [UIImage imageWithContentsOfFile:localFilePath];
    
    if (image) {
        return image;
    }
    
    return nil;
}

+(UIImage *)imageWithName:(NSString *)name
{
    UIImage *returnImage = [self localImageWithName:name];
    
    if (returnImage) {
        return returnImage;
    }
    else {
        returnImage = [UIImage imageWithData:[AHPImageRequest imageRequestWithPath:name]];
        
        if(returnImage)
            return returnImage;
    }
    
    return nil;
}

@end
