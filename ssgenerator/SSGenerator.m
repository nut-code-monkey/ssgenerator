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

-(NSString*)seguesForControllerH:( SSGController* )controller
{
    NSString* controllerSeguesType = [NSString stringWithFormat:@"%@StoryboardSegues", [self controllerClass:controller]];

    NSMutableArray* segueLines = [NSMutableArray arrayWithCapacity:controller.segues.count];
    for ( NSString* segue in controller.segues )
        [segueLines addObject:[NSString stringWithFormat:@"   __unsafe_unretained NSString* %@;", segue]];
    
    id seguesTypedef = [NSString stringWithFormat:@""
                      "extern const struct %@ {\n"
                      "%@\n"
                      "} %@ ;\n"
                      , controllerSeguesType
                      , [segueLines componentsJoinedByString:@"\n"]
                      , controllerSeguesType];

    id category = [NSString stringWithFormat:@"\n"
                           "@interface %@ ( StoryboardSegues )\n"
                           "\n"
                           "@property (assign, nonatomic, readonly) struct %@ segues;\n"
                           "\n"
                           "+(struct %@)segues;\n"
                           "\n"
                           @"@end\n\n\n"
                           , [self controllerClass:controller]
                           , controllerSeguesType
                           , controllerSeguesType];

    return [@[seguesTypedef, category] componentsJoinedByString:@"\n"];
}

-(NSString*)cellsForControllerH:( SSGController* )controller
{
    NSString* controllerCellsType = [NSString stringWithFormat:@"%@StoryboardCells", [self controllerClass:controller]];
    
    NSMutableArray* cellLines = [NSMutableArray arrayWithCapacity:controller.cells.count];
    for ( NSString* cell in controller.cells )
        [cellLines addObject:[NSString stringWithFormat:@"   __unsafe_unretained NSString* %@;", cell]];
    
    id seguesTypedef = [NSString stringWithFormat:@""
                        "extern const struct %@ {\n"
                        "%@\n"
                        "} %@ ;\n"
                        , controllerCellsType
                        , [cellLines componentsJoinedByString:@"\n"]
                        , controllerCellsType];
    
    id category = [NSString stringWithFormat:@"\n"
                   "@interface %@ ( StoryboardCells )\n"
                   "\n"
                   "@property (assign, nonatomic, readonly) struct %@ cells;\n"
                   "\n"
                   "+(struct %@)cells;\n"
                   "\n"
                   @"@end\n\n"
                   , [self controllerClass:controller]
                   , controllerCellsType
                   , controllerCellsType];
    
    return [@[seguesTypedef, category] componentsJoinedByString:@"\n"];
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
        if ( controller.customClass && ( controller.segues.count || controller.cells.count || controller.storyboardIdentifiers.count) )
        {
            [controllers addObject:[NSString stringWithFormat:@"#import \"%@.h\"\n\n", controller.customClass]];
        }
        
        if ( controller.segues.count )
        {
            [controllers addObject:[self seguesForControllerH:controller]];
        }
        
        if ( controller.cells.count )
        {
            [controllers addObject:[self cellsForControllerH:controller]];
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

-(NSString*)seguesForControllerM:( SSGController* )controller
{
    NSString* controllerSeguesType = [NSString stringWithFormat:@"%@StoryboardSegues", [self controllerClass:controller]];
    
    NSMutableArray* segueLines = [NSMutableArray arrayWithCapacity:controller.segues.count];
    for ( NSString* segue in controller.segues )
        [segueLines addObject:[NSString stringWithFormat:@"   .%@ = @\"%@\",", segue, segue]];
    
    NSString* seguesTypedef = [NSString stringWithFormat:@"const struct %@ %@ = {\n"
                               "%@\n"
                               "};\n"
                               , controllerSeguesType
                               , controllerSeguesType
                               , [segueLines componentsJoinedByString:@"\n"]];
    
    NSString* category = [NSString stringWithFormat:@"@implementation %@ ( StoryboardSegues )\n\n"
                          "@dynamic segues;\n"
                          "\n"
                          "+(struct %@)segues {\n"
                          "   return %@;\n"
                          "}\n"
                          "\n"
                          "-(struct %@)segue {\n"
                          "   return [self.class segues];\n"
                          "}\n"
                          "\n"
                          "@end\n\n"
                          , [self controllerClass:controller]
                          , controllerSeguesType
                          , controllerSeguesType
                          , controllerSeguesType];

    return [@[seguesTypedef ,category] componentsJoinedByString:@"\n\n"];
}

-(NSString*)cellsForControllerM:( SSGController* )controller
{
    NSString* controllerCellsType = [NSString stringWithFormat:@"%@StoryboardCells", [self controllerClass:controller]];
    
    NSMutableArray* cellsLines = [NSMutableArray arrayWithCapacity:controller.cells.count];
    for ( NSString* cell in controller.cells )
        [cellsLines addObject:[NSString stringWithFormat:@"   .%@ = @\"%@\",", cell, cell]];
    
    NSString* seguesTypedef = [NSString stringWithFormat:@"const struct %@ %@ = {\n"
                               "%@\n"
                               "};\n"
                               , controllerCellsType
                               , controllerCellsType
                               , [cellsLines componentsJoinedByString:@"\n"]];
    
    NSString* category = [NSString stringWithFormat:@"@implementation %@ ( StoryboardCells )\n\n"
                          "@dynamic cells;\n"
                          "\n"
                          "+(struct %@)cells {\n"
                          "   return %@;\n"
                          "}\n"
                          "\n"
                          "-(struct %@)cells {\n"
                          "   return [self.class cells];\n"
                          "}\n"
                          "\n"
                          "@end\n\n"
                          , [self controllerClass:controller]
                          , controllerCellsType
                          , controllerCellsType
                          , controllerCellsType];

    return [@[seguesTypedef ,category] componentsJoinedByString:@"\n\n"];
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
        if ( controller.segues.count )
        {
            [controllers addObject:[self seguesForControllerM:controller]];
        }
        
        if ( controller.cells.count )
        {
            [controllers addObject:[self cellsForControllerM:controller]];
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
