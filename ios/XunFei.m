//
//  XunFei.m
//  XFDemo
//
//  Created by asdc on 2018/1/9.
//  Copyright © 2018年 asdc. All rights reserved.
//

#import "XunFei.h"
#import "IFlyMSC/IFlyMSC.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"

@interface XunFei()
{
    BOOL hasListeners;
}
//不带界面的识别对象
@property (nonatomic, strong)IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, assign)BOOL isCanceled;
@property (nonatomic, strong)NSString *result;//最终结果
@property (nonatomic, strong)NSString *lastResult;//上一次记录结果
@end

static XunFei * instance = nil;

@implementation XunFei

RCT_EXPORT_MODULE();

#pragma mark - 初始化

+ (instancetype)shareInstance {
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (!instance) {
            instance = [super allocWithZone:zone];
        }
    }
    return instance;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        //初始化识别参数
        [self initRecognizer];
    }
    
    return self;
}

//初始化识别参数
- (void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    //单利模式 无UI的实例
    if (self.iFlySpeechRecognizer == nil) {
        //创建语音识别对象
        _iFlySpeechRecognizer=[IFlySpeechRecognizer sharedInstance];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置为听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
    }
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance=[IATConfig sharedInstance];
        
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        
        //设置后端点
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        
        //设置前端点
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐16K
        [_iFlySpeechRecognizer setParameter:IATConfig.lowSampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            
        }else if([instance.language isEqualToString:[IATConfig english]]){
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    }
    
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"finishSpeechRecognizer"];
}

#pragma mark - 优化无监听处理的事件
// 在添加第一个监听函数时触发
-(void)startObserving {
    hasListeners = YES;
}

-(void)stopObserving {
    hasListeners = NO;
}

#pragma mark - 注册APP
- (void)registerAppWith:(NSString *)appid
{
    //设置日志msc.log生成路径以及日志等级
    [IFlySetting setLogFile:LVL_ALL];
    
    //关闭打印控制台log
    [IFlySetting showLogcat:NO];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    //设置日志文件的路径
    [IFlySetting setLogFilePath:cachePath];
    
    //Appid是应用的身份信息，具有唯一性，初始化时必须要传入Appid。
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", appid];
    [IFlySpeechUtility createUtility:initString];
}

#pragma mark - 识别事件
// 开始识别
- (void)start
{
    NSLog(@"start");
    _lastResult = @"";
    self.isCanceled = NO;
    if (_iFlySpeechRecognizer == nil) {
        [self initRecognizer];
    }
    [_iFlySpeechRecognizer cancel];
    
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听说结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下（为了测试音频流识别用的）
    //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存。
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    BOOL ret=[_iFlySpeechRecognizer startListening];
    if (ret) {
        NSLog(@"启动成功");
    }else{
        NSLog(@"启动失败");
    }
}

//停止识别
- (void)stop
{
    NSLog(@"stop");
    [_iFlySpeechRecognizer stopListening];
}

//取消识别
- (void)cancel
{
    NSLog(@"cancel");
    self.isCanceled = YES;
    [_iFlySpeechRecognizer cancel];
}


#pragma mark - IFlySpeechRecognizerDelegate
/**
 识别结果返回代理
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast
{
    NSMutableString *resultString=[[NSMutableString alloc]init];
    NSDictionary *dic=results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }

    NSString *resultFromJson=[ISRDataHelper stringFromJson:resultString];
    self.result=[NSString stringWithFormat:@"%@%@",self.lastResult,resultFromJson];
    //保存上一次的记录
    self.lastResult = self.result;
    if (isLast) {
        NSLog(@"听说结果:%@",self.result);
    }

    if (hasListeners) {//优化无监听处理的事件
        [self sendEventWithName:@"finishSpeechRecognizer" body:@{@"result": self.result}];
    }
    
}

/**
 识别会话结束返回代理（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void)onError:(IFlySpeechError *)error
{
    NSLog(@"%s",__func__);
    NSString *text;
    
    if (self.isCanceled) {
        text=@"识别取消";
    }else if (error.errorCode==0){
        if (self.result.length==0) {
            text=@"无识别结果";
        }else{
            text=@"识别成功";
        }
    }else{
        text=[NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error
              .errorDesc];;
    }
    
    NSLog(@"%@",text);
    
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
}

/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"onBeginOfSpeech");
}

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        
        return;
    }

//    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
//    NSLog(@"%@",vol);
}

/**
 
 听写取消回调
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}


RCT_EXPORT_METHOD(registerApp:(NSString *)appid)
{
    [instance registerAppWith:appid];
}

RCT_EXPORT_METHOD(startSpeechRecognizer)
{
    [instance start];
}

RCT_EXPORT_METHOD(stopSpeechRecognizer)
{
    [instance stop];
}

RCT_EXPORT_METHOD(cancelSpeechRecognizer)
{
    [instance cancel];
}


@end
