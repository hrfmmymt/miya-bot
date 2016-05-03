{LineRawMessageListener, LineImageListener, LineVideoListener, LineAudioListener, LineLocationListener,
LineStickerListener, LineContactListener, LineRawOperationListener, LineFriendListener, LineBlockListener,
LineTextAction, LineImageAction, LineVideoAction, LineAudioAction, LineLocationAction, LineStickerAction
} = require 'hubot-line'

getTimeDiffAsMinutes = (old_msec) ->
  now = new Date()
  old = new Date(old_msec)
  diff_msec = now.getTime() - old.getTime()
  diff_minutes = parseInt( diff_msec / (60*1000), 10 )
  return diff_minutes

module.exports = (robot) ->
  # LINE platform will access the endpoint to get image and audio contents.
  contentEndpoint = 'https://miya-bot.herokuapp.com:443/download'

  robot.respond /あなたと(ジャバ|ジャヴァ|Java)/i, (msg) ->
    msg.send '今すぐ！'

  robot.listeners.push new LineImageListener robot, (() -> true), (msg) ->
    msg.message.content (content) ->
      robot.brain.set msg.message.id, new Buffer(content, 'binary').toString('base64')
      originalContentUrl = "#{contentEndpoint}?id=#{msg.message.id}"
      msg.message.previewContent (previewContent) ->
        robot.brain.set "p#{msg.message.id}", new Buffer(previewContent, 'binary').toString('base64')
        previewImageUrl = "#{contentEndpoint}?id=p#{msg.message.id}"
        msg.emote new LineImageAction originalContentUrl, previewImageUrl

  robot.listeners.push new LineVideoListener robot, (() -> true), (msg) ->
    msg.message.content (content) ->
      originalContentUrl = "https://github.com/umakoz/hubot-line-example/raw/master/content/video.mp4"
      msg.message.previewContent (previewContent) ->
        previewImageUrl = "https://github.com/umakoz/hubot-line-example/raw/master/content/video.jpg"
        msg.emote new LineVideoAction originalContentUrl, previewImageUrl

  robot.listeners.push new LineAudioListener robot, (() -> true), (msg) ->
    msg.message.content (content) ->
      robot.brain.set msg.message.id, new Buffer(content, 'binary').toString('base64')
      originalContentUrl = "#{contentEndpoint}?id=#{msg.message.id}"
      msg.emote new LineAudioAction originalContentUrl, 1000

  robot.listeners.push new LineLocationListener robot, (() -> true), (msg) ->
    msg.emote new LineLocationAction msg.message.address, msg.message.latitude, msg.message.longitude

  robot.listeners.push new LineStickerListener robot, (() -> true), (msg) ->
    msg.emote new LineStickerAction msg.message.STKID, msg.message.STKPKGID

  robot.listeners.push new LineContactListener robot, (() -> true), (msg) ->
    msg.send "got a contact. mid: #{msg.message.mid} displayName: #{msg.message.displayName}"

  # If you want to listen summarized messages like following.
  #robot.listeners.push new LineRawMessageListener robot, (() -> true), (msg) ->
  #  msg.send "RawMessage! id: #{msg.message.id}"

  robot.listeners.push new LineFriendListener robot, (() -> true), (msg) ->
    msg.send "be a friend. mid: #{msg.message.mid}"

  robot.listeners.push new LineBlockListener robot, (() -> true), (msg) ->
    # process something when a bot account was blocked.

  # If you want to listen summarized operations like following.
  #robot.listeners.push new LineRawOperationListener robot, (() -> true), (msg) ->
  #  msg.send "RawOperation!"



  # LINE platform will access the endpoint to get image and audio contents.
  robot.router.get "/download", (req, msg) =>
    content = robot.brain.get req.query.id
    robot.brain.remove req.query.id
    msg.set('Content-Type', 'binary')
    msg.send new Buffer(content, 'base64')
