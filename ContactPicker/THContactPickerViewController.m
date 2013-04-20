//
//  ContactPickerViewController.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewController.h"

@interface THContactPickerViewController ()

@end

#define kKeyboardHeight 216.0

@implementation THContactPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Contacts";
        self.contacts = [NSArray array];
        self.selectedContacts = [NSMutableArray array];
        self.filteredContacts = self.contacts;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.filteredContacts = self.contacts;
    [super viewWillAppear: animated];
    self.contactPickerView.placeholderString = @"Select contacts";
    [self adjustTableViewFrame];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [self.contactPickerView selectTextView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustTableViewFrame {
    CGRect frame = self.tableView.frame;
    frame.origin.y = CGRectGetMaxY(self.contactPickerView.frame) + 1;
    frame.size.height = CGRectGetMaxY(self.view.bounds) - kKeyboardHeight - frame.origin.y;
    self.tableView.frame = frame;
}

- (UITableViewCell*) cellForContact: (id<THContact>)contact {
    NSUInteger index = [self.filteredContacts indexOfObject: contact];
    if (index == NSNotFound)
        return nil;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow: index inSection: 0];
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (void) selectContact: (id<THContact>)contact {
    if ([self.selectedContacts containsObject:contact])
        return;
    [self cellForContact: contact].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.selectedContacts addObject:contact];
    id key = [NSValue valueWithPointer: (__bridge const void *)(contact)];
    [self.contactPickerView addContact: key withName:contact.displayName];
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    id<THContact> contact = [self.filteredContacts objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.displayName;
    if ([contact respondsToSelector: @selector(picture)]) {
        UIImage* picture = contact.picture;
        if (!picture)
            picture = [UIImage imageNamed: @"missingAvatar.png"];   //TEMP
        cell.imageView.image = picture;
    }
    if ([contact respondsToSelector: @selector(email)]) {
        cell.detailTextLabel.text = contact.email;
    }

    if ([self.selectedContacts containsObject:contact]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id<THContact> contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:contact]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:contact];
        id key = [NSValue valueWithPointer: (__bridge const void *)(contact)];
        [self.contactPickerView removeContact:key];
    } else {
        [self selectContact: contact];
    }
    
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];    
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewFrame];
}

- (void)contactPickerDidRemoveContact:(id)key {
    id<THContact> contact = [key pointerValue];
    [self.selectedContacts removeObject:contact];

    int index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

@end
