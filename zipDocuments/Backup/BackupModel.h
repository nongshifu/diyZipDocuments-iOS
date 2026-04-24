//
//  BackupModel.h
//  zipDocuments
//
//  Created by 十三哥 on 2026/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackupModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) long long size;
@end

NS_ASSUME_NONNULL_END
