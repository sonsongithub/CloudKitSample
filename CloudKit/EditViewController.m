//
//  EditViewController.m
//  CloudKit
//
//  Created by sonson on 2014/06/09.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "EditViewController.h"
#import "helper.h"

@interface EditViewController () {
	IBOutlet UITextField	*_textField;
}
@end

@implementation EditViewController

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
	
	[database saveRecord:record
	   completionHandler:^(CKRecord *record, NSError *error) {
		   dispatch_async(dispatch_get_main_queue(), ^{
			   if (error) {
				   DNSLog(@"%@", [error localizedDescription]);
			   }
			   else {
				   [self.navigationController popViewControllerAnimated:YES];
			   }
		   });
	   }];
}

@end
