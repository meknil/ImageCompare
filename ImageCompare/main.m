//
//  main.m
//  ImageCompare
//
//  Created by Mathias Linke on 03.02.14.
//  Copyright (c) 2014 Mathias Linke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageComparator.h"
#import "CommandLineArgs.h"
#import "Defines.h"
#import "ANImageBitmapRep.h"


int main(int argc, const char * argv[])
{
    int result = COMPARE_RESULT_EQUAL;
    @autoreleasepool
    {
        //
        // Yes, it's argument parsing by hand ;)
        //
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        CommandLineArgs *args = [[CommandLineArgs alloc] init];
        BOOL argumentParsingResult = [args parseArguments:arguments];
        if(argumentParsingResult)
        {
            NSString *cmpFileName =  [args.fileNames objectAtIndex:0];
            NSString *refFileName =  [args.fileNames objectAtIndex:1];
            NSString *diffFileName = [args.fileNames objectAtIndex:2];
            NSString *maskFileName = (args.fileNames.count==4) ? [args.fileNames objectAtIndex:3] : nil;
            if(args.verbose)
            {
                printf("Compare image     %s\n"
                       "with image        %s\n"
                       "create diff image %s\n",
                       [cmpFileName UTF8String],
                       [refFileName UTF8String],
                       [diffFileName UTF8String]);
                if(maskFileName!=nil)
                {
                    printf("masked by image   %s\n" , [maskFileName UTF8String]);
                }
                printf("Verbose (-v) %d\n"
                       "MaxDistancePerColorComponent (-t) %d\n",
                       args.verbose,
                       args.maxDistancePerColorComponent
                       );
            }
            
            //
            // LOAD IMAGES
            //
            NSImage *referenceImage = [[NSImage alloc] initWithContentsOfFile:refFileName];
            NSImage *toCompareImage = [[NSImage alloc] initWithContentsOfFile:cmpFileName];
            NSImage *maskImage = (maskFileName ? [[NSImage alloc] initWithContentsOfFile:maskFileName] : nil);
            
            if(nil==referenceImage || nil==toCompareImage || (nil!=maskFileName && nil==maskImage))
            {
                result = COMPARE_RESULT_IO_ERROR;
            }
            else
            {
                //
                // COMPARING
                //
                ImageComparator *ic = [[ImageComparator alloc] init];
                ic.maxDistancePerColorComponent = args.maxDistancePerColorComponent;
                ic.verbose = args.verbose;
                ic.diffImageFileName = diffFileName;
                result = [ic compareImage:toCompareImage withReferenceImage:referenceImage maskImage:maskImage];
            }
        }
        else
        {
            result = COMPARE_RESULT_ARGUMENT_ERROR;
        }
        
        switch(result)
        {
            case COMPARE_RESULT_EQUAL:
                printf("Result: Pictures are equal.\n");
                break;
            case COMPARE_RESULT_NOT_EQUAL:
                printf("Result: Pictures are NOT equal. (use option -v to get more details)\n");
                break;
            case COMPARE_RESULT_DIFFERENT_SIZE:
                printf("Error: Pictures with different size.\n");
                break;
            case COMPARE_RESULT_IO_ERROR:
                printf("Error: File not found. (use option -v to get the used file names)\n");
                break;
            case COMPARE_RESULT_ARGUMENT_ERROR:
                [args printUsageText];
                break;
        }
    }
    return result;
}

