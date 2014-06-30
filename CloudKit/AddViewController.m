//
//  AddViewController.m
//  CloudKit
//
//  Created by sonson on 2014/06/09.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "AddViewController.h"

#import <CloudKit/CloudKit.h>
#import "CKModifyRecordsOperation+test.h"
#import "helper.h"

@interface AddViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	IBOutlet UISwitch		*_switch;
	IBOutlet UITextField	*_textField;
	IBOutlet UIImageView	*_imageView;
	NSOperationQueue		*_queue;
}
@end

@implementation AddViewController

- (IBAction)attach:(id)sender {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	_imageView.image = image;
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

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
	
	if (_imageView.image) {
		NSData *data = UIImageJPEGRepresentation(_imageView.image, 0.5);
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *file = [documentsDirectory stringByAppendingPathComponent:@"data.jpg"];
		[data writeToFile:file atomically:YES];
		CKAsset *asset = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:file]];
		[newRecord setObject:asset forKey:@"image"];
	}
	
	CKModifyRecordsOperation *operation = [CKModifyRecordsOperation testModifyRecordsOperationWithRecordsToSave:@[newRecord] recordIDsToDelete:@[]];
	operation.database = database;
	[_queue addOperation:operation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_switch.on = NO;
	_queue = [[NSOperationQueue alloc] init];
}

@end
