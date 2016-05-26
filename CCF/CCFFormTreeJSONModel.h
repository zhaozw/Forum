//
//  CCFFormTree.h
//  CCF
//
//  Created by WDY on 15/12/31.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "CCFFormJSONModel.h"

@interface CCFFormTreeJSONModel : JSONModel


@property (strong, nonatomic) NSArray<CCFFormJSONModel*>* ccfforms;

-(NSArray<CCFFormJSONModel>*) filterByCCFUser:(BOOL) logdined;

@end
