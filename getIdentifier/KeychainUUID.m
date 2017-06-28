//
//  KeychainUUID.m
//  keychain+uuid
//
//  Created by aayongche on 16/2/25.
//  Copyright © 2016年 程磊. All rights reserved.
//

#import "KeychainUUID.h"
#import <UIKit/UIKit.h>
//导入Keychain依赖库
#import <Security/Security.h>
#import <AdSupport/AdSupport.h>
#define KEY_IN_KEYCHAIN     @"com.chenglei.keychain"

@interface KeychainUUID ()

@property (nonatomic, strong) NSString *uuid;

@end

@implementation KeychainUUID

#pragma mark -获取UUID
#pragma mark 保存UUID到钥匙串

- (void)saveUUID:(NSString *)uuid

{
    [self save:KEY_IN_KEYCHAIN data:uuid];
}

/**

 *此uuid在相同的一个程序里面-相同的vindor-相同的设备下是不会改变的

 *此uuid是唯一的，但应用删除再重新安装后会变化，采取的措施是：只获取一次保存在钥匙串中，之后就从钥匙串中获取

 **/

- (NSString *)getUUID

{
    NSString *deviceID;
    //如果用户在设置-隐私-广告中打开限制广告跟踪，那么IDFA就获取不到了就搞成IDFV
    if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
        deviceID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    } else {
        deviceID = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return deviceID;
}

#pragma mark 读取UUID

/**

 *先从内存中获取uuid，如果没有再从钥匙串中获取，如果还没有就生成一个新的uuid，并保存到钥匙串中供以后使用

 **/

- (id)readUUID

{
    if (_uuid == nil || _uuid.length == 0) {
        NSString *uuidStr = (NSString *)[self load:KEY_IN_KEYCHAIN];
        if (uuidStr == nil || uuidStr.length == 0) {
            uuidStr = [self getUUID];
            [self saveUUID:uuidStr];
        }
        _uuid = uuidStr;
    }
    return _uuid;
}

#pragma mark 删除UUID

- (void)deleteUUID
   
{
    [self delete:KEY_IN_KEYCHAIN];
}

#pragma mark 查询钥匙串

- (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    //大家可能对这么多参数都晕了，那我就简单介绍几个，具体可参考http://blog.sina.com.cn/s/blog_7ea0400d0101fksj.html
    /*
     kSecAttrGeneric  标识符(此属性是可选项，是用户自定义的，格式为CFDataRef)
     kSecClass  是你存数据是什么格式，这里是通用密码格式
     kSecAttrService  存的是什么服务，这个是用来到时候取的时候找到对应的服务存的值（这个属性类似于主键，kSecAttrService、kSecAttrAccount必须要赋一个值）
     kSecAttrAccount  账号，在这里作用与服务没差别（且是否必写与kSecAttrService一样）
     当你有服务或者账号则必须有密码
     kSecAttrAccessible  安全性
     */
    return [NSMutableDictionary dictionaryWithObjectsAndKeys: (__bridge_transfer id)kSecClassGenericPassword, (__bridge_transfer id)kSecClass, service, (__bridge_transfer id)kSecAttrService, service,(__bridge_transfer id)kSecAttrAccount,  (__bridge_transfer id)kSecAttrAccessibleAlways,(__bridge_transfer id)kSecAttrAccessible, nil];

}

#pragma mark 将数据保存到钥匙串

- (void)save:(NSString *)service data:(id)data {
    OSStatus result;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    result = SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
    NSCAssert( result == noErr, @"Couldn't add the Keychain Item." );

}

#pragma mark 更新钥匙串的数据
- (void)update:(NSString *)service data:(id)data {
    OSStatus result;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    NSMutableDictionary *tempCheck = [self getKeychainQuery:service];
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    result = SecItemUpdate((CFDictionaryRef)keychainQuery, (CFDictionaryRef)tempCheck);
    NSCAssert( result == noErr, @"Couldn't update the Keychain Item." );

}

#pragma mark 加载钥匙串中数据

- (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];//是否要返回密码值
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];//限制
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    } else {
        NSLog(@"Couldn't load the Keychain Item.");
    }
    return ret;

}

#pragma mark 删除钥匙串中数据

- (void)delete:(NSString *)service {
    OSStatus result;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    result = SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    NSCAssert( result == noErr, @"Couldn't delete the Keychain Item." );

}


@end
