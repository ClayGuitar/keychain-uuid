//
//  ViewController.m
//  getIdentifier
//
//  Created by aayongche on 16/2/22.
//  Copyright © 2016年 程磊. All rights reserved.
//

#import "ViewController.h"
//导入Keychain依赖库
#import <Security/Security.h>
#define KEY_UUID            @"KEY_UUID"

#define KEY_IN_KEYCHAIN     @"KEY_IN_KEYCHAIN"

@interface ViewController ()

@property (nonatomic, strong) NSString *uuid;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self delete:KEY_IN_KEYCHAIN];
    id data = [self load:KEY_IN_KEYCHAIN];
    if (data == nil) {
        [self saveUDID:[self getUUID]];
    }
    id data2 = [self load:KEY_IN_KEYCHAIN];
    NSLog(@"data = %@",data2);
}

#pragma mark -获取UUID
/**
 
 *此uuid在相同的一个程序里面-相同的vindor-相同的设备下是不会改变的
 
 *此uuid是唯一的，但应用删除再重新安装后会变化，采取的措施是：只获取一次保存在钥匙串中，之后就从钥匙串中获取
 
 **/

- (NSString *)getUUID

{
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    return identifierForVendor;
}

#pragma mark 保存UUID到钥匙串

- (void)saveUDID:(NSString *)udid

{
    NSMutableDictionary *udidKVPairs = [NSMutableDictionary dictionary];
    [udidKVPairs setObject:udid forKey:KEY_UUID];
    [self save:KEY_IN_KEYCHAIN data:udidKVPairs];
}

#pragma mark 读取UUID

/**
 
 *先从内存中获取uuid，如果没有再从钥匙串中获取，如果还没有就生成一个新的uuid，并保存到钥匙串中供以后使用
 
 **/

- (id)readUDID

{
    if (_uuid == nil || _uuid.length == 0) {
        NSMutableDictionary *udidKVPairs = (NSMutableDictionary *)[self load:KEY_IN_KEYCHAIN];
        NSString *uuid = [udidKVPairs objectForKey:KEY_UUID];
        if (uuid == nil || uuid.length == 0) {
            uuid = [self getUUID];
            [self saveUDID:uuid];
        }
        _uuid = uuid;
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
    //大家可能对这么多参数都晕了，那我就给你们一一介绍，
    /*
     kSecAttrGeneric  标识符
     kSecClass  是你存数据是什么格式，这里是通用密码格式
     kSecAttrService  存的是什么服务，这个是用来到时候取的时候找到对应的服务存的值
     kSecAttrAccount  账号，在这里作用与服务没差别
     */
    return [NSMutableDictionary dictionaryWithObjectsAndKeys: (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass, service, (__bridge_transfer id)kSecAttrService, service,(__bridge_transfer id)kSecAttrAccount,  (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible, nil];
    
}

#pragma mark 将数据保存到钥匙串

- (void)save:(NSString *)service data:(id)data {
    OSStatus result;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    result = SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
    NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
    
}

#pragma mark 更新钥匙串的数据
- (void)update:(NSString *)service data:(id)data {
    OSStatus result;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    NSMutableDictionary *tempCheck = [self getKeychainQuery:service];
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    result = SecItemUpdate((CFDictionaryRef)keychainQuery, (CFDictionaryRef)tempCheck);
    NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
    
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
            NSLog(@"keyData = %@",keyData);
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
            NSLog(@"ret = %@",ret);
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    } else {
        NSLog(@"出错了");
    }
    return ret;
    
}

#pragma mark 删除钥匙串中数据

- (void)delete:(NSString *)service {
    OSStatus result;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    result = SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    NSAssert( result == noErr, @"Couldn't delete the Keychain Item." );
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
