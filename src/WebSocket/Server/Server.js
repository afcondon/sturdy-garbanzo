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
const WebSocket = require('ws');

exports._newWebSocketServer = (function () {
  return port =>
    function (onError, onSuccess) {
      server.listen(port, function () {
        console.log(`Listening on http://localhost:${port}`)
      })
      const wss = new ws.Server({ server })
      wss.on('connection', function (ws) {
        onSuccess(makeConnection(ws))
      })

      return function (cancelError, onCancelerError, onCancelerSuccess) {
        cancel()
        onCancelerSuccess()
      }
    }
})()

function makeConnection (ws) {
  console.log('makeConnection')

  const getSocketProp = prop => () => ws[prop]
  const setSocketProp = (prop) => (v) => () => {
    ws.on(prop, v)
  }

  const connectionImpl = {
    // props
    setBinaryType: setSocketProp('binaryType'),
    getBinaryType: getSocketProp('binaryType'),
    getBufferedAmount: getSocketProp('bufferedAmount'),
    getReadyState: getSocketProp('readyState'),
    getUrl: getSocketProp('url'),
    // event handlers
    setOnclose: setSocketProp('close'),
    getOnclose: getSocketProp('close'),
    setOnerror: setSocketProp('error'),
    getOnerror: getSocketProp('error'),
    setOnmessage: setSocketProp('message'),
    getOnmessage: getSocketProp('message'),
    setOnopen: setSocketProp('open'),
    getOnopen: getSocketProp('open'),
    setProtocol: setSocketProp('protocol'),
    getProtocol: getSocketProp('protocol'),
    // methods
    closeImpl: function (params) {
      return function () {
        if (params == null) {
          ws.close()
        } else if (params.reason == null) {
          ws.close(params.code)
        } else {
          ws.close(params.code, params.reason)
        }
        return {}
      }
    },
    sendImpl: function (message) {
      return function () {
        ws.send(message)
        return {}
      }
    },
    getSocket: function () {
      return ws
    }
  }
  console.log(connectionImpl)
  return connectionImpl
}