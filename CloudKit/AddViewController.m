//
//  AddViewController.m
//  CloudKit
//
//  Created by sonson on 2014/06/09.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "AddViewController.h"

#import <CloudKit/CloudKit.h>

#import "helper.h"

@interface AddViewController () {
	IBOutlet UISwitch		*_switch;
	IBOutlet UITextField	*_textField;
	NSOperationQueue		*_queue;
}
@end

@implementation AddViewController

- (IBAction)save:(id)sender {
	CKDatabase *database = nil;
	
	if ([_textField.text length] == 0)
		return;
	
	if (_switch.on) {
		database = [[CKContainer defaultContainer] privateCloudDatabase];
	}
	else {
		database = [[CKContainer defaultContainer] publicCloudDatabase];
	}
	
	double refTime = [NSDate timeIntervalSinceReferenceDate];
	CKRecord *newRecord = [[CKRecord alloc] initWithRecordType:@"comment"];
	
	[newRecord setObject:_textField.text forKey:@"text"];
	[newRecord setObject:[NSNumber numberWithDouble:refTime] forKey:@"time"];
	
	CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[newRecord] recordIDsToDelete:@[]];
	
	operation.database = database;
	operation.completionBlock = ^(void) {
	};
	operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
		if (error) {
			DNSLog(@"%@", error);
		}
		if ([savedRecords count]) {
			DNSLog(@"savedRecords = %@", savedRecords);
		}
		if ([deletedRecordIDs count]) {
			DNSLog(@"deletedRecordIDs = %@", deletedRecordIDs);
		}
	};
	operation.perRecordCompletionBlock = ^(CKRecord *record, NSError *error) {
		DNSLog(@"%@", error);
	};
	operation.perRecordProgressBlock = ^(CKRecord *record, double progress) {
	};
	
	[_queue addOperation:operation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_switch.on = NO;
	_queue = [[NSOperationQueue alloc] init];
}

@end
