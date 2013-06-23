//
//  SSGParser.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 20.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import "SSGParser.h"
#import "SSGController.h"

@interface SSGParser () <NSXMLParserDelegate>

@property (strong, nonatomic) NSXMLParser* parser;
@property (strong, nonatomic) NSMutableArray* controllersStack;

@end

@implementation SSGParser

-(instancetype)initWithData:( NSData* )data;
{
    self = [super init];
    if (self)
    {
        self.parser = [[NSXMLParser alloc] initWithData:data];
        self.parser.delegate = self;
        self.controllersStack = [NSMutableArray array];
        self.controllers = [NSMutableArray array];
    }
    return self;
}

+(instancetype)parserForStoryboard:( NSString* )storyboardPath error:( NSError*__autoreleasing* )error
{
    NSData* data = [NSData dataWithContentsOfFile:storyboardPath options:0 error:error];
    
    if ( *error )
        return nil;
    
    SSGParser* parser = [[SSGParser alloc] initWithData:data];
    
    if ( ![parser.parser parse] )
    {
        *error = [parser.parser parserError];
        return nil;
    }
    
    return parser;
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if ( [attributeDict[@"sceneMemberID"] isEqual:@"viewController"] )
    {
        SSGController* controller = [SSGController controllerWithStoryboardElementName:elementName
                                                                          storyboardID:attributeDict[@"id"]
                                                                           customClass:attributeDict[@"customClass"]];
        [self.controllers addObject:controller];
        [self.controllersStack addObject:controller];
    }
    
    if ( [elementName isEqual:@"segue"] && [attributeDict[@"identifier"] length] )
    {
        SSGController* controller = [self.controllersStack lastObject];
        if ( controller )
        {
            [controller.segues addObject:attributeDict[@"identifier"]];
        }
    }
    
    if ( [elementName isEqual:@"tableViewCell"] && [attributeDict[@"reuseIdentifier"] length] )
    {
        SSGController* controller = [self.controllersStack lastObject];
        
        [controller.cells addObject:attributeDict[@"reuseIdentifier"]];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    SSGController* controller = [self.controllersStack lastObject];
    if ( [controller.storyboardElementName isEqual:elementName] )
    {
        [self.controllersStack removeLastObject];
    }
}

@end
