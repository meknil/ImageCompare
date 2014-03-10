//
//  CommandLineArgs.h
//  ImageCompare
//
//  Created by Mathias Linke on 07.03.14.
//  Copyright (c) 2014 Mathias Linke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandLineArgs : NSObject

@property(nonatomic,assign) BOOL verbose;
@property(nonatomic,assign) int maxDistancePerColorComponent;
@property(nonatomic,strong) NSMutableArray *fileNames;

- (BOOL) parseArguments:(NSArray *)arguments;

- (void) printUsageText;

@end
