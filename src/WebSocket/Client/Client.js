/* global exports */
'use strict';

// module WebSocket.Client
exports.newWebSocketImpl = function (url, protocols) {
  return function () {
    const platformSpecific = {}
    if (typeof module !== 'undefined' && module.require) {
      // We are on node.js
      platformSpecific.WebSocket = module.require('ws')
    } else {
      // We are in the browser
      platformSpecific.WebSocket = WebSocket
    }
    const socket = new platformSpecific.WebSocket(url, protocols)
    const getSocketProp = function (prop) {
      return function () { return socket[prop] }
    }
    const setSocketProp = function (prop) {
      return function (v) {
        return function () {
          socket[prop] = v
          return {}
        }
      }
    }
    return { // factor this code - common to server and client back into Types.js
      setBinaryType: setSocketProp('binaryType'),
      getBinaryType: getSocketProp('binaryType'),
      getBufferedAmount: getSocketProp('bufferedAmount'),
      setOnclose: setSocketProp('onclose'),
      getOnclose: getSocketProp('onclose'),
      setOnerror: setSocketProp('onerror'),
      getOnerror: getSocketProp('onerror'),
      setOnmessage: setSocketProp('onmessage'),
      getOnmessage: getSocketProp('onmessage'),
      setOnopen: setSocketProp('onopen'),
      getOnopen: getSocketProp('onopen'),
      setProtocol: setSocketProp('protocol'),
      getProtocol: getSocketProp('protocol'),
      getReadyState: getSocketProp('readyState'),
      getUrl: getSocketProp('url'),
      closeImpl:
        function (params) {
          return function () {
            if (params == null) {
              socket.close()
            } else if (params.reason == null) {
              socket.close(params.code)
            } else {
              socket.close(params.code, params.reason)
            }
            return {}
          }
        },
      sendImpl:
        function (message) {
          return function () {
            socket.send(message)
            return {}
          }
        },
      getSocket: function () { return socket }
    }
  }
}
