//
//  ScheduleViewController.m
//  eduadmin
//
//  Created by Li Jie on 14/12/31.
//  Copyright (c) 2014年 PUPBOSS. All rights reserved.
//

#import "ScheduleViewController.h"
#import "MBProgressHUD+LJ.h"
#import "LJTools.h"
#import "Common.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "iCarousel.h"
#import "DayClassTableViewCell.h"
#import "NightClassTableViewCell.h"
#import "DayCourse.h"
#import "OldClassTableView.h"
#import "Course.h"
#import "TimeAndPlace.h"

@interface ScheduleViewController () <iCarouselDataSource, iCarouselDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, OldClassTableDelegate>

@property (nonatomic, strong) iCarousel *iCaView;
@property (nonatomic, strong) OldClassTableView *oldView;
@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, copy) NSArray *courseArray;
@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic, strong) NSUserDefaults *deft;
@property (nonatomic, assign) NSInteger currentWeek;

@end

@implementation ScheduleViewController

- (void)dealloc {
    
    self.iCaView.delegate = nil;
    self.iCaView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.deft = [NSUserDefaults standardUserDefaults];
    
    if (![self.deft objectForKey:CLASSTABLEMODE]) {
        
        [self createNewClassView];
        
    } else {
        
        [self createOldClassView];
    }
    
    if (![self.deft objectForKey:KNOWOLDCLASSTABLE]) {
        
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"小 tips" message:@"点击右上角按钮可以按周查看课表" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        
        [view show];
    }
}

/**
 *  新版课表
 */
- (void)createNewClassView {
    
    NSString *filePath = [LJFileTool getFilePath:scheduleFileName];
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    if ([mgr fileExistsAtPath:filePath]) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        [self setCourseArrayForNewVersion:dict];
        
    } else {
        
        [self refreshData];
    }
    
    CGRect newFrame = self.view.frame;
    
    newFrame.origin.y += 64;
    newFrame.size.height -= 64;
    
    self.iCaView = [[iCarousel alloc] initWithFrame:newFrame];
    
    self.iCaView.delegate = self;
    self.iCaView.dataSource = self;
    self.iCaView.type = iCarouselTypeRotary;
    self.iCaView.pagingEnabled = YES;
    self.iCaView.backgroundColor = [UIColor clearColor];
    
    self.iCaView.currentItemIndex = [LJTimeTool getCurrentWeekDay] - 1;
    
    [self.view addSubview:self.iCaView];
    
    self.titleArray = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
}


/**
 *  旧版课表
 */
- (void)createOldClassView {
    
    OldClassTableView *oldClassTable = [OldClassTableView newOldClassTable];
    
    NSString *filePath = [LJFileTool getFilePath:scheduleFileName];
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    if ([mgr fileExistsAtPath:filePath]) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];

        self.dict = @{@"courses": [self getCourseGeneralDict:dict]};
        
    } else {
        
        [self refreshData];
    }
    
    oldClassTable.dict = self.dict;
    
    CGRect newFrame = self.view.frame;
    
    newFrame.origin.y += 64;
    newFrame.size.height -= 64;
    
    oldClassTable.frame = newFrame;
    
    self.oldView = oldClassTable;
    self.oldView.delegate = self;
    
    [self.view addSubview:oldClassTable];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.iCaView = nil;
    self.oldView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (void)setCourseArrayForNewVersion:(NSDictionary *)dict {

    NSDictionary *courses = [self getCourseGeneralDict:dict];
    
    NSArray *arr0 = @[courses[@"7-1"], courses[@"7-2"], courses[@"7-3"], courses[@"7-4"], courses[@"7-5"]];
    NSArray *arr1 = @[courses[@"1-1"], courses[@"1-2"], courses[@"1-3"], courses[@"1-4"], courses[@"1-5"]];
    NSArray *arr2 = @[courses[@"2-1"], courses[@"2-2"], courses[@"2-3"], courses[@"2-4"], courses[@"2-5"]];
    NSArray *arr3 = @[courses[@"3-1"], courses[@"3-2"], courses[@"3-3"], courses[@"3-4"], courses[@"3-5"]];
    NSArray *arr4 = @[courses[@"4-1"], courses[@"4-2"], courses[@"4-3"], courses[@"4-4"], courses[@"4-5"]];
    NSArray *arr5 = @[courses[@"5-1"], courses[@"5-2"], courses[@"5-3"], courses[@"5-4"], courses[@"5-5"]];
    NSArray *arr6 = @[courses[@"6-1"], courses[@"6-2"], courses[@"6-3"], courses[@"6-4"], courses[@"6-5"]];
    
    self.courseArray = @[arr0, arr1, arr2, arr3, arr4, arr5, arr6];
}

- (NSDictionary *)getCourseGeneralDict:(NSDictionary *)dict {
    
    NSString *fullDate = dict[@"firstWeekMondayAt"];
    NSArray *arr = [fullDate componentsSeparatedByString:@"T"];

    self.currentWeek = [LJTimeTool weeksWithDateFormat_yyyy_MM_ddFromDate:arr[0]];
    self.navigationItem.title = [NSString stringWithFormat:@"第%ld周", (long)self.currentWeek];
    
    NSArray *courceArr = [Course mj_objectArrayWithKeyValuesArray:dict[@"courses"]];
    
    NSDictionary *tempDict = @{@"1-1": @"",
                                @"1-2": @"",
                                @"1-3": @"",
                                @"1-4": @"",
                                @"1-5": @"",
                                @"2-1": @"",
                                @"2-2": @"",
                                @"2-3": @"",
                                @"2-4": @"",
                                @"2-5": @"",
                                @"3-1": @"",
                                @"3-2": @"",
                                @"3-3": @"",
                                @"3-4": @"",
                                @"3-5": @"",
                                @"4-1": @"",
                                @"4-2": @"",
                                @"4-3": @"",
                                @"4-4": @"",
                                @"4-5": @"",
                                @"5-1": @"",
                                @"5-2": @"",
                                @"5-3": @"",
                                @"5-4": @"",
                                @"5-5": @"",
                                @"6-1": @"",
                                @"6-2": @"",
                                @"6-3": @"",
                                @"6-4": @"",
                                @"6-5": @"",
                                @"7-1": @"",
                                @"7-2": @"",
                                @"7-3": @"",
                                @"7-4": @"",
                                @"7-5": @""
                                };
    
    NSMutableDictionary *oldFormat = [NSMutableDictionary dictionaryWithDictionary:tempDict];
    
    for (Course *cource in courceArr) {
        
        NSString *name = cource.name;
        NSString *tea = cource.teacher;
        
        if (cource.timesAndPlaces.count) {
            
            for (TimeAndPlace *tp in cource.timesAndPlaces) {
                
                if (self.currentWeek <= tp.endWeek) {
                    
                    NSString *key = [NSString stringWithFormat:@"%@-%@", [self getCountByWeekday:tp.dayInWeek], tp.stage];
                    NSString *weeks = @"";
                    
                    if ([tp.weekMode isEqualToString:@"ALL"]) {
                        
                        weeks = [NSString stringWithFormat:@"%d-%d", (int)tp.startWeek, (int)tp.endWeek];
                        
                    } else if ([tp.weekMode isEqualToString:@"ODD"]) {
                        
                        weeks = [NSString stringWithFormat:@"%d-%d(单)", (int)tp.startWeek, (int)tp.endWeek];
                        
                    } else {
                        
                        weeks = [NSString stringWithFormat:@"%d-%d(双)", (int)tp.startWeek, (int)tp.endWeek];
                    }
                    
                    NSString *value = @"";
                    
                    if (self.currentWeek < tp.startWeek) {
                        
                        value = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n未开课", name, weeks, tea, tp.room];
                        
                    } else {
                        
                        value = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", name, weeks, tea, tp.room];
                    }
                    
                    if ([oldFormat[key] length] > 10) {
                        
                        NSString *newStr = [NSString stringWithFormat:@"%@\n%@", oldFormat[key], value];
                        [oldFormat setValue:newStr forKey:key];
                        
                    } else {
                        
                        [oldFormat setValue:value forKey:key];
                    }
                }
            }
        }
    }

    return [NSDictionary dictionaryWithDictionary:oldFormat];
}

- (void)refreshData {
    
    NSInteger year = [LJTimeTool getCurrentYear];
    NSString *tm = @"";
    if ([LJTimeTool getCurrentMonth]>=2 && [LJTimeTool getCurrentMonth]<9) {
        
        tm = @"春";
        
    } else {
        
        year--;
        tm = @"秋";
    }
    
    NSDictionary *dict = @{@"year": @(year), @"term": tm};
    [LJHTTPTool getJSONWithURL:[NSString stringWithFormat:@"%@class-table/~self", MAINURL] params:dict success:^(id responseJSON) {
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:responseJSON];
        [LJFileTool writeToFileContent:dictionary withFileName:scheduleFileName];
        
        [self setCourseArrayForNewVersion:dictionary];
        [self.iCaView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


- (NSString *)getCountByWeekday:(NSString *)weekday {
    
    if ([weekday isEqualToString:@"Monday"]) {
        
        return @"1";
    }
    if ([weekday isEqualToString:@"Tuesday"]) {
        
        return @"2";
    }
    if ([weekday isEqualToString:@"Wednesday"]) {
        
        return @"3";
    }
    if ([weekday isEqualToString:@"Thursday"]) {
        
        return @"4";
    }
    if ([weekday isEqualToString:@"Friday"]) {
        
        return @"5";
    }
    if ([weekday isEqualToString:@"Saturday"]) {
        
        return @"6";
    }
    if ([weekday isEqualToString:@"Sunday"]) {
        
        return @"7";
        
    } else {
        
        return @"8";
    }
}

- (IBAction)reloadCourse:(id)sender {
    
    [self animationWithView:self.view WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
    
    if (![self.deft objectForKey:CLASSTABLEMODE]) {
        
        [self.iCaView removeFromSuperview];
        [self createOldClassView];
        [self.deft setObject:@"1" forKey:CLASSTABLEMODE];
        
    } else {
        
        [self.oldView removeFromSuperview];
        [self createNewClassView];
        
        [self.deft setObject:nil forKey:CLASSTABLEMODE];
    }
    
    [self.deft synchronize];
}

#pragma UIView实现动画
- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition {
    
    [UIView animateWithDuration:0.7f animations:^{
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    
    return 7;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    
    NSInteger HEIGHT = [UIScreen mainScreen].bounds.size.height - 40 - 64;
    NSInteger WIDTH = [UIScreen mainScreen].bounds.size.width - 30;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStylePlain];
    
    tableView.tag = index;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.allowsSelection = NO;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.alwaysBounceVertical = NO;
    tableView.backgroundColor = [UIColor colorWithRed:214/255.0 green:227/255.0 blue:181/255.0 alpha:1];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"head"];
    [tableView registerNib:[UINib nibWithNibName:@"DayClassTableViewCell" bundle:nil] forCellReuseIdentifier:@"day"];
    [tableView registerNib:[UINib nibWithNibName:@"NightClassTableViewCell" bundle:nil] forCellReuseIdentifier:@"night"];
    
    return tableView;
}

#pragma mark Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"head" forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = self.titleArray[tableView.tag];
        return cell;
    }
    if (indexPath.row == 1) {
        
        DayClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"day" forIndexPath:indexPath];
        
        cell.course0 = self.courseArray[tableView.tag][0];
        cell.course1 = self.courseArray[tableView.tag][1];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_morning"]];
        return  cell;
    }
    if (indexPath.row == 2) {
        
        DayClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"day" forIndexPath:indexPath];
        
        DayCourse *course = [DayCourse new];
        course.class0 = self.courseArray[tableView.tag][2];
        course.class1 = self.courseArray[tableView.tag][3];
        
        cell.course = course;
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_afternoon"]];
        return  cell;
        
    } else {
        
        NightClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"night" forIndexPath:indexPath];
        
        cell.course = self.courseArray[tableView.tag][4];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_night"]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        return 44;
    }
    if (indexPath.row == 1) {
        
        NSString *a = self.courseArray[tableView.tag][0];
        NSString *b = self.courseArray[tableView.tag][1];
        
        NSInteger first = [a componentsSeparatedByString:@"\n"].count;
        NSInteger second = [b componentsSeparatedByString:@"\n"].count;
        
        NSInteger time1 = (first / 4 - 1) > 0 ? (first / 4 - 1) : 0;
        NSInteger time2 = (second / 4 - 1) > 0 ? (second / 4 - 1) : 0;
        
        return 212 + (time1 + time2) * 106;
        
    }
    if (indexPath.row == 2) {
        
        NSString *a = self.courseArray[tableView.tag][2];
        NSString *b = self.courseArray[tableView.tag][3];
        
        NSInteger first = [a componentsSeparatedByString:@"\n"].count;
        NSInteger second = [b componentsSeparatedByString:@"\n"].count;
        
        NSInteger time1 = (first / 4 - 1) > 0 ? (first / 4 - 1) : 0;
        NSInteger time2 = (second / 4 - 1) > 0 ? (second / 4 - 1) : 0;
        
        return 212 + (time1 + time2) * 106;
        
    } else {
        
        NSString *a = self.courseArray[tableView.tag][4];
        
        NSInteger first = [a componentsSeparatedByString:@"\n"].count;
        
        NSInteger time1 = (first / 4 - 1) > 0 ? (first / 4 - 1) : 0;
        
        return 106 + time1 * 106;
    }
}

- (void)updateData:(NSDictionary *)dict {
    
    self.oldView.dict = @{@"courses": [self getCourseGeneralDict:dict]};
}

#pragma AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [self.deft setObject:@"1" forKey:KNOWOLDCLASSTABLE];
    }
}

@end
