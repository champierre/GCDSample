//
//  GCDSampleViewController.h
//  GCDSample
//
//  Created by Yuumi Yoshida on 10/12/15.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCDSampleViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *tweetMessages;
	NSMutableArray *tweetIconURLs;
}
@property (nonatomic, retain) NSMutableArray *tweetMessages;
@property (nonatomic, retain) NSMutableArray *tweetIconURLs;

@end

