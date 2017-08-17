import React from 'react';
import MainPage from './components/MainPage';
import { StyleSheet, Text, View, Image, Button } from 'react-native';

export default class App extends React.Component {
  constructor(props){
      super(props);
      this.state = {"displayMain": true};
  }

  onClick() {
      this.setState({"displayMain": false})
  }

  backToOrigin(){
      console.log('gotHere');
      this.setState({"displayMain":true})
  }

  render() {
      if (this.state.displayMain) {
          return (
              <View style={styles.container}>
                  <Button title="Hello" onPress={this.onClick.bind(this)}></Button>
                  <Text>Open upasdasd App.js to start working on your app!</Text>
              </View>
          );
      } else {
          return (
              <MainPage backToOrigin={this.backToOrigin.bind(this)}/>
          );
      }
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
