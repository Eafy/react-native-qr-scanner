/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Image, Text, View, Dimensions, Button,TouchableOpacity} from 'react-native';
import { QRSannerView } from 'react-native-scanner-kit';
const {height, width} = Dimensions.get('window');

export default class App extends Component<Props> {
    state = {
        isOpenFlash:false,
        isStartScan:true
    };

    componentWillMount() {
    }

    componentDidMount(){
    }

    componentWillUnmount() {
    }

  render() {
    return (
      <View style={styles.container}>
        <QRSannerView
          width={width}
          height={height}
          isStartScan={this.state.isStartScan}
          isOpenFlash={this.state.isOpenFlash}
          framingRatioRect={{x:0, y:(height-width)/2.0/height, width:1.0, height:width/height}}
          scanAudioFile="noticeMusic.caf"

          onScanResult={(params)=>{
            console.log("onScannerResult->params:" + params)
          }}

          onScanError={(params)=>{
            console.log("onScannerError->params:" + params)
          }}
        >

        </QRSannerView>

        <TouchableOpacity style={{position:'absolute',bottom:20,start:width/2-10}} onPress={()=>{
            this.setState({isOpenFlash:!this.state.isOpenFlash})
            }}>
            <Image
            source={this.state.isOpenFlash ? require('./res/image/home_icon_location.png'):require('./res/image/home_icon_car.png')}>
            </Image>
        </TouchableOpacity>

      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  }
});
