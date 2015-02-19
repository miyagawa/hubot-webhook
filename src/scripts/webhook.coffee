# Descriptipn
#   Generic Webhook plugin for Hubot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_WEBHOOK_COMMANDS
#   HUBOT_WEBHOOK_URL
#   HUBOT_WEBHOOK_PARAMS
#
# Commands:
#   Hubot <command> <text> - Trigger webhook
#
# Author:
#   Tatsuhiko Miyagawa <miyagawa@bulknews.net>
#
Qs = require 'qs'
module.exports = (robot) ->
  webhook = new Webhook process.env
  if process.env.HUBOT_WEBHOOK_COMMANDS
    cmds = process.env.HUBOT_WEBHOOK_COMMANDS.split(',').join("|")
    pattern = new RegExp "(#{cmds}) (.*)"
    robot.respond pattern, (msg) ->
      new Command(msg, robot).reply(webhook, command: msg.match[1], text: msg.match[2])
  else
    robot.respond /(.*)/, (msg) ->
      new Command(msg, robot).reply(webhook, text: msg.match[1])

class Webhook
  constructor: (env) ->
    @url = env.HUBOT_WEBHOOK_URL
    @params = Qs.parse env.HUBOT_WEBHOOK_PARAMS

  buildBody: (message, params) ->
    params[k] = v for k, v in @params
    params['user_id'] = message.user.id
    params['user_name'] = message.user.name
    params['room_id'] = message.user.room
    params['room_name'] = message.user.room
    Qs.stringify params

class Command
  constructor: (@msg, @robot) ->

  reply: (webhook, params) ->
    @msg
      .http webhook.url
      .post(webhook.buildBody(@msg.message, params)) @callback

  callback: (err, _, body) =>
    if err?
      @robot.logger.error err
    else if body
      @msg.send body
