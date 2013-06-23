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

@property (strong, nonatomic) NSArray* controllers;

@end

@implementation SSGenerator

-(instancetype)initWithControllers:( NSArray* )controllers
{
    self = [super init];
    if ( self )
    {
        self.controllers = controllers;
        self.defaultControllerClass = @"UIViewController";
    }
    return self;
}

-(NSString*)controllerClass:( SSGController* )controller
{
    return controller.customClass ? controller.customClass : self.defaultControllerClass;
}

+(instancetype)generatorForControllers:( NSArray* )controllers
{
    return [[self alloc] initWithControllers:controllers];
}

-(NSString*)seguesForControllerH:( SSGController* )controller defaultControllerType:( NSString* )defaultControllerType
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

-(NSString*)cellsForControllerH:( SSGController* )controller defaultControllerType:( NSString* )defaultControllerType
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

-(NSError*)writeH:( NSString* )file
{
    NSMutableArray* controllers = [NSMutableArray arrayWithObject:@"#import <UIKit/UIKit.h>\n\n"];
    
    for (SSGController* controller in self.controllers)
    {
        if ( controller.customClass && ( controller.segues.count || controller.cells.count ) )
        {
            [controllers addObject:[NSString stringWithFormat:@"#import \"%@.h\"\n\n", controller.customClass]];
        }
        
        if ( controller.segues.count )
        {
            [controllers addObject:[self seguesForControllerH:controller
                                        defaultControllerType:self.defaultControllerClass]];
        }
        
        if ( controller.cells.count )
        {
            [controllers addObject:[self cellsForControllerH:controller
                                       defaultControllerType:self.defaultControllerClass]];
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

-(NSString*)seguesForControllerM:( SSGController* )controller defaultControllerType:( NSString* )defaultControllerType
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

-(NSString*)cellsForControllerM:( SSGController* )controller defaultControllerType:( NSString* )defaultControllerType
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


-(NSError*)writeM:( NSString* )file
{
    id header = [NSString stringWithFormat:@"#import \"\%@.h\"", [file lastPathComponent]];

    NSMutableArray* controllers = [NSMutableArray arrayWithObject:header];
    for (SSGController* controller in self.controllers)
    {
        if ( controller.segues.count )
        {
            [controllers addObject:[self seguesForControllerM:controller
                                        defaultControllerType:self.defaultControllerClass]];
        }
        
        if ( controller.cells.count )
        {
            [controllers addObject:[self cellsForControllerM:controller
                                       defaultControllerType:self.defaultControllerClass]];
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
