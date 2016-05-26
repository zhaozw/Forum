//
//  CCFFormTree.m
//  CCF
//
//  Created by WDY on 15/12/31.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "CCFFormTreeJSONModel.h"

@implementation CCFFormTreeJSONModel

-(NSArray<CCFFormJSONModel*> *)filterByCCFUser:(BOOL)logdined{
    if (_ccfforms == nil) {
        return nil;
    }
    NSMutableArray<CCFFormJSONModel> * filtered = [NSMutableArray<CCFFormJSONModel> array];
    
    if (logdined) {
        return _ccfforms;
    }
    
    NSUInteger count = _ccfforms.count;
    
    for (int i = 0; i < count; i++) {
        CCFFormJSONModel * form = _ccfforms[i];
        if (form.isNeedLogin == 0) {
            [filtered addObject:form];
        }
    }
    
    for (CCFFormJSONModel * form in filtered) {

        NSMutableArray<CCFFormJSONModel> *childForms = form.childForms;
        if (childForms != nil && childForms.count > 0) {
            for (CCFFormJSONModel * child in childForms) {
            
                if (child.isNeedLogin == 1) {
                    [childForms removeObject:childForms];
                }
            }
        }
    }
    
    
    return [filtered copy];
}
@end
