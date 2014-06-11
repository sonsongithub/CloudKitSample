//
//  TableViewController.m
//  CloudKit
//
//  Created by sonson on 2014/06/06.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "TableViewController.h"

#import <CloudKit/CloudKit.h>
#import "CKModifyRecordsOperation+test.h"
#import "EditViewController.h"
#import "helper.h"

@interface TableViewController () {
	NSMutableArray		*_privateData;
	NSMutableArray		*_publicData;
	UISwitch			*_subscribeSwitch;
	NSOperationQueue	*_queue;
}
@end

@implementation TableViewController

- (IBAction)reload:(id)sender {
	[self refetchPrivate:YES];
	[self refetchPrivate:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"NewEntry"]) {
	}
	else if ([segue.identifier isEqualToString:@"EditEntry"]) {
		EditViewController *vc = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		
		NSMutableArray *target = nil;
		if (indexPath.section == 0) {
			target = _privateData;
			vc.isDatabasePrivate = YES;
		}
		else {
			target = _publicData;
			vc.isDatabasePrivate = NO;
		}
		
		// Configure the cell...
		CKRecord *record = target[indexPath.row];
		
		vc.record = record;
	}
}

- (void)refetchPrivate:(BOOL)private {
	DNSLogMethod
	CKDatabase *database = nil;
	NSMutableArray *target = nil;
	
	if (private) {
		database = [[CKContainer defaultContainer] privateCloudDatabase];
		target = _privateData;
	}
	else {
		database = [[CKContainer defaultContainer] publicCloudDatabase];
		target = _publicData;
	}
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"time > 0"];
	
	CKQuery *query = [[CKQuery alloc] initWithRecordType:@"comment"
											   predicate:predicate];
	[database performQuery:query
					inZoneWithID:nil
			   completionHandler:^(NSArray *results, NSError *error) {
				   DNSLogMainThread
				   dispatch_async(dispatch_get_main_queue(), ^{
					   if (error) {
						   DNSLog(@"%@", [error localizedDescription]);
						   [target removeAllObjects];
					   }
					   else {
						   [target removeAllObjects];
						   [target addObjectsFromArray:results];
					   }
					   [self.tableView reloadData];
				   });
			   }];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self refetchPrivate:YES];
	[self refetchPrivate:NO];
	[self.navigationController setToolbarHidden:NO];}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self setupBottomSwitch];
	_subscribeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"subscribed"];
}

- (void)didChangeSubscribeSwitch:(id)sender {
	if (_subscribeSwitch.on) {
		[self subscribe];
	}
	else {
		[self unsubscribe];
	}
}

- (void)subscribe {
	CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
	if (_subscribeSwitch.on) {
		
		NSPredicate *truePredicate = [NSPredicate predicateWithValue:YES];
		CKSubscription *itemSubscription = [[CKSubscription alloc] initWithRecordType:@"comment"
																			predicate:truePredicate
																			  options:CKSubscriptionOptionsFiresOnRecordCreation];
		
		
		CKNotificationInfo *notification = [[CKNotificationInfo alloc] init];
		notification.alertBody = @"New comment has been added.";
		itemSubscription.notificationInfo = notification;
		
		[database saveSubscription:itemSubscription completionHandler:^(CKSubscription *subscription, NSError *error) {
			if (error) {
				DNSLog(@"%@", [error localizedDescription]);
			}
			else {
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setBool:YES forKey:@"subscribed"];
				[defaults setObject:subscription.subscriptionID forKey:@"subscriptionID"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
		}];
	}
}

- (void)unsubscribe {
	CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
	if (!_subscribeSwitch.on) {
		
		NSString *subscriptionID = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptionID"];
		
		CKModifySubscriptionsOperation *modifyOperation = [[CKModifySubscriptionsOperation alloc] init];
		modifyOperation.subscriptionIDsToDelete = @[subscriptionID];
		
		modifyOperation.modifySubscriptionsCompletionBlock = ^(NSArray *savedSubscriptions, NSArray *deletedSubscriptionIDs, NSError *error) {
			if (error) {
				DNSLog(@"%@", [error localizedDescription]);
			} else {
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"subscriptionID"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
		};
		
		[database addOperation:modifyOperation];
	}
}

- (void)setupBottomSwitch {
	UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIView *switchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
	UISwitch *subscribeSwitch = [[UISwitch alloc] init];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	subscribeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
	label.translatesAutoresizingMaskIntoConstraints = NO;
	label.text = NSLocalizedString(@"Subscribe public.", nil);
	label.font = [UIFont systemFontOfSize:12];
	[switchView addSubview:subscribeSwitch];
	[switchView addSubview:label];
	
	_subscribeSwitch = subscribeSwitch;
	[_subscribeSwitch addTarget:self action:@selector(didChangeSubscribeSwitch:) forControlEvents:UIControlEventValueChanged];
	
	// Autolayout
	NSDictionary *views = NSDictionaryOfVariableBindings(subscribeSwitch, label);
	[switchView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subscribeSwitch(==60)]-4-[label(>=0)]-0-|"
																	  options:0
																	  metrics:nil
																		views:views]];
	[switchView addConstraint:
	 [NSLayoutConstraint constraintWithItem:label
								  attribute:NSLayoutAttributeCenterY
								  relatedBy:NSLayoutRelationEqual
									 toItem:switchView
								  attribute:NSLayoutAttributeCenterY
								 multiplier:1
								   constant:0]];
	[switchView addConstraint:
	 [NSLayoutConstraint constraintWithItem:subscribeSwitch
								  attribute:NSLayoutAttributeCenterY
								  relatedBy:NSLayoutRelationEqual
									 toItem:switchView
								  attribute:NSLayoutAttributeCenterY
								 multiplier:1
								   constant:0]];
	
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:switchView];
	self.toolbarItems = @[flexible, item, flexible];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_publicData = [NSMutableArray array];
	_privateData = [NSMutableArray array];
	_queue = [[NSOperationQueue alloc] init];
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Private";
	}
	if (section == 1) {
		return @"Public";
	}
	return @"Unknown";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [_privateData count];
	}
	else {
		return [_publicData count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
	
	NSMutableArray *target = nil;
	if (indexPath.section == 0) {
		target = _privateData;
	}
	else {
		target = _publicData;
	}
    
    // Configure the cell...
	CKRecord *record = target[indexPath.row];
	
	cell.textLabel.text = record[@"text"];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[record[@"time"] doubleValue]];
	cell.detailTextLabel.text = [formatter stringFromDate:date];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		CKDatabase *database = nil;
		NSMutableArray *target = nil;
		
		if (indexPath.section == 0) {
			database = [[CKContainer defaultContainer] privateCloudDatabase];
			target = _privateData;
		}
		else {
			database = [[CKContainer defaultContainer] publicCloudDatabase];
			target = _publicData;
		}
		CKRecord *recordToBeDeleted = [target objectAtIndex:indexPath.row];
		
		CKModifyRecordsOperation *operation = [CKModifyRecordsOperation testModifyRecordsOperationWithRecordsToSave:@[] recordIDsToDelete:@[recordToBeDeleted.recordID]];
		operation.database = database;
		[_queue addOperation:operation];
		
		[target removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
