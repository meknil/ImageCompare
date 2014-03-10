//
//  ImageComparator.h
//  ImageCompare
//
//  Created by Mathias Linke on 06.02.14.
//  Copyright (c) 2014 Mathias Linke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANImageBitmapRep.h"

@interface ImageComparator : NSObject

@property(nonatomic,assign) BOOL verbose;
@property(nonatomic,assign) int maxDistancePerColorComponent;
@property(nonatomic,strong) NSString *diffImageFileName;

- (int) compareImage:(NSImage *)tocompareImage withReferenceImage:(NSImage *)referenceImage maskImage:(NSImage *)maskImage;

@end
