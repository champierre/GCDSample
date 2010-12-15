//
//  GCDSampleAppDelegate.h
//  GCDSample
//
//  Created by Yuumi Yoshida on 10/12/15.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDSampleViewController;

@interface GCDSampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GCDSampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GCDSampleViewController *viewController;

@end

