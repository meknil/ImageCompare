//
//  CommandLineArgs.m
//  ImageCompare
//
//  Created by Mathias Linke on 07.03.14.
//  Copyright (c) 2014 Mathias Linke. All rights reserved.
//

#import "CommandLineArgs.h"

#define MAX_DISTANCE_PER_PIXEL_DEFAULT 8

@implementation CommandLineArgs

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        _maxDistancePerColorComponent = MAX_DISTANCE_PER_PIXEL_DEFAULT;
        _verbose = NO;
        _fileNames = [NSMutableArray array];
    }
    return self;
}

- (BOOL) parseArguments:(NSArray *)arguments
{
    BOOL error = NO;
    if(arguments.count <= 1)
    {
        error = YES;
    }
    else
    {
        int argumentIndex = 1;
        while (argumentIndex < arguments.count)
        {
            NSString *a = [arguments objectAtIndex:argumentIndex];
            if(NSOrderedSame==[a compare:@"-h" options:NSCaseInsensitiveSearch])
            {
                error = YES; // force printing of usage
                break;
            }
            else if(NSOrderedSame==[a compare:@"-v" options:NSCaseInsensitiveSearch])
            {
                self.verbose = true;
            }
            else if(NSOrderedSame==[a compare:@"-t" options:NSCaseInsensitiveSearch])
            {
                argumentIndex++;
                if(argumentIndex >= arguments.count)
                {
                    error = YES;
                    break;
                }
                else
                {
                    NSString *v = [arguments objectAtIndex:argumentIndex];
                    self.maxDistancePerColorComponent = [v doubleValue];
                }
            }
            else
            {
                if('-' != [a characterAtIndex:0])
                {
                    [self.fileNames addObject:a];
                }
                else
                {
                    error = YES;
                    break;
                }
            }
            argumentIndex++;
        }
    }
    
    if(self.fileNames.count < 3)
    {
        error = YES;
    }
    
    return !error; // invert because true as return value means all fine :)
}

- (void) printUsageText
{
    printf( "Usage:   ImageCompare [options] <compare-file> <reference-file> <difference-file> [<mask-file>]\n"
            "\n"
            "Options: -h           print this help info\n"
            "         -v           be more verbose\n"
            "         -t <value>   value is a integer interpreted as maximum distance per color component\n"
            "                      The resulting quadratic mean error will be calculated by 3*(value*value)\n"
            "                      Default is %d.\n"
            "\n"
            "Return codes:  0      both images are equal\n"
            "              -1      images are not equal\n"
            "              -2      error because the images have different sizes\n"
            "              -3      error because IO problems (mostly file not found)\n"
            "              -4      error because wrong arguments used\n"
            "\n"
            "Note: If a mask-file is specified then the color of the top left corner will be used to mask areas\n"
            "      where the program doesn't compare pixels!\n"
            "\n"
            "Info: Source for this program at https://github.com/meknil/ImageCompare\n"
            "      Using ANImageBitmapRep (see https://github.com/unixpickle/ANImageBitmapRep)\n\n", MAX_DISTANCE_PER_PIXEL_DEFAULT);
}

@end
