//
//  TPVAppDelegate.h
//  TPV
//
//  Created by Flavio on 12/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "DropboxSDK.h"


@interface TPVAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, DBSessionDelegate> {
    FirstViewController *_firstViewController;
    SecondViewController *_secondViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FirstViewController *firstViewController;
@property (nonatomic, retain) IBOutlet SecondViewController *secondViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
