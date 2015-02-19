# hubot-webhook

Generic Webhook plugin for Hubot

## Description

This hubot script sends incoming messages to a remote Webhook URL as an HTTP POST request, and if there's a response back from the webhook, renders the text as a reply.

The remote webhook has a compatibility with [Slack's Custom Slash Commands](https://api.slack.com/slash-commands), and the POST body would look like:

```
room_id=1&
room_name=chatroom&
user_id=123&
user_name=miyagawa&
text=hello+world
```

The response body will be rendered as a reply when the response is 200. Any non-200 response will be ignored.

## Installation

    > npm install --save hubot-webhook

## Configuration

### HUBOT_WEBHOOK_URL

`HUBOT_WEBHOOK_URL` is a required environment variable to set the webhook endpoint.

    > export HUBOT_WEBHOOK_URL=https://your-handler.herokuapp.com/

### HUBOT_WEBHOOK_COMMANDS

By default, all incoming messages addressed to Hubot will be sent to the Webhook URL:

    miyagawa> hubot weather 94107
    # -> POST ${HUBOT_WEBHOOK_URL} ...&text=weather+94107

If you want to limit the commands, you can set them in `HUBOT_WEBHOOK_COMMANDS` as a comma-separated list.

    > export HUBOT_WEBHOOK_COMMANDS=weather,stock,deploy

    miyagawa> hubot weather 94107
    # -> command=weather&text=94107
    
    miyagawa> hubot stock $AAPL
    # -> command=stock&text=$AAPL
    
    miyagawa> hubot deploy production master
    # -> command=deploy&text=production+master
    
    miyagawa> hubot hello
    # (ignored)

Hubot's aliasing feature would be useful if you want it act like a slash command:

    > export HUBOT_ALIAS=/

    miyagawa> /weather 94107
    # -> command=weather&text=94107

### HUBOT_WEBHOOK_PARAMS

To verify that the request comes from this bot, you can set an extra parameter(s) in `HUBOT_WEBHOOK_PARAMS` that will be sent to the webhook URL along with the message.

    > export HUBOT_WEBHOOK_PARAMS="token=1234567890"
    
## Author

Tatsuhiko Miyagawa

## License

MIT

