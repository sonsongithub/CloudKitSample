//
//  CKModifyRecordsOperation+test.m
//  CloudKit
//
//  Created by sonson on 2014/06/11.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "CKModifyRecordsOperation+test.h"

#import "helper.h"

@implementation CKModifyRecordsOperation(test)

+ (instancetype)testModifyRecordsOperationWithRecordsToSave:(NSArray /* CKRecord */ *)records recordIDsToDelete:(NSArray /* CKRecordID */ *)recordIDs {
	//
	// You have to set appropriate role at iCloud Dashboard in order to edit a property of your record.
	//
	CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:records recordIDsToDelete:recordIDs];
	
	//
	// Save policy
	//
	operation.savePolicy = CKRecordSaveIfServerRecordUnchanged;
	//	operation.savePolicy = CKRecordSaveAllKeys;
	//	operation.savePolicy = CKRecordSaveChangedKeys;
	
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
	
	return operation;
}

@end
