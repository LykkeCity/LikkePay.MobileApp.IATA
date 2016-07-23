//
//  LWRegisterHintPresenter.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 26.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRegisterHintPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWRegisterCameraPresenter.h"
#import "LWPersonalDataModel.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "UIViewController+Loading.h"
#import "LWPrivateKeyManager.h"


@interface LWRegisterHintPresenter () <LWAuthManagerDelegate> {
    LWTextField *hintTextField;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end


@implementation LWRegisterHintPresenter


#pragma mark - LWRegisterBasePresenter

- (void)proceedToNextStep {
    [self setLoading:YES];
    self.registrationInfo.passwordHint=hintTextField.text;
    [[LWAuthManager instance] requestRegistration:self.registrationInfo];
}

- (NSString *)fieldPlaceholder {
    return @"Hint for your password";
}

- (BOOL)validateInput:(NSString *)input {
    
    return input.length>0;
//    return ([LWValidator validateConfirmPassword:input]
//            && [self.registrationInfo.password isEqualToString:input]);
}

- (void)configureTextField:(LWTextField *)textField {
    textField.secure = NO;
    hintTextField=textField;
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
    [[LWPrivateKeyManager shared] generatePrivateKey];
    [[LWAuthManager instance] requestSaveClientKeysWithPubKey:[LWPrivateKeyManager shared].publicKeyLykke encodedPrivateKey:[LWPrivateKeyManager shared].encryptedKeyLykke];

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
