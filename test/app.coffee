# Imports
express = require "express"
klarna = require './../src/klarna'

# Klarna setup
klarna.init
  # ASK KLARNA FOR TEST CREDENTIALS!
  eid: ''
  secret: ''
  test: true

klarna.config
  terms_uri: 'http://www.example.com'
  cancellation_terms_uri: 'http://www.example.com'
  checkout_uri: 'http://www.example.com'
  confirmation_uri: 'http://www.example.com'
  push_uri: 'http://www.example.com'

# Klarna formatted cart
cart = {
  items: [
    {
      name: 'Spam'
      reference: '1234',
      quantity: 1,
      unit_price: 3400,
      tax_rate: 2500
    }
  ]
}

app = express()
app.set('view-options', {pretty: true})

# Start process on simple GET request
app.get '/', (req, res) ->
  # Place order
  klarna.place(cart)
  # Fetch order
  .then(
    (id) ->
      klarna.fetch(id)
    (error) ->
      res.send error
  # Return snippet
  ).then(
    (order) ->
      html =
        '<div style="text-align: center; font-family: Helvetica, sans-serif">' +
        'Order id: ' + order.id + '<br><br>' +
        'Open <a href="localhost:3000/' + order.id + '">this link</a> in another browser tab and reload the page when you have completed your checkout to confirm your purchase.' +
        order.gui.snippet
      res.send html
    (error) ->
      res.send error
  )

app.get '/:id', (req, res) ->
  if req.params.id?
    klarnaId = req.params.id
    myId = 'my_ref_01'
    klarna.confirm(klarnaId, myId).then(
      (order) ->
        res.send order.gui.snippet
      (error) ->
        res.send error
    )

server = app.listen 3000, () ->
  host = server.address().address
  port = server.address().port
  console.log 'Klarna Test Server running at http://%s:%s', host, port
  console.log 'Enter address above in browser to make a test purchase', host, port
