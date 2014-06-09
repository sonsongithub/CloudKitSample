//
//  TableViewController.m
//  CloudKit
//
//  Created by sonson on 2014/06/06.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "TableViewController.h"

#import <CloudKit/CloudKit.h>

#import "EditViewController.h"

#import "helper.h"

@interface TableViewController () {
	NSMutableArray *_privateData;
	NSMutableArray *_publicData;
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_publicData = [NSMutableArray array];
	_privateData = [NSMutableArray array];
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
	cell.detailTextLabel.text = [record[@"time"] stringValue];
    
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
		
		[database deleteRecordWithID:recordToBeDeleted.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
			if (error) {
				DNSLog(@"%@", [error localizedDescription]);
			}
			else {
				DNSLog(@"Deleted - %@", recordID);
			}
		}];
		[target removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
