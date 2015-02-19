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
  unless process.env.HUBOT_WEBHOOK_URL
    robot.logger.warning "webhook plugin is disabled since HUBOT_WEBHOOK_URL is not set."
    return
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
    @method = env.HUBOT_WEBHOOK_METHOD || 'POST'

  prepareParams: (message, params) ->
    params[k] = v for k, v of @params
    params['user_id'] = message.user.id
    params['user_name'] = message.user.name
    params['room_id'] = message.user.room
    params['room_name'] = message.user.room

class Command
  constructor: (@msg, @robot) ->

  reply: (webhook, params) ->
    webhook.prepareParams(@msg.message, params)
    switch webhook.method
      when "GET"
        @msg.http(webhook.url).query(params).get() @callback
      else
        @msg.http(webhook.url).post(Qs.stringify params) @callback

  callback: (err, _, body) =>
    if err?
      @robot.logger.error err
    else if body
      @msg.send body
