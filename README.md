# web socket server on NodeJS/ws
## Example program for extension of purescript-websocket-simple to support server sockets too

This is a derivation of [`purescript-websocket-simple`](https://github.com/zudov/purescript-websocket-simple) (which is a very useful library that
protected me from now from ever having to learn or even understand websockets at all. but as soon as i wanted originate a websocket - 
creating a "server socket" in websocket parlance - i hit some limitations.)

Altho' that library has some support for running in Node (the socket opening code has a platform independent part which tries to detect 
if it's running in the browser and if not it `require`'s `ws`) it doesn't support server sockets at all and, it turns out they are different in
several ways. 

Most important difference is that in order to use a server websocket you are probably going to prefer to do so in `Aff` rather than synchronously. 
This is because the `Connection` can be done immediately but it only makes sense to return the `Socket` when at least one client has connected to it.

# what's here

i've broken the original library apart a bit, abstracting the common stuff and making separate modules for client and server sockets. 
the server socket code simply won't work in the browser and i haven't made any nice error handling for that (but probably should).

# state of the code

if you `spago run` the main here AND you connect to the resulting socket (ie at `ws://localhost:8080`), for example using `websocat` utility, then you should
see activity in the console when you type into the client and if you type `goodbye` it will close the socket.

It's very unpolished, more of a gist than a repo but still, i think, useful.
