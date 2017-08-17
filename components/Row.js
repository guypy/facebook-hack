import React from 'react';
import {View, Text, StyleSheet, Image, Button} from 'react-native';

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 12,
        flexDirection: 'row',
        alignItems: 'center',
    },
    text: {
        marginLeft: 12,
        fontSize: 16,
        fontWeight: 'bold',
        marginRight: 20,
    },
    photo: {
        height: 70,
        width: 70,
        borderRadius: 20,
    },
    price: {
        marginLeft: 12,
        fontSize: 10,
        marginRight: 10
    },
    button: {
        fontSize: 10,
        color: '#ffffff',
        backgroundColor: '#0099cc',
        borderRadius: 20
    },
    buttonColumn: {
        alignItems: 'flex-end',
        flexDirection: 'column'
    }
});


const openDetails = function () {
    console.log(this.name);
};

export default class Row extends React.Component {
    constructor(props) {
        super(props);
        this.state = {test:'test'}
    }


    openDetails() {
        console.log(this.props.name);
    }

    addToCart(){
        console.log(this.props.price);
    }

    render() {
        return (
            <View style={styles.container}>
                <Image source={{uri: this.props.picture.large}} style={styles.photo}/>
                <View>
                    <Text style={styles.text}>
                        {`${this.props.name}`}
                    </Text>
                    <Text style={styles.price}>
                        {`${this.props.price}`}$
                    </Text>
                </View>
                <View style={styles.container.buttonColumn}>
                    <Button style={styles.container.button} title="More details" onPress={this.openDetails.bind(this)}></Button>
                    <Button style={styles.container.button} title="Add to cart" onPress={this.addToCart.bind(this)}></Button>
                </View>
            </View>
        )
    }
}