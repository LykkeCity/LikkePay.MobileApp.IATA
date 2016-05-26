//
//  LWTradingWalletPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 27.03.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWTradingWalletPresenter.h"
#import "LWBitcoinDepositPresenter.h"
#import "LWWithdrawFundsPresenter.h"
#import "TKButton.h"
#import "UIViewController+Navigation.h"
#import "UIViewController+Loading.h"
#import "LWCurrencyDepositPresenter.h"
#import "LWCache.h"
#import "LWWithdrawInputPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"


@interface LWTradingWalletPresenter () {
    
}

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet TKButton *withdrawButton;
@property (weak, nonatomic) IBOutlet TKButton *depositButton;

@end


@implementation LWTradingWalletPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = Localize(@"wallets.trading.title");
    [self.withdrawButton setTitle:Localize(@"wallets.trading.withdraw") forState:UIControlStateNormal];
    [self.depositButton setTitle:Localize(@"wallets.trading.deposit") forState:UIControlStateNormal];
    
#ifdef PROJECT_IATA
#else
    [self.withdrawButton setGrayPalette];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setBackButton];
    
    if ([self isMovingToParentViewController]) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestTransactions:self.assetId];
    }
    
    if([LWCache isAssetDepositAvailableForAssetID:self.assetId]==NO)
    {
        self.depositButton.hidden=YES;
        self.withdrawButton.hidden=YES;
    }
}

#pragma mark - Actions

- (IBAction)withdrawClicked:(id)sender {
    
    LWWithdrawFundsPresenter *presenter;
    
    if([self.assetId isEqualToString:@"BTC"] || [self.assetId isEqualToString:@"LKK"])
    {
        presenter = [LWWithdrawFundsPresenter new];
        presenter.assetId = self.assetId;
        presenter.assetSymbol=self.currencySymbol;
        
    }
    else
    {
        presenter=[LWWithdrawInputPresenter new];
        presenter.assetId=self.assetId;
        presenter.assetSymbol=self.currencySymbol;
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
    }

    
    
    
}

- (IBAction)depositClicked:(id)sender {
    
    NSDictionary *depositTypes=@{@"EUR":@"currency",
                                 @"USD":@"currency",
                                 @"CHF":@"currency",
                                 @"GBP":@"currency",
                                 @"BTC":@"bitcoin",
                                 @"LKK":@"bitcoin"};
    
    
    UIViewController *presenter;
    
    if([depositTypes[self.assetId] isEqualToString:@"bitcoin"])
    {
        presenter = [LWBitcoinDepositPresenter new];
    }
    else
    {
        presenter=[LWCurrencyDepositPresenter new];
    }
    
    ((LWCurrencyDepositPresenter *)presenter).assetName=self.assetName;
    ((LWCurrencyDepositPresenter *)presenter).issuerId=self.issuerId;
    ((LWCurrencyDepositPresenter *)presenter).assetID=self.assetId;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }

    
}


@end
