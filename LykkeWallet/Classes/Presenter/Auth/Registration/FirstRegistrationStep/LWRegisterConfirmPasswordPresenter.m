//
//  LWRegisterConfirmPasswordPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterConfirmPasswordPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWRegisterCameraPresenter.h"

#import "LWPersonalDataModel.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "UIViewController+Loading.h"


@interface LWRegisterConfirmPasswordPresenter () <LWAuthManagerDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end


@implementation LWRegisterConfirmPasswordPresenter


#pragma mark - LWRegisterBasePresenter

- (void)proceedToNextStep {
    [self setLoading:YES];

    [[LWAuthManager instance] requestRegistration:self.registrationInfo];
}

- (NSString *)fieldPlaceholder {
    return Localize(@"register.passwordConfirm");
}

- (BOOL)validateInput:(NSString *)input {
    return ([LWValidator validateConfirmPassword:input]
            && [self.registrationInfo.password isEqualToString:input]);
}

- (void)configureTextField:(LWTextField *)textField {
    textField.secure = YES;
}

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    
    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    
        self.scrollView.contentOffset=CGPointMake(0, 120);
        self.scrollView.scrollEnabled=NO;
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    self.scrollView.contentOffset=CGPointMake(0, 0);
    
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollEnabled=YES;
}



#pragma mark - LWAuthStepPresenter

//- (LWAuthStep)stepId {
//    return LWAuthStepRegisterConfirmPassword;
//}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidRegister:(LWAuthManager *)manager {
    [[LWAuthManager instance] requestPersonalData];
}

- (void)authManager:(LWAuthManager *)manager didReceivePersonalData:(LWPersonalDataModel *)data {
    if ([data isFullNameEmpty]) {
        [self setLoading:NO];
        LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
        [navigation navigateToStep:LWAuthStepRegisterFullName
                  preparationBlock:^(LWAuthStepPresenter *presenter) {
                  }];
    }
    else if ([data isPhoneEmpty]) {
        [self setLoading:NO];
        LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
        [navigation navigateToStep:LWAuthStepRegisterPhone
                  preparationBlock:^(LWAuthStepPresenter *presenter) {
                  }];
    }
    else {
        [[LWAuthManager instance] requestDocumentsToUpload];
    }
}

- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status {
    [self setLoading:NO];
    
    LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
    [navigation navigateWithDocumentStatus:status hideBackButton:YES];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response];
}

@end
