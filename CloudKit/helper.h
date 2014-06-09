//
//  helper.h
//  CloudKit
//
//  Created by sonson on 2014/06/06.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#define _DEBUG

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

#pragma mark - for Debug

#ifdef	_DEBUG
	#define	DNSLog(...)		NSLog(__VA_ARGS__);
	#define DNSLogMethod	NSLog(@"[%s] %@", class_getName([self class]), NSStringFromSelector(_cmd));
	#define DNSLogPoint(p)	NSLog(@"%f,%f", p.x, p.y);
	#define DNSLogSize(p)	NSLog(@"%f,%f", p.width, p.height);
	#define DNSLogRect(p)	NSLog(@"%f,%f %f,%f", p.origin.x, p.origin.y, p.size.width, p.size.height);
	#define DNSLogEdgeInsets(p)	NSLog(@"%f,%f %f,%f", p.top, p.left, p.bottom, p.right);
	#define DNSLogMainThread if ([NSThread isMainThread]){NSLog(@"This is the main thread.");}else{NSLog(@"This is a sub thread.");}
#else
	#define DNSLog(...)		{}
	#define DNSLogMethod	{}
	#define DNSLogPoint(p)	{}
	#define DNSLogSize(p)	{}
	#define DNSLogRect(p)	{}
	#define DNSLogEdgeInsets(p)	{}
	#define DNSLogMainThread {}
#endif