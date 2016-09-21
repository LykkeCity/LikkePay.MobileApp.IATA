//
//  LWAuthenticationPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthenticationPresenter.h"
#import "LWKYCPendingPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWAuthenticationData.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "LWDeviceInfo.h"
#import "UIViewController+Loading.h"
#import "LWPrivateKeyManager.h"
#import "UIView+Toast.h"
#import "LWCommonButton.h"
#import "LWPINPresenter.h"
#import "LWSMSCodeCheckPresenter.h"

#import "LWCache.h"

#import "LWRestorePasswordWordsPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"


@interface LWAuthenticationPresenter () <UITextFieldDelegate, LWAuthManagerDelegate> {
    CGFloat passwordContainerTopOffsetConstraintOrigin;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet LWCommonButton *loginButton;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *emailHintButton;
@property (weak, nonatomic) IBOutlet UIImageView *passwordInvalidImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenButtonsConstraint;

//@property (strong, nonatomic) NSLayoutConstraint *distanceBetweenButtonsConstraint2;

@property (strong,nonatomic) NSLayoutConstraint *resetPasswordWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *emailHintWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordContainerTopOffsetConstraint;


@end


@implementation LWAuthenticationPresenter 

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    passwordContainerTopOffsetConstraintOrigin=_passwordContainerTopOffsetConstraint.constant;
    
    // init fields
    
    _passwordField.placeholder = Localize(@"auth.password");
    _passwordField.secureTextEntry = YES;
    _passwordField.delegate = self;
    
    self.resetPasswordWidthConstraint=[NSLayoutConstraint constraintWithItem:self.resetPasswordButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.resetPasswordButton addConstraint:self.resetPasswordWidthConstraint];

    self.distanceBetweenButtonsConstraint.constant=0;
    
    self.passwordInvalidImageView.hidden=YES;
    
    self.loginButton.type=BUTTON_TYPE_COLORED;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.loginButton.enabled=[self canProceed:_passwordField.text];
//    [LWValidator setButton:self.loginButton enabled:[self canProceed]];
    
    // load email
    
    // focus first name
    
    self.observeKeyboardEvents=YES;
    
//    if(_userHasHint==NO && !self.emailHintWidthConstraint)
    if(!self.emailHintWidthConstraint)
    {
        self.emailHintWidthConstraint=[NSLayoutConstraint constraintWithItem:self.emailHintButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        [self.emailHintButton addConstraint:self.emailHintWidthConstraint];
    }

    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_passwordField becomeFirstResponder];
    self.title = Localize(@"title.authentication");
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];


//    LWSMSCodeCheckPresenter *pin=[[LWSMSCodeCheckPresenter alloc] init];
//    [self.navigationController pushViewController:pin animated:YES];
//    return;


}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.loginButton.layer.cornerRadius=self.loginButton.bounds.size.height/2;
}


#pragma mark - LWTextFieldDelegate

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    
    NSString *newString=[textField.text stringByReplacingCharactersInRange:range withString:string];
    self.passwordInvalidImageView.hidden=YES;
    self.loginButton.enabled=[self canProceed:newString];
    return YES;
}


//- (void)textFieldDidChangeValue:(LWTextField *)textFieldInput {
//    if (!self.isVisible) { // prevent from being processed if controller is not presented
//        return;
//    }
//    // check button state
//    [LWValidator setButton:self.loginButton enabled:[self canProceed]];
//}


#pragma mark - Private

- (BOOL)canProceed:(NSString *) pass
{
    
    BOOL isValidPassword = [LWValidator validatePassword:pass];
    
    return isValidPassword;
}


#pragma mark - Utils

- (IBAction)loginClicked:(id)sender {
    [self.view endEditing:YES];
    if ([self canProceed:_passwordField.text]) {
        [self setLoading:YES];
        
        LWAuthenticationData *data = [LWAuthenticationData new];
        data.email = self.email;
        data.password = _passwordField.text;
        data.clientInfo = [[LWDeviceInfo instance] clientInfo];
        
        [[LWAuthManager instance] requestAuthentication:data];
    }
}

-(IBAction)restorePasswordClicked:(id)sender
{
    LWRestorePasswordWordsPresenter *presenter=[[LWRestorePasswordWordsPresenter alloc] init];
    presenter.email=self.email;
//    [self.navigationController pushViewController:presenter animated:YES];
    
    
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

-(IBAction)sendHintPressed:(id)sender
{
    [self.view endEditing:YES];
    [self setLoading:YES];
    [[LWAuthManager instance] requestSendHintForEmail:self.email];
    
}

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        _passwordContainerTopOffsetConstraint.constant=22;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        return;
    }

//    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
//    {
//        [super observeKeyboardWillShowNotification:notification];
//        return;
//    }
//    if([UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeRight)
//    {
//        self.scrollView.contentOffset=CGPointMake(0, 80);
//        self.scrollView.scrollEnabled=NO;
//    }as
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.scrollViewBottomConstraint.constant=frame.size.height;

}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        _passwordContainerTopOffsetConstraint.constant=passwordContainerTopOffsetConstraintOrigin;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        return;
    }
    
    
    self.scrollViewBottomConstraint.constant=0;
    
//    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
//    {
//        [super observeKeyboardWillShowNotification:notification];
//        return;
//    }
//    self.scrollView.contentOffset=CGPointMake(0, 0);
//    
//    self.scrollView.contentInset = UIEdgeInsetsZero;
//    self.scrollView.scrollEnabled=YES;
}



#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidAuthenticate:(LWAuthManager *)manager KYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered {
    [self setLoading:NO];
    
    
    
    LWAuthNavigationController *navController = (LWAuthNavigationController *)self.navigationController;
    [navController navigateKYCStatus:status
                          isPinEntered:isPinEntered
                        isAuthentication:YES];
}

-(void) authManagerDidSendEmailHint:(LWAuthManager *)manager
{
    [self setLoading:NO];
    [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];

}




- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
   // [self showReject:reject response:context.task.response];
    
    [self setLoading:NO];
    
    if([reject[@"Code"] intValue]!=2)
    {
        [self showReject:reject response:context.task.response];
        return;
    }
    
    if(_userHasHint)
        _emailHintWidthConstraint.active=NO;
//    if([[NSUserDefaults standardUserDefaults] boolForKey:@"UserHasBackupOfPrivateKey"])
        self.resetPasswordWidthConstraint.active=NO;
    
    if(_userHasHint)// && [[NSUserDefaults standardUserDefaults] boolForKey:@"UserHasBackupOfPrivateKey"])
        self.distanceBetweenButtonsConstraint.constant=25;
    else
        self.distanceBetweenButtonsConstraint.constant=0;
    
    self.passwordInvalidImageView.hidden=NO;
    [self.view layoutSubviews];
}

-(NSString *) nibName
{
    if([UIScreen mainScreen].bounds.size.width==320)
    {
        return @"LWAuthenticationPresenter_iphone5";
    }
    else
        return @"LWAuthenticationPresenter";
}

@end
