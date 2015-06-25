//
//  CheckBoxCell.h
//  Yelp
//
//  Created by Vincent Lai on 6/24/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckBoxCell;

@protocol CheckBoxCellDelegate <NSObject>

- (void)checkBoxCell:(CheckBoxCell *)cell didUpdateValue:(BOOL)value;

@end

@interface CheckBoxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) id<CheckBoxCellDelegate> delegate;

- (void)setOn:(BOOL)on;

@end
