//
//  SSGenerator.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 21.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import "SSGenerator.h"
#import "SSGController.h"

@interface SSGenerator ()

@property (strong, nonatomic) NSString* storyboard;
@property (strong, nonatomic) NSArray* controllers;

@end

@implementation SSGenerator

-(instancetype)initWithStoryboard:( NSString* )storyboard controllers:( NSArray* )controllers
{
    self = [super init];
    if ( self )
    {
        self.controllers = controllers;
        self.defaultControllerClass = @"UIViewController";
        self.storyboard = storyboard;
    }
    return self;
}

-(NSString*)controllerClass:( SSGController* )controller
{
    return controller.customClass ? controller.customClass : self.defaultControllerClass;
}

+(instancetype)generatorForStoryboard:( NSString* )storyboard controllers:( NSArray* )controllers
{
    return [[self alloc] initWithStoryboard:storyboard controllers:controllers];
}

#pragma mark - Lines for *.h file

-(NSString*)segueForControllerH:( SSGController* )controller
{
    NSString* controllerSegueType = [NSString stringWithFormat:@"%@StoryboardSegue", [self controllerClass:controller]];

    NSMutableArray* segueLines = [NSMutableArray arrayWithCapacity:controller.segue.count];
    for ( NSString* segue in controller.segue )
        [segueLines addObject:[NSString stringWithFormat:@"   __unsafe_unretained NSString* %@;", segue]];
    
    id segueTypedef = [NSString stringWithFormat:@""
                      "extern const struct %@ {\n"
                      "%@\n"
                      "} %@ ;\n"
                      , controllerSegueType
                      , [segueLines componentsJoinedByString:@"\n"]
                      , controllerSegueType];

    id category = [NSString stringWithFormat:@"\n"
                           "@interface %@ ( StoryboardSegue )\n"
                           "\n"
                           "@property (assign, nonatomic, readonly) struct %@ segue;\n"
                           "\n"
                           "+(struct %@)segue;\n"
                           "\n"
                           @"@end\n\n\n"
                           , [self controllerClass:controller]
                           , controllerSegueType
                           , controllerSegueType];

    return [@[segueTypedef, category] componentsJoinedByString:@"\n"];
}

-(NSString*)cellForControllerH:( SSGController* )controller
{
    NSString* controllerCellType = [NSString stringWithFormat:@"%@StoryboardCell", [self controllerClass:controller]];
    
    NSMutableArray* cellLines = [NSMutableArray arrayWithCapacity:controller.cell.count];
    for ( NSString* cell in controller.cell )
        [cellLines addObject:[NSString stringWithFormat:@"   __unsafe_unretained NSString* %@;", cell]];
    
    id segueTypedef = [NSString stringWithFormat:@""
                        "extern const struct %@ {\n"
                        "%@\n"
                        "} %@ ;\n"
                        , controllerCellType
                        , [cellLines componentsJoinedByString:@"\n"]
                        , controllerCellType];
    
    id category = [NSString stringWithFormat:@"\n"
                   "@interface %@ ( StoryboardCell )\n"
                   "\n"
                   "@property (assign, nonatomic, readonly) struct %@ cell;\n"
                   "\n"
                   "+(struct %@)cell;\n"
                   "\n"
                   @"@end\n\n"
                   , [self controllerClass:controller]
                   , controllerCellType
                   , controllerCellType];
    
    return [@[segueTypedef, category] componentsJoinedByString:@"\n"];
}

-(NSString*)constructorsForControllerH:( SSGController* )controller
{
    NSMutableArray* constructors = [NSMutableArray arrayWithCapacity:controller.storyboardIdentifiers.count];
    for ( NSString* storyboardIdentifier in controller.storyboardIdentifiers )
    {
        [constructors addObject:[NSString stringWithFormat:@"+(instancetype)controller%@;\n", storyboardIdentifier]];
    }
    
    return [NSString stringWithFormat:@"@interface %@ ( StoryboardIdentifiers )\n\n"
            "%@\n"
            "@end\n"
            , [self controllerClass:controller],
            [constructors componentsJoinedByString:@"\n"]];
}

#pragma mark -

-(NSError*)writeH:( NSString* )file
{
    NSMutableArray* controllers = [NSMutableArray arrayWithObject:@"#import <UIKit/UIKit.h>\n\n"];
    
    for ( SSGController* controller in self.controllers )
    {
        if ( controller.customClass && ( controller.segue.count || controller.cell.count || controller.storyboardIdentifiers.count) )
        {
            [controllers addObject:[NSString stringWithFormat:@"#import \"%@.h\"\n\n", controller.customClass]];
        }
        
        if ( controller.segue.count )
        {
            [controllers addObject:[self segueForControllerH:controller]];
        }
        
        if ( controller.cell.count )
        {
            [controllers addObject:[self cellForControllerH:controller]];
        }
        
        if ( controller.storyboardIdentifiers.count )
        {
            [controllers addObject:[self constructorsForControllerH:controller]];
        }
    }

    NSString* hFile = [controllers componentsJoinedByString:@"\n\n"];
    
    NSError* error = nil;
    [hFile writeToFile:[file stringByAppendingString:@".h"]
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&error];

    return error;
}

#pragma mark - Lines for *.m file

-(NSString*)segueForControllerM:( SSGController* )controller
{
    NSString* controllerSegueType = [NSString stringWithFormat:@"%@StoryboardSegue", [self controllerClass:controller]];
    
    NSMutableArray* segueLines = [NSMutableArray arrayWithCapacity:controller.segue.count];
    for ( NSString* segue in controller.segue )
        [segueLines addObject:[NSString stringWithFormat:@"   .%@ = @\"%@\",", segue, segue]];
    
    NSString* segueTypedef = [NSString stringWithFormat:@"const struct %@ %@ = {\n"
                               "%@\n"
                               "};\n"
                               , controllerSegueType
                               , controllerSegueType
                               , [segueLines componentsJoinedByString:@"\n"]];
    
    NSString* category = [NSString stringWithFormat:@"@implementation %@ ( StoryboardSegue )\n\n"
                          "@dynamic segue;\n"
                          "\n"
                          "+(struct %@)segue {\n"
                          "   return %@;\n"
                          "}\n"
                          "\n"
                          "-(struct %@)segue {\n"
                          "   return [self.class segue];\n"
                          "}\n"
                          "\n"
                          "@end\n\n"
                          , [self controllerClass:controller]
                          , controllerSegueType
                          , controllerSegueType
                          , controllerSegueType];

    return [@[segueTypedef ,category] componentsJoinedByString:@"\n\n"];
}

-(NSString*)cellForControllerM:( SSGController* )controller
{
    NSString* controllerCellType = [NSString stringWithFormat:@"%@StoryboardCell", [self controllerClass:controller]];
    
    NSMutableArray* cellLines = [NSMutableArray arrayWithCapacity:controller.cell.count];
    for ( NSString* cell in controller.cell )
        [cellLines addObject:[NSString stringWithFormat:@"   .%@ = @\"%@\",", cell, cell]];
    
    NSString* cellTypedef = [NSString stringWithFormat:@"const struct %@ %@ = {\n"
                               "%@\n"
                               "};\n"
                               , controllerCellType
                               , controllerCellType
                               , [cellLines componentsJoinedByString:@"\n"]];
    
    NSString* category = [NSString stringWithFormat:@"@implementation %@ ( StoryboardCell )\n\n"
                          "@dynamic cell;\n"
                          "\n"
                          "+(struct %@)cell {\n"
                          "   return %@;\n"
                          "}\n"
                          "\n"
                          "-(struct %@)cell {\n"
                          "   return [self.class cell];\n"
                          "}\n"
                          "\n"
                          "@end\n\n"
                          , [self controllerClass:controller]
                          , controllerCellType
                          , controllerCellType
                          , controllerCellType];

    return [@[cellTypedef ,category] componentsJoinedByString:@"\n\n"];
}

-(NSString*)constructorsForControllerM:( SSGController* )controller
{
    NSMutableArray* constructors = [NSMutableArray arrayWithCapacity:controller.storyboardIdentifiers.count];
    for ( NSString* storyboardIdentifier in controller.storyboardIdentifiers)
    {
        [constructors addObject:[NSString stringWithFormat:@"+(instancetype)controller%@ {\n"
                                 "   UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@\"%@\" bundle:nil];\n"
                                 "   return [storyboard instantiateViewControllerWithIdentifier:@\"%@\"];\n"
                                 "}\n"
                                 , storyboardIdentifier
                                 , self.storyboard
                                 , storyboardIdentifier]];
    }
    
    return [NSString stringWithFormat:@"@implementation %@ ( StoryboardIdentifiers )\n\n"
            "%@"
            "@end\n\n"
            , [self controllerClass:controller]
            , [constructors componentsJoinedByString:@"\n\n"]];
}

#pragma mark -

-(NSError*)writeM:( NSString* )file
{
    id header = [NSString stringWithFormat:@"#import \"\%@.h\"", [file lastPathComponent]];

    NSMutableArray* controllers = [NSMutableArray arrayWithObject:header];
    for (SSGController* controller in self.controllers)
    {
        if ( controller.segue.count )
        {
            [controllers addObject:[self segueForControllerM:controller]];
        }
        
        if ( controller.cell.count )
        {
            [controllers addObject:[self cellForControllerM:controller]];
        }
        
        if ( controller.storyboardIdentifiers.count )
        {
            [controllers addObject:[self constructorsForControllerM:controller]];
        }
    }

    NSString* mFile = [controllers componentsJoinedByString:@"\n\n"];
    
    NSError* error = nil;
    [mFile writeToFile:[file stringByAppendingString:@".m"]
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&error];
    
    return error;
}

@end
