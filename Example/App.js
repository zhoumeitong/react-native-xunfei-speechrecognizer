/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

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
