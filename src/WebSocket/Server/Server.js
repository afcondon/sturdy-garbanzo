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

// const wss = new WebSocket.Server({ port: 8080 });

// wss.on('connection', function connection(ws) {
//   ws.on('message', function incoming(message) {
//     console.log('received: %s', message);
//   });

//   ws.send('something');
// });

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

      function makeConnection (ws) {
        console.log('makeConnection')

        const getSocketProp = prop => () => socket[prop]
        const setSocketProp = (prop) => (v) => () => {
          ws.on(prop, v)
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
      }
      return function (cancelError, onCancelerError, onCancelerSuccess) {
        cancel()
        onCancelerSuccess()
      }
    }
})()
