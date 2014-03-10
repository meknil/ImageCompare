//
//  ImageComparator.m
//  ImageCompare
//
//  Created by Mathias Linke on 06.02.14.
//  Copyright (c) 2014 Mathias Linke. All rights reserved.
//

#import "ImageComparator.h"
#import "Defines.h"

@implementation ImageComparator

-(void) printPixel:(BMPixel)pixel
{
    printf("(R:%0.2f G:%0.2f B:%0.2f A:%0.2f)", pixel.red, pixel.green, pixel.blue, pixel.alpha);
}

- (BMPixel) grayPixel:(BMPixel)pix
{
    float gray = (0.333*pix.red + 0.333*pix.green + 0.333*pix.blue);
    return BMPixelMake(gray, gray, gray, 0.4);
}

- (BOOL) equalsPixel:(BMPixel)cmpPixel toPixel:(BMPixel)refPixel withAlpha:(BOOL)withAlpha threshold:(double)threshold
{
    BOOL isEqual = (refPixel.red == cmpPixel.red && refPixel.green == cmpPixel.green && refPixel.blue == cmpPixel.blue && (!withAlpha || refPixel.alpha == cmpPixel.alpha));
    if(!isEqual)
    {
        double distance = [self colorDistancePixel:cmpPixel pixel:refPixel withAlpha:YES];
        isEqual = (distance <= threshold);
    }
    return isEqual;
}

//
// the color distance is just the quadratic mean color distance, SQRT( (r^2 + g^2 + b^2 + a^2) / 4.0 ) or SQRT( (r^2 + g^2 + b^2 ) / 3.0 )
// but the SQRT operation and the devision are not really necessary to compare both values :)
// the threshold is also calculated in this way.
//

- (float) calcThreshold:(NSUInteger)absoluteDiffPerColorComponent
{
    float c = absoluteDiffPerColorComponent/255.0;
    float t = 3.0*(c*c); // = c^2 + c^2 + c^2
    if(self.verbose)
    {
        printf("Threshold for %lu is %f\n", (unsigned long)absoluteDiffPerColorComponent, t);
    }
    return t;
}

-(double) colorDistancePixel:(BMPixel)cmpPixel  pixel:(BMPixel)refPixel withAlpha:(BOOL)withAlpha
{

    float redDiff = fabsf(cmpPixel.red-refPixel.red);
    float greenDiff = fabsf(cmpPixel.green-refPixel.green);
    float blueDiff = fabsf(cmpPixel.blue-refPixel.blue);
    float alphaDiff = fabsf(cmpPixel.alpha-refPixel.alpha);
    double distance = (withAlpha ? redDiff*redDiff+greenDiff*greenDiff+blueDiff*blueDiff+alphaDiff*alphaDiff : redDiff*redDiff+greenDiff*greenDiff+blueDiff*blueDiff);
    return distance;
}

- (int) compareImage:(NSImage *)tocompareImage withReferenceImage:(NSImage *)referenceImage maskImage:(NSImage *)maskImage
{
    double maxDistance = 0.0000;
    double threshold = [self calcThreshold:self.maxDistancePerColorComponent];
    int compareResult = COMPARE_RESULT_EQUAL;
    bool useMask = maskImage != nil;
    // COMPARING
    ANImageBitmapRep *referenceImageRep = [ANImageBitmapRep imageBitmapRepWithImage:referenceImage];
    ANImageBitmapRep *toCompareImageRep = [ANImageBitmapRep imageBitmapRepWithImage:tocompareImage];
    ANImageBitmapRep *diffImageRep = [ANImageBitmapRep imageBitmapRepWithImage:referenceImage]; // taken from reference
    ANImageBitmapRep *maskImageRep = (useMask ? [ANImageBitmapRep imageBitmapRepWithImage:maskImage] : nil);
    
    if(CGSizeEqualToSize(tocompareImage.size,referenceImage.size) && (!useMask || CGSizeEqualToSize(tocompareImage.size,maskImage.size)))
    {
        BMPixel redPixel = BMPixelMake(1.0, 0.0, 0.0, 0.8);
        NSUInteger refW = referenceImage.size.width;
        NSUInteger refH = referenceImage.size.height;
        BMPixel ignorePixel = [maskImageRep getPixelAtPoint:BMPointMake(0, 0)];
        if(self.verbose)
        {
            printf("Pictures size %dx%d\n", (unsigned int)refW, (unsigned int)refH);
        }
        for(int y=0; y<refH; ++y)
        {
            for(int x=0; x<refW; ++x)
            {
                BOOL ignoreActualPixel = NO;
                if(maskImageRep)
                {
                    BMPixel maskPixel = [maskImageRep getPixelAtPoint:BMPointMake(x, y)];
                    if([self equalsPixel:maskPixel toPixel:ignorePixel withAlpha:NO threshold:threshold])
                    {
                        [diffImageRep setPixel:ignorePixel atPoint:BMPointMake(x, y)];
                        ignoreActualPixel = YES;
                    }
                }
                
                if(!ignoreActualPixel)
                {
                    BMPixel refPixel = [referenceImageRep getPixelAtPoint:BMPointMake(x, y)];
                    BMPixel cmpPixel = [toCompareImageRep getPixelAtPoint:BMPointMake(x, y)];
                    [diffImageRep setPixel:[self grayPixel:refPixel] atPoint:BMPointMake(x, y)];
                    
                    if(![self equalsPixel:cmpPixel toPixel:refPixel withAlpha:NO threshold:threshold])
                    {
                        [diffImageRep setPixel:redPixel atPoint:BMPointMake(x, y)];
                        compareResult = COMPARE_RESULT_NOT_EQUAL;
                        double actualDifference = [self colorDistancePixel:(BMPixel)cmpPixel pixel:(BMPixel)refPixel withAlpha:NO];
                        maxDistance = MAX(maxDistance, actualDifference);
                        if(self.verbose)
                        {
                            printf("Diff x:%d y:%d   ", x, y);
                            [self printPixel:cmpPixel];
                            printf("   ");
                            [self printPixel:refPixel];
                            printf("   dist:%f   ", actualDifference);
                            printf("\n");
                        }
                    }
                }
            }
        }
        
        if(self.verbose)
        {
            printf("Maximum distance is %f\n", maxDistance);
            printf("Maximun quadratic mean distance is %f\n", threshold);
            printf("Top-left mask color ");
            [self printPixel:ignorePixel];
            printf("\n");
        }
        
        // SAVING DIFF
        if(self.diffImageFileName)
        {
            NSData *imageData = [[diffImageRep image] TIFFRepresentation];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
            imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
            BOOL written = [imageData writeToFile:self.diffImageFileName atomically:NO];
            if(!written)
            {
                compareResult = COMPARE_RESULT_IO_ERROR;
            }
        }
    }
    else
    {
        compareResult = COMPARE_RESULT_DIFFERENT_SIZE;
    }
    return compareResult;
}

@end
