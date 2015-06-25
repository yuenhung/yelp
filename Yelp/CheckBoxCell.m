//
//  CheckBoxCell.m
//  Yelp
//
//  Created by Vincent Lai on 6/24/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "CheckBoxCell.h"

@interface CheckBoxCell ()

@property (weak, nonatomic) IBOutlet UIButton *checkBox;

- (IBAction)chechBoxAction:(id)sender;

@end

@implementation CheckBoxCell

- (void)awakeFromNib {
    // Initialization code
    UIImage *unCheckImage = [UIImage imageNamed:@"uncheck"];
    unCheckImage = [unCheckImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIImage *checkImage = [UIImage imageNamed:@"check"];
    checkImage = [checkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.checkBox setBackgroundImage:unCheckImage forState:UIControlStateNormal];
    [self.checkBox setBackgroundImage:checkImage forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOn:(BOOL)on {
    _on = on;
    self.checkBox.selected = on;
}

- (IBAction)chechBoxAction:(id)sender {
    if (self.on == YES) {
        [self setOn:NO];
    } else {
        [self setOn:YES];
    }
    
    [self.delegate checkBoxCell:self didUpdateValue:self.on];
}
@end
