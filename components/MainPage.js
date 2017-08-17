import React from 'react';
import {StyleSheet, Text, View, Image, Button} from 'react-native';

export default class MainPage extends React.Component{
    constructor(props){
        super(props);
        this.state ={firstText:'components'};
    }

    navigateToSecondPage(){
        console.log(this.props);
        this.props.backToOrigin()

    };

    render() {
        return (
            <View>
                  <Text>{"aaa"}</Text>
                <Button title="NavigateBackToFirst" onPress={this.navigateToSecondPage.bind(this)}></Button>
           </View>
        );
    }
}

const style = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#999',
        alignItems: 'center',
        justifyContent: 'center',
    },
});

