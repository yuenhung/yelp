//
//  FiltersViewController.h
//  Yelp
//
//  Created by Vincent Lai on 6/23/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FilterSection) {
    SECTION_DEALS = 0,
    SECTION_DISTANCE = 1,
    SECTION_SORT = 2,
    SECTION_CATEGORIES = 3
};

typedef NS_ENUM(NSInteger, SortMethod) {
    SortMethodBestMatch = 0,
    SortMethodDistance = 1,
    SortMethodHighestRated = 2
};

@class FiltersViewController;

@protocol FiltersViewControllerDelegate <NSObject>

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters;

@end

@interface FiltersViewController : UIViewController

@property (nonatomic, weak) id<FiltersViewControllerDelegate> delegate;

@end
