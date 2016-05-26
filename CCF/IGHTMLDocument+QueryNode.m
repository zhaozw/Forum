//
//  IGHTMLDocument+QueryNode.m
//  CCF
//
//  Created by 迪远 王 on 16/3/26.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "IGHTMLDocument+QueryNode.h"

@implementation IGHTMLDocument(QueryNode)

-(IGXMLNode *)queryNodeWithXPath:(NSString *)xpath{
    return [self queryWithXPath:xpath].firstObject;
}
@end
