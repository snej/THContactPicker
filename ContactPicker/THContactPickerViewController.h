//
//  ContactPickerViewController.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerView.h"

@protocol THContact <NSObject>
@property (readonly) NSString* displayName;
@optional
@property (readonly) UIImage* picture;
@property (readonly) NSString* email;
@end

@interface THContactPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, THContactPickerDelegate>

@property (nonatomic, strong) IBOutlet THContactPickerView *contactPickerView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

- (void) selectContact: (id<THContact>)contact;

@end
