//
//  LWHistoryPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 19.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWHistoryPresenter.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"

@implementation LWHistoryPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"tab.history");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = Localize(@"tab.history");

    if (self.shouldGoBack) {
        [self setBackButton];
    }
    
    if (self.tabBarController && self.navigationItem) {
        self.tabBarController.title = [self.navigationItem.title uppercaseString];
    }
    
    [self setLoading:YES];
    [[LWAuthManager instance] requestTransactions:self.assetId];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"tab.history");

}

@end
