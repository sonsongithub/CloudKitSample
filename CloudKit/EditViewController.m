//
//  EditViewController.m
//  CloudKit
//
//  Created by sonson on 2014/06/09.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "EditViewController.h"
#import "helper.h"
#import "CKModifyRecordsOperation+test.h"

@interface EditViewController () {
	IBOutlet UITextField	*_textField;
	NSOperationQueue		*_queue;
}
@end

@implementation EditViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_queue = [[NSOperationQueue alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_textField.text = _record[@"text"];
}

- (IBAction)save:(id)sender {
	CKDatabase *database = nil;
	
	if ([_textField.text length] == 0)
		return;
	
	if ([_textField.text isEqualToString:_record[@"text"]])
		[self.navigationController popViewControllerAnimated:YES];
	
	if (_isDatabasePrivate) {
		database = [[CKContainer defaultContainer] privateCloudDatabase];
	}
	else {
		database = [[CKContainer defaultContainer] publicCloudDatabase];
	}
	
	CKRecord *record = [[CKRecord alloc] initWithRecordType:@"comment" recordID:self.record.recordID];
	
	record[@"time"] = self.record[@"time"];
	record[@"text"] = _textField.text;
	
	//
	// You have to set appropriate role at iCloud Dashboard in order to edit a property of your record.
	//
	CKModifyRecordsOperation *operation = [CKModifyRecordsOperation testModifyRecordsOperationWithRecordsToSave:@[record] recordIDsToDelete:@[]];
	operation.database = database;
	[_queue addOperation:operation];
}

@end
