/* @flow */

import { Asset, Font } from 'expo';
import React from 'react';
import {
  ActivityIndicator,
  Platform,
  StatusBar,
  StyleSheet,
  View,
  ScrollView,
  Text,
  Button,
  Image,
  Linking
} from 'react-native';
import { NavigationProvider, StackNavigation } from '@expo/ex-navigation';
import { ActionSheetProvider } from '@expo/react-native-action-sheet';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';

import ExUrls from 'ExUrls';
import AuthTokenActions from '../Flux/AuthTokenActions';
import BrowserActions from '../Flux/BrowserActions';
import LocalStorage from '../Storage/LocalStorage';
import GlobalLoadingOverlay from './containers/GlobalLoadingOverlay';
import ExStore from '../Flux/ExStore';

import customNavigationContext from './navigation/customNavigationContext';

function cacheImages(images) {
  return images.map(image => Asset.fromModule(image).downloadAsync());
}



export default class AppContainer extends React.Component {
  state = {
    isReady: false,
  };

  componentDidMount() {
    this._initializeStateAsync();
  }

  onClickButton() {
    console.log("ASDFASDFSDF")
    // let url = ExUrls.normalizeUrl('exp://exp.host/@community/movieapp')
    let url = ExUrls.normalizeUrl('exp://exp.host/@community/growler-prowler')

    // let url = ExUrls.normalizeUrl('exp://xa-znt.barak2222.app2.exp.direct:80')
    Linking.openURL(url)
  }

  _initializeStateAsync = async () => {
    try {
      ExStore.dispatch(BrowserActions.loadSettingsAsync());
      ExStore.dispatch(BrowserActions.loadHistoryAsync());
      let storedAuthTokens = await LocalStorage.getAuthTokensAsync();

      if (storedAuthTokens) {
        ExStore.dispatch(AuthTokenActions.setAuthTokens(storedAuthTokens));
      }

      if (Platform.OS === 'ios') {
        let imageAssets = [
          require('../Assets/ios-menu-refresh.png'),
          require('../Assets/ios-menu-home.png'),
        ];

        await Promise.all([
          ...cacheImages(imageAssets),
          Font.loadAsync(Ionicons.font),
        ]);
      } else {
        await Promise.all([
          Font.loadAsync(Ionicons.font),
          Font.loadAsync(MaterialIcons.font),
        ]);
      }
    } catch (e) {
      // ..
    } finally {
      this.setState({ isReady: true });
    }
  };
  
  render() {
    if (!this.state.isReady) {
      return (
        <View
          style={{
            flex: 1,
            backgroundColor: 'white',
            alignItems: 'center',
            justifyContent: 'center',
          }}>
          <ActivityIndicator />
        </View>
      );
    }

    return (
      <View style={styles.container}>
        <Image style={{width: '100%', height: 60, position: 'absolute', top: 0, zIndex: 2}} source={{uri: 'http://i.imgur.com/uvInxy7.png'}} /> 
        <ScrollView style={{marginTop: 60}}>
          <View style={{width: '100%', opacity: 0, height: 45, position: 'absolute', top: 306, zIndex: 1}}>
            <Button title="" onPress={this.onClickButton} />
          </View>
          <Image style={{width: '100%', height: 2000}} source={{uri: 'http://i.imgur.com/pkaYFcv.png'}} /> 
          
        </ScrollView>
        <Image style={{width: '100%', height: 45, position: 'absolute', bottom: 0}} source={{uri: 'http://i.imgur.com/drI03Rg.png'}} />
      </View>
      )

  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  statusBarUnderlay: {
    height: 24,
    backgroundColor: 'rgba(0,0,0,0.2)',
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
  },
});
