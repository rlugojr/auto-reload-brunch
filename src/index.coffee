sysPath = require 'path'
WebSocketServer = (require 'ws').Server

module.exports = class AutoReloader
  brunchPlugin: yes

  constructor: (@config) ->
    @connections = []
    if @config.persistent
      @server = new WebSocketServer host: '0.0.0.0', port: 9485
      @server.on 'connection', (connection) =>
        @connections.push connection
        connection.on 'close', =>
          @connections.splice connection, 1

  onCompile: (changedFiles) ->
    return unless @config.persistent
    allCss = false if changedFiles.length is 0
    allCss ?= changedFiles.every (file)-> file.type is 'stylesheet'
    message = if allCss then 'stylesheet' else 'page' 
    @connections
      .filter (connection) =>
        connection.readyState is 1
      .forEach (connection) =>
        connection.send message

  include: [
    (sysPath.join __dirname, '..', 'vendor', 'auto-reload.js')
  ]
