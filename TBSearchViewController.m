//
//  TBSearchViewController.m
//  bianbian
//
//  Created by Jarvis on 14-9-18.
//  Copyright (c) 2014年 com.thongbin. All rights reserved.
//

#import "TBSearchViewController.h"
#import "TBSearchResultMultipleViewController.h"
#import "TBSearchResultSingleViewController.h"

@interface TBSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{   
    IBOutlet UISearchBar *_searchBar;
    NSString *_searchText;
    NSMutableArray *_searchTipArray;
    NSMutableArray *_searchRecordArray;
    NSUserDefaults *_userDefault;
    UITableView *_recordTableView;
}


@end

@implementation TBSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _userDefault = [NSUserDefaults standardUserDefaults];
    _searchRecordArray = [_userDefault objectForKey:kSearchRecordStoreKey];
    if (!_searchRecordArray) {
        _searchRecordArray = [NSMutableArray array];
    }
    
    _recordTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _recordTableView.delegate = self;
    _recordTableView.dataSource = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchBar becomeFirstResponder];
}

#pragma mark - UITableViewDelegate & dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _recordTableView) {
        if([_searchRecordArray count] == 0){
            return 1;
        }
        return [_searchRecordArray count] + 1;
    }
    return [_searchTipArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _recordTableView) {
        if([_searchRecordArray count] == 0){
            return 0.0;
        }
    }
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _recordTableView) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        if([_searchRecordArray count] != 0 && indexPath.row != [_searchRecordArray count]){
            cell.textLabel.text = [_searchRecordArray objectAtIndex:indexPath.row];
        }else if (indexPath.row == [_searchRecordArray count])
        {
            UIButton *clearSearchRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
            clearSearchRecordButton.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
            [clearSearchRecordButton.layer setBackgroundColor:[UIColor colorWithRed:0.23 green:0.62 blue:1 alpha:1].CGColor];
            [clearSearchRecordButton setTitle:@"清除搜索记录" forState:UIControlStateNormal];
            [clearSearchRecordButton.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [clearSearchRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [clearSearchRecordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [clearSearchRecordButton addTarget:self action:@selector(clearRecordBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            if ([_searchRecordArray count] == 0) {
                [clearSearchRecordButton setTitle:@"没有搜索记录" forState:UIControlStateNormal];
                [clearSearchRecordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [clearSearchRecordButton.layer setBackgroundColor:[UIColor whiteColor].CGColor];
            }
            [cell.contentView addSubview:clearSearchRecordButton];
        }
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [_searchTipArray objectAtIndex:indexPath.row];
    return cell;

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == _recordTableView) {
        return @"搜索历史";
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *text = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    _searchRecordArray = [_userDefault objectForKey:kSearchRecordStoreKey];
    _searchRecordArray = [NSMutableArray arrayWithArray:_searchRecordArray];
    [_searchRecordArray removeObject:text];
    [_searchRecordArray addObject:text];
    [_userDefault setObject:_searchRecordArray forKey:kSearchRecordStoreKey];
    
    TBSearchResultMultipleViewController *vc = [TBBaseViewController viewControllerByIdentifier:@"searchResultMultipleViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}

#pragma clearRecordBtnDidClicked
-(void)clearRecordBtnDidClicked:(id)sender
{
    [_userDefault removeObjectForKey:kSearchRecordStoreKey];
    [_searchRecordArray removeAllObjects];
    [_recordTableView reloadData];
}

#pragma mark -UISearchBar & UISerchDisplayController Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchRecordArray removeObject:_searchText];
    [_searchRecordArray addObject:_searchText];
    [_userDefault setObject:_searchRecordArray forKey:kSearchRecordStoreKey];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [controller.searchContentsController.view addSubview:_recordTableView];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchText = searchText;
    if ([searchText length] > 0 ) {
        [_recordTableView removeFromSuperview];
        #warning 请求搜索补全
        
    }else{
        [_recordTableView reloadData];
        [self.searchDisplayController.searchContentsController.view addSubview:_recordTableView];
    }
    
}
@end
