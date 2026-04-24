//
//  AddRuleVC.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <UIKit/UIKit.h>
#import "SandboxRuleModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^AddRuleCompletion)(SandboxRuleModel *model);

@interface AddRuleViewController : UIViewController
@property (nonatomic, strong) SandboxRuleModel *editModel;
@property (nonatomic, copy) AddRuleCompletion completion;
@end

NS_ASSUME_NONNULL_END
