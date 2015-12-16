# Imports
express = require "express"
klarna = require "./../../src/js/klarna"
bodyParser = require "body-parser"

### ENTER YOUR MERCHANT ID AND SHARED SECRET HERE ###
klarna.init
  eid: ''
  secret: ''

# Set urls (while using default country, language and currency settings)
klarna.config
  terms_uri: 'http://www.example.com'
  cancellation_terms_uri: 'http://www.example.com'
  checkout_uri: 'http://www.example.com'
  confirmation_uri: 'http://localhost:3000/confirmation?klarna_order_id={checkout.order.id}'
  push_uri: 'http://www.example.com'

# Create express app
app = express()
# Add body parser middleware
app.use bodyParser.json()
# Serve public folder on '/'
app.use express.static 'public'

# POST: Place order
app.post '/order', (req, res) ->
  # 1) Place order and log to console
  console.log "Placing order"
  klarna.place(req.body)
  .then(
    # 2) Fetch order by id
    (id) ->
      # In a live environment you should wait for a push notification from Klarna before confirming the order
      klarna.fetch id
    (error) ->
      res.status(500).send error
  )
  .then(
    # 3) Return snippet...
    (order) ->
      console.log "Snippet received"
      res.send order.gui.snippet
    # ...or error
    (error) ->
      res.status(500).send error
  )

# GET: Confirm order
app.get '/confirmation', (req, res) ->
  On confirmation, get order id and log to console
  id = req.query.klarna_order_id
  console.log "Confirming order"
  # 1) Confirm order with Klarna
  klarna.confirm id, '1000'
  .then(
    # 2) Return snippet...
    (order) ->
      console.log "Order confirmed"
      html = order.gui.snippet
      # Add link to snippet html
      html += '<div style="font-family: Helvetica, sans-serif; text-align: center"><a href="/order/' + id + '">View order</a>'
      res.send html
    # ...or error
    (error) ->
      res.status(500).send error
  )

app.get '/order/:id', (req, res) ->
  # Parse order id
  id = req.params.id
  # 1) Fetch order
  klarna.fetch(id)
  .then(
    #) 2 Return order data...
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
    # ...or error
    (error) ->
      res.status(500).send error
  )

# Run local server on port 3000
server = app.listen 3000, 'localhost', () ->
  host = server.address().address
  port = server.address().port
  console.log "Klarna Checkout example server is up and running!"
  console.log "Visit http://#{host}:#{port} in browser to try it."
