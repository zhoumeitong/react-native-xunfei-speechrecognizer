# react-native-xunfei

功能：
通过使用讯飞SDK实现语音听写功能。

一、获取appid并下载对应的SDK

appid是第三方应用集成讯飞开放平台SDK的身份标识，由于SDK静态库和appid是绑定的，每款应用必须保持唯一，所以这里需要用户自己下载对应的SDK。
参考：http://www.xfyun.cn/sdk/dispatcher

二、链接xunfei库

参考：https://reactnative.cn/docs/0.50/linking-libraries-ios.html#content

1、添加react-native-xunfei插件到你工程的node_modules文件夹下

2、添加xunfei库中的.xcodeproj文件在你的工程中

3、点击你的主工程文件，选择Build Phases，然后把刚才所添加进去的.xcodeproj下的Products文件夹中的静态库文件（.a文件），拖到Link Binary With Libraries组内。


三、开发环境配置

参考：http://doc.xfyun.cn/msc_ios/302721

1、引入系统库及第三方库
左侧目录中选中工程名，在TARGETS->Build Phases-> Link Binary With Libaries中点击“+”按钮，在弹出的窗口中查找并选择所需的库（见下图），单击“Add”按钮，将库文件添加到工程中。

![](http://upload-images.jianshu.io/upload_images/2093433-4c66b7c8d7391e95.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


2、设置Bitcode
在Xcode 7,8默认开启了Bitcode，而Bitcode 需要工程依赖的所有类库同时支持。MSC SDK暂时还不支持Bitcode，可以先临时关闭。关闭此设置，只需在Targets - Build Settings 中搜索Bitcode 即可，找到相应选项，设置为NO。

![](http://upload-images.jianshu.io/upload_images/2093433-479fe3d03d48a374.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3、用户隐私权限配置
iOS 10发布以来，苹果为了用户信息安全，加入隐私权限设置机制，让用户来选择是否允许。
隐私权限配置可在info.plist 新增相关privacy字段，MSC SDK中需要用到的权限主要包括麦克风权限、联系人权限和地理位置权限：
><key>NSMicrophoneUsageDescription</key>
<string></string>
<key>NSLocationUsageDescription</key>
<string></string>
<key>NSLocationAlwaysUsageDescription</key>
<string></string>
<key>NSContactsUsageDescription</key>
<string></string>

![](http://upload-images.jianshu.io/upload_images/2093433-4b8cb2e7077405ca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


四、简单使用

js文件
```

import React, { Component } from 'react';
import {
Platform,
StyleSheet,
Text,
View,
Dimensions,
Alert,
ScrollView,
TouchableHighlight,
NativeEventEmitter
} from 'react-native';

import XunFei from 'react-native-xunfei';

let appid = '5a531707';

function show(title, msg) {
AlertIOS.alert(title+'', msg+'');
}


export default class App extends Component<{}> {


constructor(props: Object) {
super(props)

this.state = {
value: '',
}
}

componentDidMount() {

this.registerApp();

const XunFeiEmitter = new NativeEventEmitter(XunFei);

const subscription = XunFeiEmitter.addListener(
'finishSpeechRecognizer',
(response) => {
this.setState({
value: response.result,
});
}
);
}

componentWillUnmount(){
//取消订阅
subscription.remove();
}

//注册应用
registerApp() {
XunFei.registerApp(appid);
}

//开始识别
startSpeechRecognizer() {
XunFei.startSpeechRecognizer();
}


//停止识别
stopSpeechRecognizer() {
XunFei.stopSpeechRecognizer();
}

//取消识别
cancelSpeechRecognizer() {
XunFei.cancelSpeechRecognizer();
}


render() {
return (
<ScrollView contentContainerStyle={styles.wrapper}>

<Text style={styles.pageTitle}>{this.state.value}</Text>

<TouchableHighlight
style={styles.button} underlayColor="#f38"
onPress={this.registerApp}>
<Text style={styles.buttonTitle}>registerApp</Text>
</TouchableHighlight>


<TouchableHighlight
style={styles.button} underlayColor="#f38"
onPress={this.startSpeechRecognizer}>
<Text style={styles.buttonTitle}>startSpeechRecognizer</Text>
</TouchableHighlight>

<TouchableHighlight
style={styles.button} underlayColor="#f38"
onPress={this.stopSpeechRecognizer}>
<Text style={styles.buttonTitle}>stopSpeechRecognizer</Text>
</TouchableHighlight>


<TouchableHighlight
style={styles.button} underlayColor="#f38"
onPress={this.cancelSpeechRecognizer}>
<Text style={styles.buttonTitle}>cancelSpeechRecognizer</Text>
</TouchableHighlight>


</ScrollView>
);
}
}

const styles = StyleSheet.create({
wrapper: {
paddingTop: 60,
paddingBottom: 20,
alignItems: 'center',
},
pageTitle: {
paddingBottom: 40
},
button: {
width: 200,
height: 40,
marginBottom: 10,
borderRadius: 6,
backgroundColor: '#f38',
alignItems: 'center',
justifyContent: 'center',
},
buttonTitle: {
fontSize: 16,
color: '#fff'
},
});

```

效果展示:

![](http://upload-images.jianshu.io/upload_images/2093433-3fd65b92fff233b9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/440)
