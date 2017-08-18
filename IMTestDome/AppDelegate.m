//
//  AppDelegate.m
//  IMTestDome
//
//  Created by 科技部2 on 2017/8/10.
//  Copyright © 2017年 Ken. All rights reserved.
//

#import "AppDelegate.h"

#import "TestChatViewController.h"

//#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>


//
//#define RongAppKey @"c9kqb3rdk5bej"
//
////user001
//#define Ruser1Token @"PBq5rlMgh9m0ou9gJAKWroT6DopgHJIr8BqdVXNYyWIuXuLQjRQdBL2hGPQ6qjq9b3NKiX4jkDBeqPtwmLKhFrw7IURhyIFZ"
//
//
////user002
//#define Ruser2Token @"r/Iad9rIuwHwVQimUR1q3tZw8TYge+8+JRD0wu0MyPtcFLSARg1SLxm8acr7+6Mf3zdpz8vCv7skKFC6fHxhtbUSFEbnXu08"


#define RongAppKey @"3argexb63d6be"
//user001
#define Ruser1Token @"yvxUTGiJ/c6xHACp+zt/6A1N/aq8O7Jj9NeZEXMQLcOCijOjxglxlebniMsXpUGhOLzAARGrzakNnSn7CxSCzz4X+90TyC1K"


//user002
#define Ruser2Token @"T1z7uSH5gMmIhhYMe5lWh3mkXxFESD2VHBr5mLDkaRij3rG/xt9kudOZxb15CITO5sQZvAS70V2Xd/L4wmjlCg=="


@interface AppDelegate ()<RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMGroupUserInfoDataSource,RCIMReceiveMessageDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
     [self IMInit];
    
    [self registerPush];
    
   
    
    
    if (launchOptions) {
        NSDictionary *remoteNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"remoteNotificationUserInfo %@",remoteNotificationUserInfo);
    }
    
    return YES;
}

#pragma mark - 用户信息提供者、群组信息提供者、群名片信息提供者
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:userId portrait:nil];
    return completion(userInfo);
}

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion{
    
    RCGroup *grounpInfo = [[RCGroup alloc]initWithGroupId:groupId groupName:groupId portraitUri:nil];
    return completion(grounpInfo);
    
}

- (void)getUserInfoWithUserId:(NSString *)userId
                      inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    
    RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:userId name:userId portrait:nil];
    return completion(userInfo);
}
#pragma mark - 消息接收监听器
- (void)onRCIMReceiveMessage:(RCMessage *)message
                        left:(int)left{
    NSLog(@"onRCIMReceiveMessage %@",message.content.mentionedInfo);  
}

-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message
                      withSenderName:(NSString *)senderName{
    return NO;
}
-(BOOL)onRCIMCustomAlertSound:(RCMessage *)message{
    return NO;
}


#pragma mark - 初始化融云SDK
-(void)IMInit{
    
    //请使用您之前从融云开发者控制台注册得到的 App Key，通过RCIM的单例，传入 initWithAppKey: 方法，初始化 SDK。
    [[RCIM sharedRCIM] initWithAppKey:RongAppKey];
//    [[RCIMClient sharedRCIMClient] initWithAppKey:RongAppKey];
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    /*
     将您在上一步获取到的 Token，通过 RCIMClient 的单例，传入 -connectWithToken:success:error:tokenIncorrect: 方法，即可建立与服务器的连接。
     
     在 App 整个生命周期，您只需要调用一次此方法与融云服务器建立连接。之后无论是网络出现异常或者 App 有前后台的切换等，SDK 都会负责自动重连。 SDK 针对 iOS 的前后台和各种网络状况，进行了连接和重连机制的优化，建议您调用一次 connectWithToken 即可，其余交给 SDK 处理。 除非您已经手动将连接断开，否则您不需要自己再手动重连。
     */
    
    
    
    [[RCIMClient sharedRCIMClient] connectWithToken:Ruser2Token
                                            success:^(NSString *userId) {
                                                NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [[RCIM sharedRCIM] setUserInfoDataSource:self];
                                                    
                                                    TestChatViewController *ctl = [[TestChatViewController alloc]init];
                                                    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:ctl];
                                                });
                                                
                                            } error:^(RCConnectErrorCode status) {
                                                NSLog(@"登陆的错误码为:%ld", status);
                                            } tokenIncorrect:^{
                                                //token过期或者不正确。
                                                //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                                                //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                                                NSLog(@"token错误");
                                            }];
    
    
    //用户信息提供者
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    //群组信息提供者
    [[RCIM sharedRCIM] setGroupInfoDataSource:self];
    //群名片信息提供者
    [[RCIM sharedRCIM] setGroupUserInfoDataSource:self];
    //IMKit连接状态的监听器
//    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    //IMKit消息接收的监听器
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    //是否关闭本地通知，默认是打开的
    [[RCIM sharedRCIM] setDisableMessageNotificaiton:NO];
    //设置Log级别，开发阶段打印详细logsetReceiveMessageDelegate
//    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Error;
    
}

#pragma mark - 更新BadgeNumber
-(void)updataBadgeNumber{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_APPSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    
    NSString * unreadNum = [NSString stringWithFormat:@"%d",unreadMsgCount];
    NSDictionary * dict = @{@"unreadNum":unreadNum};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageUnreadNum" object:nil userInfo:dict];
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = unreadMsgCount;
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    
    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    
}


/**
 * 推送处理1
 */
-(void)registerPush{

        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token =[[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    NSLog(@"token = %@",token);
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {

    // 请检查App的APNs的权限设置，更多内容可以参考文档
    // http://www.rongcloud.cn/docs/ios_push.html。
    NSLog(@"获取DeviceToken失败！！！");
    NSLog(@"ERROR：%@", error);

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // userInfo为远程推送的内容
    
    NSLog(@"userInfo %@",userInfo);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self updataBadgeNumber];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
