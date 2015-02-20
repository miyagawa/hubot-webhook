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

To identify the incoming HTTP requests from other bot instances, you can set a static, extra list of parameter(s) in `HUBOT_WEBHOOK_PARAMS` that will be sent to the webhook URL along with the message.

    > export HUBOT_WEBHOOK_PARAMS="token=1234567890"

### HUBOT_WEBHOOK_HMAC_SECRET

To verify that the request comes from this bot, you can set an HMAC secret key that should be shared between Hubot and the receiver.

    > export HUBOT_WEBHOOK_HMAC_SECRET=a068a22dbe1b0a577d3800a3233f5a23693ae920

    miyagawa> /weather 94107
    # -> POST ...
    #    X-Webhook-Signature: sha1=dbdadeb3c4615399acd809cfb0d996ba0f31db41

The signature is generated using HMAC's hexdigest using SHA1 algorithm, in such a way (in Node):

    var crypto = require('crypto');
    'sha1=' + crypto.createHmac('sha1', 'SECRET').update(post_body).digest('hex');

If you're using Ruby, the same signature can be generated as:

    require 'openssl'
    'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), 'SECRET', post_body)

See also [how to validate GitHub's webhooks](https://developer.github.com/webhooks/securing/#validating-payloads-from-github) which uses the same technique, but with a different header name.

### HUBOT_WEBHOOK_METHOD

You can set `HUBOT_WEBHOOK_METHOD` to `GET` to send the webhook as a GET rather than a POST request.
    
## Author

Tatsuhiko Miyagawa

## License

MIT

