//
//  LWBackupGetStartedPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWBackupGetStartedPresenter.h"
#import "LWValidator.h"
#import "LWBackupSingleWordPresenter.h"
#import "LWPrivateKeyManager.h"
#import "UIViewController+Navigation.h"
#import "LWKeychainManager.h"
#import "LWAuthNavigationController.h"
#import "UIViewController+Loading.h"
#import "LWWalletMigrationModel.h"

@interface LWBackupGetStartedPresenter () <UIAlertViewDelegate>
{
//    NSString *oldEncodedPrivateKey;
    NSArray *seedWords;
}

@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getStartedWidthConstraint;

@end

@implementation LWBackupGetStartedPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dict=@{NSKernAttributeName:@(1), NSFontAttributeName:[UIFont fontWithName:@"ProximaNova-Semibold" size:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self.getStartedButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"GET STARTED!" attributes:dict] forState:UIControlStateNormal];
    
    [LWValidator setButton:self.getStartedButton enabled:YES];

    if([UIScreen mainScreen].bounds.size.width==320)
        _getStartedWidthConstraint.constant=280;
    
    seedWords=[[LWPrivateKeyManager shared] privateKeyWords];
    if(!seedWords)
        seedWords=[LWPrivateKeyManager generateSeedWords];

    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244.0/255 green:246.0/255 blue:247.0/255 alpha:1];
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
//        [self setCrossCloseButton];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setCrossCloseButton];
    [self setTitle:@"BACK UP"];
//    [self checkPrivateKey];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.getStartedButton.layer.cornerRadius=self.getStartedButton.bounds.size.height/2;
}

-(void) crossCloseButtonPressed
{
    if([super shouldDismissIpadModalViewController]==NO)
        return;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
    {
        UIViewController *firstController=[self.navigationController.viewControllers firstObject];
        if([firstController isKindOfClass:[UITabBarController class]])
            [self.navigationController popToRootViewControllerAnimated:YES];
        else
            [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];

    }
    else
    {
        [super crossCloseButtonPressed];
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)getStartedPressed:(id)sender
{
//    if([self checkPrivateKey]==NO)
//        return;
//    if(![LWKeychainManager instance].login)
//        presenter.wordsList=[LWPrivateKeyManager generateSeedWords];
    LWBackupSingleWordPresenter *presenter=[[LWBackupSingleWordPresenter alloc] init];

    presenter.currentWordNum=0;
    presenter.wordsList=seedWords;
    [self.navigationController pushViewController:presenter animated:YES];
}

//-(BOOL) checkPrivateKey
//{
//    NSArray *words;
//    if([LWPrivateKeyManager shared].privateKeyLykke)
//    {
//        words=[[LWPrivateKeyManager shared] privateKeyWords];
//        if(words==nil)
//        {
//            
//            [self setLoading:YES];
//            oldEncodedPrivateKey=[LWPrivateKeyManager shared].encryptedKeyLykke;
//            LWWalletMigrationModel *model=[[LWWalletMigrationModel alloc] init];
//            model.fromPrivateKey=[[LWPrivateKeyManager shared] wifPrivateKeyLykke];
//            
//            [[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:[LWPrivateKeyManager generateSeedWords]];
//            model.toPrivateKey=[[LWPrivateKeyManager shared] wifPrivateKeyLykke];
//            model.toEncodedPrivateKey=[LWPrivateKeyManager shared].encryptedKeyLykke;
//            model.toPubKey=[[LWPrivateKeyManager shared] publicKeyLykke];
//            [[LWAuthManager instance] requestWalletMigration:model];
//
//            
//            return NO;
//        }
//    }
//    else
//    {
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"You have no private key" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        return NO;
//    }
//    return YES;
//}


//-(void) authManagerDidCompleteWalletMigration:(LWAuthManager *)manager
//{
//    [self setLoading:NO];
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"CONGRATULATIONS" message:@"Your wallets migration has been successfully completed. Now you can proceed with the backup of your private key." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    
//    [alert show];
//}

//-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
//{
//    [self setLoading:NO];
//    [self showReject:reject response:context.task.response];
//    [[LWPrivateKeyManager shared] decryptLykkePrivateKeyAndSave:oldEncodedPrivateKey];
//}




@end
