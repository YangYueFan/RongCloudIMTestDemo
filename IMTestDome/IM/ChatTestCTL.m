//
//  ChatTestCTL.m
//  IMTestDome
//
//  Created by 科技部2 on 2017/8/10.
//  Copyright © 2017年 Ken. All rights reserved.
//

#import "ChatTestCTL.h"
#import <AudioToolbox/AudioToolbox.h>
@interface ChatTestCTL ()<RCIMClientReceiveMessageDelegate>

@end

@implementation ChatTestCTL

- (void)viewDidLoad {
    //重写显示相关的接口，必须先调用super，否则会屏蔽SDK默认的处理
    [super viewDidLoad];
    
    
    self.title = @"IM";
    
    //设置需要显示哪些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_DISCUSSION),
                                        @(ConversationType_CHATROOM),
                                        @(ConversationType_GROUP),
                                        @(ConversationType_APPSERVICE),
                                        @(ConversationType_SYSTEM)]];
    //设置需要将哪些类型的会话在会话列表中聚合显示
    [self setCollectionConversationType:@[@(ConversationType_DISCUSSION),
                                          @(ConversationType_GROUP)]];
    
    // 设置消息接收监听
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    
    
    
    
    
    
    
    NSArray *conversationList = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[@(ConversationType_PRIVATE),
                                                       @(ConversationType_DISCUSSION),
                                                       @(ConversationType_GROUP),
                                                       @(ConversationType_SYSTEM),
                                                       @(ConversationType_APPSERVICE),
                                                       @(ConversationType_PUBLICSERVICE)]];
    for (RCConversation *conversation in conversationList) {
        NSLog(@"会话类型：%lu，目标会话ID：%@", (unsigned long)conversation.conversationType, conversation.targetId);
    }
    
    
    int totalUnreadCount = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    NSLog(@"当前所有会话的未读消息数为：%d", totalUnreadCount);
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"ToUser1" style:UIBarButtonItemStylePlain target:self action:@selector(newChar)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(void)newChar{
    //新建一个聊天会话View Controller对象,建议这样初始化
    RCConversationViewController *chat = [[RCConversationViewController alloc] initWithConversationType:ConversationType_DISCUSSION
targetId:@"User001"];
    
    //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
    chat.conversationType = ConversationType_PRIVATE;
    //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
    
    
    //设置聊天会话界面要显示的标题
    chat.title = @"user001";
    //显示聊天会话界面
    [self.navigationController pushViewController:chat animated:YES];
}


//重写RCConversationListViewController的onSelectedTableRow事件
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    
    if(conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION){
        
        ChatTestCTL *temp = [[ChatTestCTL alloc]init];
        
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationModelType]];
        
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        
        [self.navigationController pushViewController:temp animated:YES];
        
    }else if (model.conversationModelType == ConversationType_PRIVATE){
        
        RCConversationViewController *vc = [[RCConversationViewController alloc]init];
        
        vc.conversationType = model.conversationType;
        vc.targetId = model.targetId;
        
        
        [self.navigationController pushViewController:vc animated:YES];
    }else{
    
        RCConversationViewController *conversationVC = [[RCConversationViewController alloc]init];
        conversationVC.conversationType = model.conversationType;
        conversationVC.targetId = model.targetId;
        conversationVC.title = @"想显示的会话标题";
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
    

}

/*!
 接收消息的回调方法
 
 @param message     当前接收到的消息
 @param nLeft       还剩余的未接收的消息数，left>=0
 @param object      消息监听设置的key值
 
 @discussion 如果您设置了IMlib消息监听之后，SDK在接收到消息时候会执行此方法。
 其中，left为还剩余的、还未接收的消息数量。比如刚上线一口气收到多条消息时，通过此方法，您可以获取到每条消息，left会依次递减直到0。
 您可以根据left数量来优化您的App体验和性能，比如收到大量消息时等待left为0再刷新UI。
 object为您在设置消息接收监听时的key值。
 */
- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object {
    
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        NSLog(@"消息内容：%@", testMessage.content);
        
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    }
    
    NSLog(@"还剩余的未接收的消息数：%d", nLeft);
    
    if (nLeft == 0) {
        
        [self refreshConversationTableViewIfNeeded];
        
    }
}

@end
