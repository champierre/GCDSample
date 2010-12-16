//
//  GCDSampleViewController.m
//  GCDSample
//
//  Created by Yuumi Yoshida on 10/12/15.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "GCDSampleViewController.h"
#import "JSON.h"

#define TWITTER_URL_PUBLIC_TIMELINE @"http://api.twitter.com/1/statuses/public_timeline.json"

@implementation GCDSampleViewController
@synthesize tweetMessages;
@synthesize tweetIconURLs;

#pragma mark -
#pragma mark Timer

static NSDate *timeFrom;

- (void)startTimer {
	timeFrom = [[NSDate alloc] init];
}

- (void)stopTimer {
	NSDate *timeTo = [NSDate new];
	NSLog(@"load time = %6.3f", [timeTo timeIntervalSinceDate:timeFrom]);
}


#pragma mark -
#pragma mark Tweitter access


- (NSData *)getData:(NSString *)url; {
	NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
							 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	NSURLResponse *response;
	NSError       *error;
	NSData *result = [NSURLConnection sendSynchronousRequest:request 
										   returningResponse:&response error:&error];
	if (result == nil) {
		NSLog(@"NSURLConnection error %@", error);
	}
	
	return result;
}

- (UIImage *) getImage:(NSString *)url {
	return [UIImage imageWithData:[self getData:url]];
}

- (void)loadPublicTimeline {
	NSString *jsonString = [[[NSString alloc] initWithData:[self getData:TWITTER_URL_PUBLIC_TIMELINE]
										 encoding:NSUTF8StringEncoding] autorelease];
	NSArray *entries = [jsonString JSONValue];

	self.tweetMessages = [[NSMutableArray alloc] init];
	self.tweetIconURLs    = [[NSMutableArray alloc] init];
	for (NSDictionary *entry in entries) {
		[tweetMessages addObject:[entry objectForKey:@"text"]];
		[tweetIconURLs addObject:[[entry objectForKey:@"user"] objectForKey:@"profile_image_url"]];
	}
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self startTimer];
	main_queue = dispatch_get_main_queue();
	timeline_queue = dispatch_queue_create("com.ey-office.gcd-sample.timeline", NULL);
	image_queue = dispatch_queue_create("com.ey-office.gcd-sample.image", NULL);
	
	dispatch_async(timeline_queue, ^{
		[self loadPublicTimeline];
		dispatch_async(main_queue, ^{
			[self.tableView reloadData];
		});
	});
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	dispatch_release(timeline_queue);
	dispatch_release(image_queue);
}
					   
#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 66.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return tweetMessages ? [tweetMessages count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SampleTable";
	
	if (!tweetMessages) {
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.text = @"loading...";
		cell.textLabel.textColor = [UIColor grayColor];
		return cell;
	}
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.textLabel.text = [tweetMessages objectAtIndex:[indexPath row]];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.numberOfLines = 3;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	cell.textLabel.textColor = [UIColor darkGrayColor];
	cell.imageView.image = [UIImage imageNamed:@"blank.png"];

	dispatch_async(image_queue, ^{
		UIImage *icon = [self getImage:[tweetIconURLs objectAtIndex:[indexPath row]]];
		dispatch_async(main_queue, ^{
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.imageView.image = icon;
		});
	});

	if ([indexPath row] == 6) 	[self stopTimer];

    return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.tweetMessages = nil;
	self.tweetIconURLs = nil;
}


- (void)dealloc {
	[tweetMessages release];
	[tweetIconURLs    release];
    [super dealloc];
}

@end
