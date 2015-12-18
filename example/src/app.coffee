# Import modules
try
  express = require "express"
  klarna = require "klarna-checkout"
  bodyParser = require "body-parser"
  colors = require "colors"
  fs = require "fs"
catch err
  console.log "ERROR! Required modules not installed. Please run 'npm install'\n"
  return

# Read config.json
try
  cfg = fs.readFileSync 'credentials.json', 'utf-8'
catch err
  console.error "ERROR! 'credentials.json' not found. Please run 'npm run-script setup'.\n".red
  return

# Parse config.json
try
  cfg = JSON.parse cfg
catch err
  console.error "ERROR! Invalid 'credentials.json' file. Please run 'npm run-script setup'.\n".red
  return

# Initialize module with credentials stored in credentials.json
klarna.init
  eid: cfg.eid
  secret: cfg.secret

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

# Format order data as html (not very elegant, I know...)
order2html = (order) ->
  html = ''
  # Parse 1st order keys
  for key, value of order
    # If value is key, parse 2nd order keys
    if typeof value is 'object'
      html += '<strong>' + key + '</strong><br>'
      for key, val2 of value
        # Prevent snippet from rendering in browser...
        if key is 'snippet' then val2 = '(We don\'t want to render this now...)'
        # Add indented row
        html += '&nbsp;&nbsp;' + key + ': ' + val2 + '<br>'
    else
      html += key + ': ' + value + '<br>'
  return html

# On POST from webshop -> place order and return checkout snippet
app.post '/order', (req, res) ->

  # 1) Place order
  console.log "Placing order"
  klarna.place(req.body)

  # 2) If success -> fetch order
  .then(
    # Success
    (id) ->
      # Fetch order by id
      klarna.fetch id
    # Error
    (error) ->
      res.status(500).send error
  )

  # 3) If success -> return snippet
  .then(
    # Success
    (order) ->
      console.log "Snippet received"
      # Return snippet
      res.send order.gui.snippet
    # Error
    (error) ->
      res.status(500).send error
  )

# On GET from Klarna -> confirm order and return confirmation snippet
app.get '/confirmation', (req, res) ->
  # Log to console
  console.log "Confirming order"
  # Parse id
  id = req.query.klarna_order_id

  # 1) Confirm order (with merchant order reference)
  klarna.confirm id, '1000'

  # 2) If success -> return snippet
  .then(
    # Success
    (order) ->
      # Log to console
      console.log "Order confirmed"
      # Initialize html string from snippet
      html = order.gui.snippet
      # Add link to snippet html
      html += '<div style="font-family: Helvetica, sans-serif; text-align: center"><a href="/order/' + id + '">View order</a>'
      # Return html
      res.send html
    # Error
    (error) ->
      res.status(500).send error
  )

app.get '/order/:id', (req, res) ->
  # Parse order id
  id = req.params.id

  # 1) Fetch order
  klarna.fetch(id)
  # 2) Return order data
  .then(
    # Success
    (order) ->
      # Format HTML output (not very elegant, I know...)
      res.send order2html order
    # ...or error
    (error) ->
      res.status(500).send error
  )

# Run local server on port 3000
server = app.listen 3000, 'localhost', () ->
  port = server.address().port
  console.log "Klarna Checkout example server is up and running!".green
  console.log "Visit http://localhost:#{port} in a browser to try it.".green
