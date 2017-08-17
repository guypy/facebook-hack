/* @flow */

import { NetInfo } from 'react-native';

class Connectivity {
  _isAvailable = true;
  _listeners = {};

  constructor() {
    NetInfo.isConnected.addEventListener(
      'change',
      this._handleConnectivityChange
    );
    this.isAvailableAsync();
  }

  isAvailable = () => {
    return this._isAvailable;
  };

  isAvailableAsync = async () => {
    if (this._isAvailable) {
      return this._isAvailable;
    }

    try {
      this._isAvailable = await NetInfo.isConnected.fetch();
    } catch (e) {
      this._isAvailable = false;
    }

    return this._isAvailable;
  };

  _handleConnectivityChange = (isAvailable: boolean) => {
    this._isAvailable = isAvailable;
    Object.values(this._listeners).forEach(listener => {
      typeof listener === 'function' && listener(this._isAvailable);
    });
  };

  addListener = (listener: any) => {
    this._listeners[listener] = listener;
  };

  removeListener = (listener: any) => {
    delete this._listeners[listener];
  };
}

export default new Connectivity();
