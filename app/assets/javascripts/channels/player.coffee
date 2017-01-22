 App.player = App.cable.subscriptions.create "PlayerChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data.nextVideoId
      window.player.play(data.nextVideoId);
      $('.alert').hide()
    else if data.pendingVideos
      this.pending( data.pendingVideos )
    else if data.playlistEnded
      $('.alert').show()
    else if data.stop
      window.player.stop()

  start: ->
    @perform 'start'

  next: (videoId)->
    @perform 'next', currentVideoId: videoId

  pending: (videos)->
    list = $("#pending_videos");
    list.empty();
    first = videos.shift();
    list.append('<li><strong>' + first.title + '</strong></li>')
    for v in videos
      list.append('<li>' + v.title + '</li>')
