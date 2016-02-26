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
#import "KeychainUUID.h"
#import "KeychainItemWrapper.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *uuid;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    KeychainItemWrapper *itemWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.chenglei" accessGroup:nil];
//    [itemWrapper setObject:@"chengleitext" forKey:(__bridge_transfer id)kSecAttrService];
//    [itemWrapper setObject:@"chengleitext" forKey:(__bridge_transfer id)kSecAttrAccount];
//    [itemWrapper setObject:[self getUUID] forKey:(__bridge_transfer id)kSecValueData];
    
//    [self delete:KEY_IN_KEYCHAIN];
    
    fsdfdsfds 
    
    
    KeychainUUID *keychain = [[KeychainUUID alloc] init];
    id data = [keychain readUDID];
    NSLog(@"data = %@",data);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
