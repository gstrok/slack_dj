 App.player = App.cable.subscriptions.create "PlayerChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data.nextVideo
      window.player.play(data.nextVideo);
    else if data.nextPending
      window.player.renderNextPending(data.nextPending)
    else if data.stop
      window.player.stop()

  start: ->
    @perform 'start'

  next: (videoId)->
    @perform 'next', currentVideoId: videoId

  whats_next: ->
    @perform 'whats_next'
