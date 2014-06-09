//
//  EditViewController.h
//  CloudKit
//
//  Created by sonson on 2014/06/09.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

@interface EditViewController : UITableViewController

@property (nonatomic, assign) BOOL isDatabasePrivate;
@property (nonatomic, strong) CKRecord *record;

@end
