//
//  SandboxKit.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#ifndef SandboxKit_h
#define SandboxKit_h

#import <UIKit/UIKit.h>
#import "SandboxMenuView.h"
#import "BackupManager.h"
#import "RuleManager.h"
#import "SandboxCleaner.h"
#import "SVProgressHUD.h"
#import "TopGestureManager.h"

__attribute__((constructor)) void SandboxKitInit(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[TopGestureManager sharedManager] startMonitor];
        
    });
}

#endif /* SandboxKit_h */
