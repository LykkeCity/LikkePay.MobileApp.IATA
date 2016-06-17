//
//  LWAuthValidationPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 21.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthValidationPresenter.h"
#import "LWRegisterCameraPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWAuthManager.h"
#import "LWPersonalData.h"
#import "UIViewController+Loading.h"
#import "LWCache.h"
#import "LWProgressView.h"


@interface LWAuthValidationPresenter () {
    
}

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet LWProgressView *activity;

@end


@implementation LWAuthValidationPresenter


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.activity startAnimating];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[LWAuthManager instance] requestRegistrationGet];
    
    self.versionLabel.text=[LWCache currentAppVersion];
}



- (LWAuthStep)stepId {
    return LWAuthStepValidation;
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#endif

- (void)localize {
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.validation.label")];
}



#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidRegisterGet:(LWAuthManager *)manager KYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered personalData:(LWPersonalData *)personalData {

    LWAuthNavigationController *navController = (LWAuthNavigationController *)self.navigationController;
    
    if ([status isEqualToString:@"NeedToFillData"] && isPinEntered==NO) {
        // request documents to upload
        self.textLabel.text = [NSString stringWithFormat:Localize(@"register.check.documents.label")];
        
        BOOL const isFullNameEmpty = personalData.fullName == nil || [personalData.fullName isKindOfClass:[NSNull class]] || [personalData.fullName isEqualToString:@""];
        BOOL const isPhoneEmpty = personalData.phone == nil || [personalData.phone isKindOfClass:[NSNull class]] ||[personalData.phone isEqualToString:@""];
        
        if (isFullNameEmpty) {
            [self setLoading:NO];
            LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
            [navigation navigateToStep:LWAuthStepRegisterFullName
                      preparationBlock:^(LWAuthStepPresenter *presenter) {
                      }];
        }
        else if (isPhoneEmpty) {
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
    else {
        [navController navigateKYCStatus:@"Ok"
                            isPinEntered:isPinEntered
                        isAuthentication:YES];
    }
}

- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status {
    [((LWAuthNavigationController *)self.navigationController) navigateWithDocumentStatus:status hideBackButton:YES];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    
    [((LWAuthNavigationController *)self.navigationController) logout];
}

@end
