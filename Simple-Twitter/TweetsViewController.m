//
//  TweetsViewController.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/7/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "TweetsViewController.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "User.h"
#import "TweetsTableCell.h"
#import "ComposeTweetViewController.h"
#import "TweetsDetailUViewController.h"

@interface TweetsViewController () <ComposeTweetViewControllerDelegate, TweetsDetailDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation TweetsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Compose" style:UIBarButtonItemStylePlain target:self action:@selector(onComposeButton)];
    self.navigationItem.title = @"Tweets";

    // table view
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.delegate = self;
    [self.tweetsTableView registerNib:[UINib nibWithNibName:@"TweetsTableCell" bundle:nil] forCellReuseIdentifier:@"TweetsTableCell"];
    self.tweetsTableView.rowHeight = UITableViewAutomaticDimension;
    
    // pull refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tweetsTableView insertSubview:self.refreshControl atIndex:0];
    
    [[TwitterClient sharedInstance] homeTimeLineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        self.tweetsArray = [[NSMutableArray alloc] initWithArray:tweets];
        [self.tweetsTableView reloadData];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogoutButton {
    [User logout];
}

- (void)onComposeButton {
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onRefresh {
    [[TwitterClient sharedInstance] homeTimeLineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        self.tweetsArray = [[NSMutableArray alloc] initWithArray:tweets];
        [self.tweetsTableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)didPostTweet:(Tweet *)tweet {
    [self.tweetsArray insertObject:tweet atIndex:0];
    [self.tweetsTableView reloadData];
}

- (void)didFavoriteTweet:(Tweet *)tweet {
    [self replaceWithLatestTweet:tweet];
}

- (void)didRetweet:(Tweet *)tweet {
    
}

- (void)replaceWithLatestTweet:(Tweet *)newTweet {
    for (NSUInteger i = 0; i <self.tweetsArray.count; i++) {
        Tweet *tweet = [self.tweetsArray objectAtIndex:i];
        if ([tweet.idStr isEqualToString:newTweet.idStr]) {
            self.tweetsArray[i] = newTweet;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsTableCell"];
    Tweet *tweet = self.tweetsArray[indexPath.row];
    cell.tweet = tweet;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweetsArray[indexPath.row];
    TweetsDetailUViewController *vc = [[TweetsDetailUViewController alloc] init];
    vc.tweet = tweet;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
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
