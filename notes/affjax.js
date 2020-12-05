/* global exports */
/* global module */
'use strict'

exports._ajax = (function () {
  const ajax = {
    newXHR: () => {
      const XHR = module.require('xhr2')
      return new XHR()
    },

    fixupUrl: (url) => {
      const urllib = module.require('url')
      const u = urllib.parse(url)
      u.protocol = u.protocol || 'http:'
      u.hostname = u.hostname || 'localhost'
      return urllib.format(u)
    },

    getResponse: (xhr) => xhr.response
  }

  return (mkHeader, options) => function (onError, onSuccess) {
    const xhr = ajax.newXHR()
    const fixedUrl = ajax.fixupUrl(options.url)

    xhr.open( options.method || 'GET', fixedUrl, true, options.username, options.password 
    if (options.headers) {
      try {
        for (let i = 0, header; (header = options.headers[i]) != null; i++) {
          xhr.setRequestHeader(header.field, header.value)
        }
      } catch (e) {
        onError(e)
      }
    }
    const onerror = function (msg) {
      return function () {
        onError(new Error(msg + ': ' + options.method + ' ' + options.url))
      }
    }

    xhr.onerror = onerror('AJAX request failed')

    xhr.ontimeout = onerror('AJAX request timed out')

    xhr.onload = function () {
      onSuccess({
        status: xhr.status,
        statusText: xhr.statusText,
        headers: xhr
          .getAllResponseHeaders()
          .split('\r\n')
          .filter(function (header) {
            return header.length > 0
          })
          .map(function (header) {
            const i = header.indexOf(':')
            return mkHeader(header.substring(0, i))(header.substring(i + 2))
          }),
        body: ajax.getResponse(xhr)
      })
    }

    xhr.responseType = options.responseType

    xhr.withCredentials = options.withCredentials

    xhr.send(options.content)

    return function (error, cancelErrback, cancelCallback) {
      try {
        xhr.abort()
      } catch (e) {
        return cancelErrback(e)
      }
      return cancelCallback()
    }
  }
})()
