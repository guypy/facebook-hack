/* @flow */

import React from 'react';
import { ScrollView, StyleSheet, TextInput } from 'react-native';
import { connect } from 'react-redux';

import Alerts from '../constants/Alerts';
import Analytics from '../../Api/Analytics';
import AuthTokenActions from '../../Flux/AuthTokenActions';
import Colors from '../constants/Colors';
import Form from '../components/Form';
import PrimaryButton from '../components/PrimaryButton';
import Auth0Api from '../../Api/Auth0Api';

const DEBUG = false;

@connect(data => SignInScreen.getDataProps(data))
export default class SignInScreen extends React.Component {
  static route = {
    navigationBar: {
      title: 'Sign In',
    },
  };

  static getDataProps(data) {
    return {
      authTokens: data.authTokens,
    };
  }

  state = DEBUG
    ? {
        email: 'testing@getexponent.com',
        password: 'pass123',
        isLoading: false,
      }
    : {
        email: '',
        password: '',
        isLoading: false,
      };

  _isMounted: boolean;

  componentDidMount() {
    this._isMounted = true;
  }

  componentWillUnmount() {
    this._isMounted = false;
  }

  componentWillReceiveProps(nextProps: Object) {
    if (nextProps.authTokens.idToken && !this.props.authTokens.idToken) {
      TextInput.State.blurTextInput(TextInput.State.currentlyFocusedField());
      this.props.navigation.dismissModal();
    }
  }

  render() {
    return (
      <ScrollView
        style={styles.container}
        contentContainerStyle={{ paddingTop: 15 }}
        keyboardShouldPersistTaps="always"
        keyboardDismissMode="on-drag">
        <Form>
          <Form.Input
            autoCapitalize="none"
            autoCorrect={false}
            autoFocus={true}
            blurOnSubmit={false}
            keyboardType="email-address"
            label="E-mail or username"
            onChangeText={this._handleChangeEmail}
            onSubmitEditing={this._handleSubmitEmail}
            returnKeyType="next"
            value={this.state.email}
          />
          <Form.Input
            hideBottomBorder
            label="Password"
            ref={view => {
              this._passwordInput = view;
            }}
            onChangeText={this._handleChangePassword}
            onSubmitEditing={this._handleSubmitPassword}
            returnKeyType="done"
            secureTextEntry
            value={this.state.password}
          />
        </Form>

        <PrimaryButton
          isLoading={this.state.isLoading}
          style={{ margin: 20 }}
          onPress={this._handleSubmit}>
          Sign In
        </PrimaryButton>
      </ScrollView>
    );
  }

  _passwordInput: TextInput;

  _handleSubmitEmail = () => {
    this._passwordInput.focus();
  };

  _handleSubmitPassword = () => {
    this._handleSubmit();
  };

  _handleChangeEmail = (email: string) => {
    this.setState({ email });
  };

  _handleChangePassword = (password: string) => {
    this.setState({ password });
  };

  _handleSubmit = async () => {
    let { email, password, isLoading } = this.state;

    if (isLoading) {
      return;
    }

    this.setState({ isLoading: true });

    try {
      let result = await Auth0Api.signInAsync(email, password);

      if (this._isMounted) {
        if (result.error) {
          this._handleError(result);
        } else {
          this.props.navigator.hideLocalAlert();

          let trackingOpts = {
            id: result.id,
            emailOrUsername: email,
          };
          Analytics.identify(result.id, trackingOpts);
          Analytics.track(Analytics.events.USER_LOGGED_IN, trackingOpts);

          this.props.dispatch(
            AuthTokenActions.signIn({
              refreshToken: result.refresh_token,
              accessToken: result.access_token,
              idToken: result.id_token,
            })
          );
        }
      }
    } catch (e) {
      this._isMounted && this._handleError(e);
    } finally {
      this._isMounted && this.setState({ isLoading: false });
    }
  };

  _handleError = (error: Error) => {
    console.log({ error });
    let message =
      error.error_description ||
      error.message ||
      'Sorry, something went wrong.';
    this.props.navigator.showLocalAlert(message, Alerts.error);
  };
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.greyBackground,
  },
});
