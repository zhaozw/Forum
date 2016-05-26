//
//  CCFFormTree.h
//  CCF
//
//  Created by WDY on 15/12/31.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol CCFFormJSONModel
@end


@interface CCFFormJSONModel : JSONModel

@property (nonatomic, assign) int formId;
@property (nonatomic, strong) NSString * formName;
@property (nonatomic, assign) int parentFormId;

@property (nonatomic, strong) NSMutableArray<CCFFormJSONModel> * childForms;
@property (nonatomic, assign) int isNeedLogin;


@end