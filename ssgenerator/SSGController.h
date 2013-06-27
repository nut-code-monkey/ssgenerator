//
//  SSGController.h
//  storyboard_segue_generator
//
//  Created by Max Lunin on 21.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSGController : NSObject

@property (strong, nonatomic) NSString* storyboardElementName;
@property (strong, nonatomic) NSString* storyboardID;
@property (strong, nonatomic) NSString* customClass;

@property (strong, nonatomic) NSMutableSet* storyboardIdentifiers;
@property (strong, nonatomic) NSMutableSet* segues;
@property (strong, nonatomic) NSMutableSet* cells;

+(instancetype)controllerWithStoryboardElementName:( NSString* )name
                                      storyboardID:( NSString* )storyboardID
                                        customClass:( NSString* )customClass;

@end
