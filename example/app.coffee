# Imports
express = require "express"
klarna = require "./../../src/js/klarna"
bodyParser = require "body-parser"
jsonMarkup = require "json-markup"

### ASK KLARNA FOR TEST CREDENTIALS! ###
klarna.init
  eid: ''
  secret: ''

klarna.config
  terms_uri: 'http://www.example.com'
  cancellation_terms_uri: 'http://www.example.com'
  checkout_uri: 'http://www.example.com'
  confirmation_uri: 'http://localhost:3000/confirmation?klarna_order_id={checkout.order.id}'
  push_uri: 'http://www.example.com'

app = express()
app.use bodyParser.json()
app.use express.static 'public'

# POST: Place order
app.post '/order', (req, res) ->
  # 1) Place order
  klarna.place(req.body)
  .then(
    # 2) Fetch order by id
    (id) ->
      console.log "Placing order"
      # In a live environment you should wait for a push notification from Klarna before confirming the order
      klarna.fetch id
    (error) ->
      res.status(500).send error
  )
  .then(
    # 3) Return snippet
    (order) ->
      console.log "Snippet received"
      res.send order.gui.snippet
    (error) ->
      res.send error
  )

# GET: Confirm order
app.get '/confirmation', (req, res) ->
  id = req.query.klarna_order_id
  console.log "Confirming order"
  klarna.confirm id, '1000'
  .then(
    (order) ->
      console.log "Order confirmed"
      html = order.gui.snippet
      html += '<div style="font-family: Helvetica, sans-serif; text-align: center"><a href="/order/' + id + '">View order</a>'
      res.send html
    (error) ->
      res.send error
  )

app.get '/order/:id', (req, res) ->
  id = req.params.id
  # Fetch order
  klarna.fetch(id)
  .then(
    (order) ->
      # Format HTML output (not very elegant, I know...)
      html = ''
      for key, value of order
        if typeof value is 'object'
          html += '<strong>' + key + '</strong><br>'
          for key, val2 of value
            if key is 'snippet'
              val2 = '(We don\'t want to render this now...)'
            html += '&nbsp;&nbsp;' + key + ': ' + val2 + '<br>'
        else
          html += key + ': ' + value + '<br>'
      res.send html
    (error) ->
      res.send error
  )

server = app.listen 3000, 'localhost', () ->
  host = server.address().address
  port = server.address().port
  console.log "Klarna Checkout example server is up and running!"
  console.log "Visit http://#{host}:#{port} in browser to try it."
