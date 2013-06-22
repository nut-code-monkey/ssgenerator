//
//  SSGParser.m
//  storyboard_segue_generator
//
//  Created by Max Lunin on 20.06.13.
//  Copyright (c) 2013 Max Lunin. All rights reserved.
//

#import "SSGParser.h"

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
        self.destinations = [NSMutableDictionary dictionary];
        self.segues = [NSMutableSet set];
        self.controllersStack = [NSMutableArray array];
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

+(NSString *)containerClassForElementName:(NSString *)elementName
{
    return @{
              @"viewController": @"UIViewController",
              @"tableViewController" : @"UITableViewController",
              @"navigationController" : @"UINavigationController"
            }
             [elementName];
}

-(BOOL)isContrioller:( NSString* )elementName
{
    return [self.class containerClassForElementName:elementName] != 0;
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if ( [attributeDict[@"sceneMemberID"] isEqual:@"viewController"] )
    {
        NSMutableDictionary* attributes = [attributeDict mutableCopy];
        id idString = attributeDict[@"id"];
        
        self.destinations[ idString ] = attributes;
        
        [self.controllersStack addObject:attributes];
    }
    
    if ( [elementName isEqual:@"segue"] )
    {
        NSMutableDictionary* attributes = [attributeDict mutableCopy];
        if ( self.controllersStack.count )
        {
            attributes[@"sourceViewController"] = [self.controllersStack lastObject];
        }

        [self.segues addObject:attributes];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ( [self isContrioller:elementName] )
    {
        [self.controllersStack removeLastObject];
    }
}

@end
