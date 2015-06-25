//
//  FiltersViewController.m
//  Yelp
//
//  Created by Vincent Lai on 6/23/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "CheckBoxCell.h"
#import "ExpandCell.h"
#import "SeeAllCell.h"

@interface FiltersViewController ()<UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, CheckBoxCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *distances;
@property (nonatomic, strong) NSArray *sortMethods;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSDictionary *selectedDistance;
@property (nonatomic, strong) NSDictionary *selectedSortMethod;
@property (nonatomic) BOOL offeringDeal;

@property (nonatomic) BOOL distanceExpanded;
@property (nonatomic) BOOL sortExpanded;
@property (nonatomic) BOOL categoriesExpanded;

- (void)initCategories;
- (void)initArrays;


@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.selectedCategories = [NSMutableSet set];
        [self initCategories];
        [self initArrays];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //定義navigation 左右按鈕 同時設定callback function
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckBoxCell" bundle:nil] forCellReuseIdentifier:@"CheckBoxCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ExpandCell" bundle:nil] forCellReuseIdentifier:@"ExpandCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SeeAllCell" bundle:nil] forCellReuseIdentifier:@"SeeAllCell"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.offeringDeal = [defaults boolForKey:@"filtersOfferingDeal"];
    self.selectedDistance = [defaults objectForKey:@"filtersSelectedDistance"];
    self.selectedSortMethod = [defaults objectForKey:@"filtersSelectedSortMethod"];
    
    NSData *selectedCategoriesData = [defaults objectForKey:@"filtersSelectedCategories"];
    self.selectedCategories = [NSKeyedUnarchiver unarchiveObjectWithData:selectedCategoriesData];
    
    if (!self.selectedDistance) {
        self.selectedDistance = self.distances[0];
    }
    if (!self.selectedSortMethod) {
        self.selectedSortMethod = self.sortMethods[0];
    }
    if (!self.selectedCategories) {
        self.selectedCategories = [NSMutableSet set];
    }
}

//定義table view每個section的數量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case SECTION_DEALS:
            return 1;
        case SECTION_DISTANCE:
            if (self.distanceExpanded)  return 5;
            return 1;
        case SECTION_SORT:
            if (self.sortExpanded)  return 3;
            return 1;
        case SECTION_CATEGORIES:
            if (self.categoriesExpanded)
                return self.categories.count;
            return 4;
        default:
            return 0;
    }
}

//定義每個cell的內容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    //分類一 Offering a Deal 的描述
    if(indexPath.section == SECTION_DEALS)
    {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        cell.titleLabel.text = @"Offering a Deal";
        cell.on = self.offeringDeal;
        cell.delegate = self;
        return cell;
    }
    else if(indexPath.section == SECTION_DISTANCE)
    {
        if (!self.distanceExpanded) {
            ExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandCell"];
            cell.titleLabel.text = self.selectedDistance[@"name"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            CheckBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckBoxCell"];
            cell.titleLabel.text = self.distances[indexPath.row][@"name"];
            cell.on = [self.selectedDistance isEqualToDictionary:self.distances[indexPath.row]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }
    }
    else if(indexPath.section == SECTION_SORT)
    {
        if (!self.sortExpanded) {
            ExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandCell"];
            cell.titleLabel.text = self.selectedSortMethod[@"name"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else {
            CheckBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckBoxCell"];
            cell.titleLabel.text = self.sortMethods[indexPath.row][@"name"];
            cell.on = [self.selectedSortMethod isEqualToDictionary:self.sortMethods[indexPath.row]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }
    }
    else
    {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        
        if (!self.categoriesExpanded) {
            SeeAllCell *seeAllcell = [tableView dequeueReusableCellWithIdentifier:@"SeeAllCell"];
            
            if (indexPath.row == 3) {
                return seeAllcell;
            } else {
                cell.titleLabel.text = self.categories[indexPath.row][@"name"];
                cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
                cell.delegate = self;
                return cell;
            }
        } else {
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            cell.delegate = self;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected section: %ld, row: %ld", (long)indexPath.section, (long)indexPath.row);
    if (indexPath.section == SECTION_DISTANCE)
    {
        if (!self.distanceExpanded) {
            self.distanceExpanded = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_DISTANCE] withRowAnimation:UITableViewRowAnimationNone];
            
        } else {
            CheckBoxCell *cell = (CheckBoxCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.on = YES;
            [self checkBoxCell:cell didUpdateValue:YES];
        }
    }
    else if (indexPath.section == SECTION_SORT)
    {
        if (!self.sortExpanded) {
            self.sortExpanded = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_SORT] withRowAnimation:UITableViewRowAnimationNone];
            
        } else {
            CheckBoxCell *cell = (CheckBoxCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.on = YES;
            [self checkBoxCell:cell didUpdateValue:YES];
        }
    }
    else if (indexPath.section == SECTION_CATEGORIES) {
        if (!self.categoriesExpanded && indexPath.row == 3) {
            self.categoriesExpanded = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_CATEGORIES] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            SwitchCell *cell = (SwitchCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell toggleOn];
        }
    }

}

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.section == SECTION_DEALS)
    {
        if (value) {
            self.offeringDeal = YES;
        } else {
            self.offeringDeal = NO;
        }
    } else if(indexPath.section == SECTION_CATEGORIES){
        if(value) {
            [self.selectedCategories addObject:self.categories [indexPath.row]];
        } else {
            [self.selectedCategories removeObject:self.categories [indexPath.row]];
        }
    }

}


- (void)checkBoxCell:(CheckBoxCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"indexPath.section = %ld", indexPath.section);
    
    if (indexPath.section == SECTION_DISTANCE)
    {
        if (value) {
            self.selectedDistance = self.distances[indexPath.row];
        
            for (NSInteger row = 0; row < 5; row++) {
                if (row != indexPath.row) {
                    CheckBoxCell *cell = (CheckBoxCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
                    [cell setOn:NO];
                }
            }
            self.distanceExpanded = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_DISTANCE] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            cell.on = YES;
            self.distanceExpanded = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_DISTANCE] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (indexPath.section == SECTION_SORT){
        if (value) {
            self.selectedSortMethod = self.sortMethods[indexPath.row];
            
            for (NSInteger row = 0; row < 3; row++) {
                if (row != indexPath.row) {
                    CheckBoxCell *cell = (CheckBoxCell *)[self.tableView cellForRowAtIndexPath:
                                                          [NSIndexPath indexPathForRow:row inSection:indexPath.section]];
                    [cell setOn:NO];
                }
            }
            
            self.sortExpanded = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_SORT] withRowAnimation:UITableViewRowAnimationNone];
            
        } else {
            self.selectedSortMethod = nil;
        }
    }
}

//新增filter的query string
- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    if (self.offeringDeal)
        [filters setObject:@"true" forKey:@"deals_filter"];
    
    if (self.selectedDistance &&
        ![self.selectedDistance isEqualToDictionary:self.distances[0]])  // don't set filter for "best match"
    {
        [filters setObject:self.selectedDistance[@"value"] forKey:@"radius_filter"];
    }
    
    if (self.selectedSortMethod) {
        [filters setObject:self.selectedSortMethod[@"value"] forKey:@"sort"];
    }
    
    return filters;
}

//cancel button的call back function
- (void)onCancelButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Apply button的call back function
- (void)onApplyButton{
    
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self saveFilters];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)saveFilters {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.offeringDeal forKey:@"filtersOfferingDeal"];
    [defaults setObject:self.selectedDistance forKey:@"filtersSelectedDistance"];
    [defaults setObject:self.selectedSortMethod forKey:@"filtersSelectedSortMethod"];
    
    // NSUserDefaults cannot save CFSet objects
    NSData *selectedCategoriesData = [NSKeyedArchiver archivedDataWithRootObject:self.selectedCategories];
    [defaults setObject:selectedCategoriesData forKey:@"filtersSelectedCategories"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//設定有多少分類
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

//每個分類的標題名稱
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SECTION_DEALS:
            return @"Most Popular";
        case SECTION_DISTANCE:
            return @"Distance";
        case SECTION_SORT:
            return @"Sort By";
        case SECTION_CATEGORIES:
            return @"Categories";
        default:
            return @"";
    }
}

- (void)initArrays {
    self.distances = @[
                       @{@"name" : @"Best Match", @"value" : @""},
                       @{@"name" : @"2 blocks", @"value" : @160},
                       @{@"name" : @"6 blocks", @"value" : @480},
                       @{@"name" : @"1 mile", @"value" : @1609},
                       @{@"name" : @"5 miles", @"value" : @8047}
                       ];
    
    self.sortMethods = @[
                         @{@"name" : @"Best Match", @"value" : @0},
                         @{@"name" : @"Distance", @"value" : @1},
                         @{@"name" : @"Rating", @"value" : @2}
                         ];
}

- (void)initCategories {
    self.categories = @[
                        @{@"name" : @"Afghan", @"code" : @"afghani"},
                        @{@"name" : @"African", @"code" : @"african"},
                        @{@"name" : @"American (New)", @"code" : @"newamerican"},
                        @{@"name" : @"American (Traditional)", @"code" : @"tradamerican"},
                        @{@"name" : @"Arabian", @"code" : @"arabian"},
                        @{@"name" : @"Argentine", @"code" : @"argentine"},
                        @{@"name" : @"Armenian", @"code" : @"armenian"},
                        @{@"name" : @"Asian Fusion", @"code" : @"asianfusion"},
                        @{@"name" : @"Australian", @"code" : @"australian"},
                        @{@"name" : @"Austrian", @"code" : @"austrian"},
                        @{@"name" : @"Bangladeshi", @"code" : @"bangladeshi"},
                        @{@"name" : @"Barbeque", @"code" : @"bbq"},
                        @{@"name" : @"Basque", @"code" : @"basque"},
                        @{@"name" : @"Belgian", @"code" : @"belgian"},
                        @{@"name" : @"Brasseries", @"code" : @"brasseries"},
                        @{@"name" : @"Brazilian", @"code" : @"brazilian"},
                        @{@"name" : @"Breakfast & Brunch", @"code" : @"breakfast_brunch"},
                        @{@"name" : @"British", @"code" : @"british"},
                        @{@"name" : @"Buffets", @"code" : @"buffets"},
                        @{@"name" : @"Burgers", @"code" : @"burgers"},
                        @{@"name" : @"Burmese", @"code" : @"burmese"},
                        @{@"name" : @"Cafes", @"code" : @"cafes"},
                        @{@"name" : @"Cafeteria", @"code" : @"cafeteria"},
                        @{@"name" : @"Cajun/Creole", @"code" : @"cajun"},
                        @{@"name" : @"Cambodian", @"code" : @"cambodian"},
                        @{@"name" : @"Caribbean", @"code" : @"caribbean"},
                        @{@"name" : @"Catalan", @"code" : @"catalan"},
                        @{@"name" : @"Cheesesteaks", @"code" : @"cheesesteaks"},
                        @{@"name" : @"Chicken Wings", @"code" : @"chicken_wings"},
                        @{@"name" : @"Chinese", @"code" : @"chinese"},
                        @{@"name" : @"Comfort Food", @"code" : @"comfortfood"},
                        @{@"name" : @"Creperies", @"code" : @"creperies"},
                        @{@"name" : @"Cuban", @"code" : @"cuban"},
                        @{@"name" : @"Czech", @"code" : @"czech"},
                        @{@"name" : @"Delis", @"code" : @"delis"},
                        @{@"name" : @"Diners", @"code" : @"diners"},
                        @{@"name" : @"Ethiopian", @"code" : @"ethiopian"},
                        @{@"name" : @"Fast Food", @"code" : @"hotdogs"},
                        @{@"name" : @"Filipino", @"code" : @"filipino"},
                        @{@"name" : @"Fish & Chips", @"code" : @"fishnchips"},
                        @{@"name" : @"Fondue", @"code" : @"fondue"},
                        @{@"name" : @"Food Court", @"code" : @"food_court"},
                        @{@"name" : @"Food Stands", @"code" : @"foodstands"},
                        @{@"name" : @"French", @"code" : @"french"},
                        @{@"name" : @"Gastropubs", @"code" : @"gastropubs"},
                        @{@"name" : @"German", @"code" : @"german"},
                        @{@"name" : @"Gluten-Free", @"code" : @"gluten_free"},
                        @{@"name" : @"Greek", @"code" : @"greek"},
                        @{@"name" : @"Halal", @"code" : @"halal"},
                        @{@"name" : @"Hawaiian", @"code" : @"hawaiian"},
                        @{@"name" : @"Himalayan/Nepalese", @"code" : @"himalayan"},
                        @{@"name" : @"Hot Dogs", @"code" : @"hotdog"},
                        @{@"name" : @"Hot Pot", @"code" : @"hotpot"},
                        @{@"name" : @"Hungarian", @"code" : @"hungarian"},
                        @{@"name" : @"Iberian", @"code" : @"iberian"},
                        @{@"name" : @"Indian", @"code" : @"indpak"},
                        @{@"name" : @"Indonesian", @"code" : @"indonesian"},
                        @{@"name" : @"Irish", @"code" : @"irish"},
                        @{@"name" : @"Italian", @"code" : @"italian"},
                        @{@"name" : @"Japanese", @"code" : @"japanese"},
                        @{@"name" : @"Korean", @"code" : @"korean"},
                        @{@"name" : @"Kosher", @"code" : @"kosher"},
                        @{@"name" : @"Laotian", @"code" : @"laotian"},
                        @{@"name" : @"Latin American", @"code" : @"latin"},
                        @{@"name" : @"Live/Raw Food", @"code" : @"raw_food"},
                        @{@"name" : @"Malaysian", @"code" : @"malaysian"},
                        @{@"name" : @"Mediterranean", @"code" : @"mediterranean"},
                        @{@"name" : @"Mexican", @"code" : @"mexican"},
                        @{@"name" : @"Middle Eastern", @"code" : @"mideastern"},
                        @{@"name" : @"Modern European", @"code" : @"modern_european"},
                        @{@"name" : @"Mongolian", @"code" : @"mongolian"},
                        @{@"name" : @"Moroccan", @"code" : @"moroccan"},
                        @{@"name" : @"Pakistani", @"code" : @"pakistani"},
                        @{@"name" : @"Persian/Iranian", @"code" : @"persian"},
                        @{@"name" : @"Peruvian", @"code" : @"peruvian"},
                        @{@"name" : @"Pizza", @"code" : @"pizza"},
                        @{@"name" : @"Polish", @"code" : @"polish"},
                        @{@"name" : @"Portuguese", @"code" : @"portuguese"},
                        @{@"name" : @"Russian", @"code" : @"russian"},
                        @{@"name" : @"Salad", @"code" : @"salad"},
                        @{@"name" : @"Sandwiches", @"code" : @"sandwiches"},
                        @{@"name" : @"Scandinavian", @"code" : @"scandinavian"},
                        @{@"name" : @"Scottish", @"code" : @"scottish"},
                        @{@"name" : @"Seafood", @"code" : @"seafood"},
                        @{@"name" : @"Singaporean", @"code" : @"singaporean"},
                        @{@"name" : @"Slovakian", @"code" : @"slovakian"},
                        @{@"name" : @"Soul Food", @"code" : @"soulfood"},
                        @{@"name" : @"Soup", @"code" : @"soup"},
                        @{@"name" : @"Southern", @"code" : @"southern"},
                        @{@"name" : @"Spanish", @"code" : @"spanish"},
                        @{@"name" : @"Steakhouses", @"code" : @"steak"},
                        @{@"name" : @"Sushi Bars", @"code" : @"sushi"},
                        @{@"name" : @"Taiwanese", @"code" : @"taiwanese"},
                        @{@"name" : @"Tapas Bars", @"code" : @"tapas"},
                        @{@"name" : @"Tapas/Small Plates", @"code" : @"tapasmallplates"},
                        @{@"name" : @"Tex-Mex", @"code" : @"tex-mex"},
                        @{@"name" : @"Thai", @"code" : @"thai"},
                        @{@"name" : @"Turkish", @"code" : @"turkish"},
                        @{@"name" : @"Ukrainian", @"code" : @"ukrainian"},
                        @{@"name" : @"Uzbek", @"code" : @"uzbek"},
                        @{@"name" : @"Vegan", @"code" : @"vegan"},
                        @{@"name" : @"Vegetarian", @"code" : @"vegetarian"},
                        @{@"name" : @"Vietnamese", @"code" : @"vietnamese"}
                        ];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
