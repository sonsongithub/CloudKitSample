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
	
	[database saveRecord:newRecord
			 completionHandler:^(CKRecord *saved, NSError *error) {
				 dispatch_async(dispatch_get_main_queue(), ^{
					 if (error) {
						 DNSLog(@"%@", [error localizedDescription]);
					 }
					 else {
						 DNSLog(@"Added - %@", saved);
						 [self.navigationController popViewControllerAnimated:YES];
					 }
				 });
			 }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_switch.on = NO;
}

@end
