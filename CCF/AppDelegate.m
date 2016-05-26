//
//  AppDelegate.m
//  CCF
//
//  Created by WDY on 15/12/28.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Forum.h"
#import "CCFFormDao.h"
#import "ForumCoreDataManager.h"
#import "FormEntry.h"
#import "NSUserDefaults+Extensions.h"
#import "ApiTestViewController.h"
#import "NSUserDefaults+Setting.h"
#import <AVOSCloud.h>
#import <AVOSCloudIM.h>
#import "ForumApi.h"
#import "UIStoryboard+CCF.h"



@interface AppDelegate (){
    BOOL API_DEBUG;
    int DB_VERSION;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // 这地方要换成你自己的ID，别用我这个，否则签名不对你也无法收到推送
    [AVOSCloud setApplicationId:@"x67DOcrRJjpYs5Qb6H13PrMY-gzGzoHsz" clientKey:@"LGvFICq1HK7z01ybiNQcDQNu"];
    
    application.applicationIconBadgeNumber = 0;
    
    
    DB_VERSION = 4;
    
    
    
    API_DEBUG = NO;
    
    if (API_DEBUG) {
        
        NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
        
        NSString * versionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        
        ApiTestViewController * testController = [[ApiTestViewController alloc] init];
        self.window.rootViewController = testController;
        return YES;
    }
    



    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//Documents目录
    
    
    NSLog(@"CCF->>>>>%@", documentsDirectory);
    
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];


    // 设置默认数值
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dictonary = [NSMutableDictionary dictionary];
    [dictonary setValue:[NSNumber numberWithInt:1] forKey:kSIGNATURE];
    [dictonary setValue:[NSNumber numberWithInt:1] forKey:kTOP_THREAD];
    [setting registerDefaults:dictonary];
    
    
    
    ForumApi * browser = [[ForumApi alloc]init];
    LoginUser * loginUser = [browser getLoginUser];
    
    NSDate * date = [NSDate date];
    
    if (loginUser.userID == nil || [loginUser.expireTime compare:date] == NSOrderedAscending) {
        self.window.rootViewController = [[LoginViewController alloc]init];
    }
    
    
    
    
    NSUserDefaults * data = [NSUserDefaults standardUserDefaults];
    
    if ([data dbVersion] != DB_VERSION) {
        
        ForumCoreDataManager * formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
        
        // 清空数据库
        [formManager deleteData];
        
//        NSString *path = [[NSBundle mainBundle]pathForResource:@"ccf" ofType:@"json"];
//        NSArray<CCFForm*> * forms = [[[CCFFormDao alloc]init] parseCCFForms:path];
//
//        
//        NSMutableArray<CCFForm *> * needInsert = [NSMutableArray array];
//        
//        for (CCFForm *form in forms) {
//            [needInsert addObjectsFromArray:[self flatForm:form]];
//        }
//        
//        
//        
//        [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
//            FormEntry *newsInfo = (FormEntry*)target;
//            newsInfo.formId = [src valueForKey:@"formId"];
//            newsInfo.formName = [src valueForKey:@"formName"];
//            newsInfo.parentFormId = [src valueForKey:@"parentFormId"];
//            newsInfo.isNeedLogin = [src valueForKey:@"isNeedLogin"];
//        }];
        
        
        
        ForumCoreDataManager * userManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
        [userManager deleteData];
        
        [data setDBVersion:DB_VERSION];
        
        
        [browser logout];
        
        LoginViewController * rootController = [[LoginViewController alloc] init];
        
        UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
        [stortboard changeRootViewControllerToController:rootController];
        
    }


    [AVOSCloudIM registerForRemoteNotification];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{

    // 首先要想LeanCloud保存installation
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (!succeeded) {
            NSLog(@"Error-------> :%@", error);
        }

    }];
    
    // 向系统申请推送服务
    [AVOSCloudIM handleRemoteNotificationsWithDeviceToken:deviceToken];

    
    

}




-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    
    if (application.applicationState == UIApplicationStateActive) {
        // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个 alertView，只是那样稍显 aggressive：）
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>   didReceiveRemoteNotification   createLocale");
    } else {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>   didReceiveRemoteNotification  remote");
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}







- (NSArray*) flatForm:(Forum*) form{
    NSMutableArray * resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum * childForm in form.childForms) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.andforce.CCF" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CCF" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CCF.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
