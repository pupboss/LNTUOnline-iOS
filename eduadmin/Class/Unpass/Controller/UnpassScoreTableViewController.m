//
//  UnpassScoreTableViewController.m
//  eduadmin
//
//  Created by JieLee on 14/12/31.
//  Copyright (c) 2014年 PUPBOSS. All rights reserved.
//

#import "UnpassScoreTableViewController.h"
#import "MBProgressHUD+LJ.h"
#import "LJTools.h"
#import "Common.h"
#import "DetailGradeController.h"
#import "UnpassGrade.h"
#import "MJExtension.h"
#import "PartGradeCell.h"

@interface UnpassScoreTableViewController ()
{
    NSArray *_gradeArr;
}
@end

@implementation UnpassScoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showMessage:waitStr];
    
    self.averageOfCreditPointInfo.numberOfLines = 0;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getAverageOfCreditPointInfo];
    [self getUnpassCoursesInfo];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _gradeArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PartGradeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"part"];
    
    if (cell == nil) {
        cell = [PartGradeCell newPartGradeCell];
    }
    
    cell.unPassGrade = _gradeArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = @[_gradeArr[indexPath.row],@"1"];
    
    [self performSegueWithIdentifier:@"unpass2detail" sender:arr];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailGradeController *con = segue.destinationViewController;
    con.arr = sender;
}

- (void)getAverageOfCreditPointInfo
{
    [LJHTTPTool getHTTPWithURL:[NSString stringWithFormat:@"%@grades/averageOfCreditPointInfo",sinaURL] params:nil success:^(id responseHTTP) {
        
        NSString *response = [[NSString alloc] initWithData:responseHTTP encoding:NSUTF8StringEncoding];
        
        //用回车隔开
        NSArray *result = [response componentsSeparatedByString:@"\n"];
        self.averageOfCreditPointInfo.text = result[1];
    } failure:^(NSError *error) {
        self.averageOfCreditPointInfo.text = errorStr;
    }];
}

- (void)getUnpassCoursesInfo
{
    [LJHTTPTool getJSONWithURL:[NSString stringWithFormat:@"%@grades/unpassCoursesInfo",sinaURL] params:nil success:^(id responseJSON) {
        
        _gradeArr = [UnpassGrade objectArrayWithKeyValuesArray:responseJSON];
        [self.tableView reloadData];
        [MBProgressHUD hideHUD];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"居然无挂科，你超神了！"];
    }];
}

@end