# keychain-uuid
根据第三方openudid修改

其中ViewController中为实例代码，KeychainItemWrapper.h与.m为苹果Demo，这里只是为了存取唯一值且公司只有一个应用，暂不涉及到同一Vender(com.xxxx)也就是一个公司两款app相互之间都能获取同一id。故在KeychainItemWrapper实例的时候，请将    - (id)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup;中accessGroup置为nil。至于初始化后插入数据失败问题，请看ViewController中注释。
谢谢。

