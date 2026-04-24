//
//  RuleEngine.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>
#import "SandboxRuleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RuleEngine : NSObject
+ (BOOL)matchFile:(NSString *)path rules:(NSArray *)rules;
@end

NS_ASSUME_NONNULL_END
