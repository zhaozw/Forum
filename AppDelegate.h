//
//  AppDelegate.h
//
//  Created by WDY on 15/12/28.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

@property(readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

- (NSString *)forumBaseUrl;

- (NSString *)forumHost;

- (NSString *) bundleIdentifier;

@end

