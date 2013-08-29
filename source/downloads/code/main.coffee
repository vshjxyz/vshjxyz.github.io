window.Hello =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    'use strict'
    console.log 'Hello from Backbone!'

console.log 'Waiting for the device to be ready...'

$ ->
    window.DEBUG = false
    console.log 'init Started'
    if not window.device.available
        console.log "WE ARE IN DEBUG"
        window.DEBUG = true
        # In this case we should be in a desktop application (debug)

        # Login with the test user (that has limited privileges and/or makes the app point to another endpoint)
        Hello.BASEURL = 'localhost:8000'

        console.log 'Initializing the main router'
        Hello.init()

    # Waiting for phoneGap to load
    document.addEventListener 'deviceready', ->
        console.log "WE ARE NOT IN DEBUG"
        # PhoneGap is loaded
        try
            throw "Cordova variable does not exist. Check that you have included cordova.js correctly" if (typeof cordova is "undefined") and (typeof Cordova is "undefined")

            # FB plugin initialized

            Hello.BASEURL = 'api.yourdomain.com'

            console.log 'Initializing the main router'
            Hello.init()
        catch e
            window.last_error = e
            console.error e
            throw e
    , false

