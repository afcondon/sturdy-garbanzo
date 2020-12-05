/* global exports */
'use strict'

// module WebSocket.Server

// NB server sockets are, of necessity, Node-only
const express = require('express')
const path = require('path')
const { createServer } = require('http')
const ws = module.require('ws')
const app = express()
app.use(express.static(path.join(__dirname, '/public')))
const server = createServer(app)

exports._newWebSocketServer = (function () {

  return (port)  => function(onError, onSuccess) {
    server.listen(port, function () {
      console.log(`Listening on http://localhost:${port}`)
    })
    const socket = new ws.Server({ server })
    socket.on('connection', function() {
      onSuccess(makeConnection)
    })

    function makeConnection () {
      console.log('interior of makeConnection')
      const getSocketProp = function (prop) {
        return function () {
          return socket[prop]
        }
      }
      const setSocketProp = function (prop) {
        return function (v) {
          return function () {
            socket[prop] = v
            return {}
          }
        }
      }
    
      return {
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
        closeImpl: function (params) {
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
        sendImpl: function (message) {
          return function () {
            socket.send(message)
            return {}
          }
        },
        getSocket: function () {
          return socket
        }
      }
    }
    return function (cancelError, onCancelerError, onCancelerSuccess) {
      cancel();
      onCancelerSuccess();
    };
  }
})()
