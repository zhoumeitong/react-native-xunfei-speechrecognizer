# react-native-xunfei-speechrecognizer

### 功能：

通过使用讯飞SDK实现语音听写功能。

### 使用步骤

#### 一、获取appid并下载对应的SDK

`appid`是第三方应用集成讯飞开放平台SDK的身份标识，由于SDK静态库和`appid`是绑定的，每款应用必须保持唯一，所以这里需要用户自己下载对应的SDK。

参考：http://www.xfyun.cn/sdk/dispatcher

#### 二、链接xunfei库

参考：https://reactnative.cn/docs/0.50/linking-libraries-ios.html#content

##### 手动添加：

1、添加`react-native-xunfei-speechrecognizer`插件到你工程的`node_modules`文件夹下
2、添加`xunfei`库中的`.xcodeproj`文件在你的工程中
3、点击你的主工程文件，选择`Build Phases`，然后把刚才所添加进去的`.xcodeproj`下的`Products`文件夹中的静态库文件（.a文件），拖到`Link Binary With Libraries`组内。

##### 自动添加：

```
npm install react-native-xunfei-speechrecognizer --save 
或
yarn add react-native-xunfei-speechrecognizer

react-native link
```

#### 三、开发环境配置

参考：http://doc.xfyun.cn/msc_ios/302721

##### 1、引入系统库及第三方库

左侧目录中选中工程名，在`TARGETS->Build Phases-> Link Binary With Libaries`中点击`“+”`按钮，在弹出的窗口中查找并选择所需的库（见下图），单击`“Add”`按钮，将库文件添加到工程中。

- iflyMSC.framework
- libz.tbd
- AVFoundation.framework
- SystemConfiguration.framework
- Foundation.framework
- CoreTelephony.framework
- AudioToolbox.framework
- UIKit.framework
- CoreLocation.framework
- Contacts.framework
- AddressBook.framework
- QuartzCore.framework
- CoreGraphics.framework
- libc++.tbd
- libicucore.tbd

![](http://upload-images.jianshu.io/upload_images/2093433-4c66b7c8d7391e95.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)


##### 2、设置Bitcode

在`Xcode 7,8`默认开启了`Bitcode`，而`Bitcode`需要工程依赖的所有类库同时支持。`MSC SDK`暂时还不支持`Bitcode`，可以先临时关闭。关闭此设置，只需在`Targets - Build Settings`中搜索`Bitcode`即可，找到相应选项，设置为`NO`。

![](http://upload-images.jianshu.io/upload_images/2093433-479fe3d03d48a374.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)

##### 3、用户隐私权限配置

`iOS 10`发布以来，苹果为了用户信息安全，加入隐私权限设置机制，让用户来选择是否允许。
隐私权限配置可在`info.plist`新增相关`privacy`字段，`MSC SDK`中需要用到的权限主要包括麦克风权限、联系人权限和地理位置权限：

><key>NSMicrophoneUsageDescription</key>
<string></string>
<key>NSLocationUsageDescription</key>
<string></string>
<key>NSLocationAlwaysUsageDescription</key>
<string></string>
<key>NSContactsUsageDescription</key>
<string></string>

#### 四、简单使用

##### 方法

Event Name | Returns | Notes 
------ | ---- | -------
registerApp | null | 注册应用
startSpeechRecognizer | null | 开始识别
stopSpeechRecognizer | null | 停止识别
cancelSpeechRecognizer | null | 取消识别
finishSpeechRecognizer | result | 识别结束监听事件

##### js文件

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

import XunFei from 'react-native-xunfei-speechrecognizer';

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
