# Import modules
crypto = require 'crypto'
request = require 'request'
Promise = require 'promise'

# Flags
flags = {
  test: true,
  initalized: false
}

# Credentials
credentials = {
  eid: null
  secret: null
}

# Configuration (default: Sweden, SEK, Swedish)
config = {
  purchase_country: 'SE',
  purchase_currency: 'SEK',
  locale: 'sv-se',
  merchant:
    id: null
    terms_uri: null
    cancellation_terms_uri: null
    checkout_uri: null
    confirmation_uri: null
    push_uri: null
  gui:
    layout: 'desktop'
}

# Klarna stuff
klarna = {
  url:
    test: 'https://checkout.testdrive.klarna.com/checkout/orders'
    live: 'https://checkout.klarna.com/checkout/orders'
}

# Construct HTTP request according to Klarna specifications
httpRequest = {

  # Set HTTP request headers
  headers: (payload) ->

    # Create (digestive) biscuit from payload and hash from biscuit
    biscuit = if payload? then JSON.stringify(payload) + credentials.secret else credentials.secret
    hash = crypto.createHash('sha256').update(biscuit).digest('base64')

    # Return headers
    'Authorization': 'Klarna ' + hash,
    'Content-Type': 'application/vnd.klarna.checkout.aggregated-order-v2+json',
    'Accept': 'application/vnd.klarna.checkout.aggregated-order-v2+json'

  # Set HTTP request options
  options: (data, id) ->
    # Test or live environment?
    url = if flags.test then klarna.url.test else klarna.url.live
    # Return HTTP request options
    url: if id? then url + '/' + id else url
    headers: this.headers(data),
    body: data
    json: if data? then true else false
}

# EXPORT: Initialize
exports.init = (input) ->

  # Set merchant ID
  if input.eid?
    credentials.eid = input.eid
    config.merchant.id = input.eid

  # Set shared secret
  if input.secret?
    credentials.secret = input.secret

  # Set/unset test flag
  if input.test? and typeof input.test is 'boolean'
    flags.test = input.test

  # If success -> set flag 'initialized'
  if input.eid? and input.secret? then flags.initalized = true

# EXPORT: Set config
exports.config = (input) ->

  # Country, language and currency
  if input.purchase_country?
    config.purchase_country = input.purchase_country
  if input.purchase_currency?
    config.purchase_currency = input.purchase_currency
  if input.locale?
    config.locale = input.locale

  # Layout
  if input.layout?
    if input.layout is 'desktop' or input.layout is 'mobile'
      config.gui.layout = input.layout

  # Uris
  if input.terms_uri?
    config.merchant.terms_uri = input.terms_uri
  if input.cancellation_terms_uri?
    config.merchant.cancellation_terms_uri = input.cancellation_terms_uri
  if input.checkout_uri?
    config.merchant.checkout_uri = input.checkout_uri
  if input.confirmation_uri?
    config.merchant.confirmation_uri = input.confirmation_uri
  if input.push_uri?
    config.merchant.push_uri = input.push_uri


# Wrapper for all exported (order related) functions
wrapper = (f) ->

# Module initalized?
  if not flags.initalized
    return () ->
      new Promise (resolve, reject) ->
        reject 'Klarna module not initialized. Please use init() method.'

  # All uris set?
  for key, value of config.uris
    if not value?
      return () ->
        new Promise (resolve, reject) ->
          reject "'%s' not set", key
      break

  return f

parseError = (error, response, body) ->

  if error
    return {
    type: 'HTTP Request'
    code: error.code
    message: error.message
    }

  else if body
    console.log "Klarna error"
    return {
    type: 'Klarna'
    code: body.http_status_code + " - " + body.http_status_message
    message: body.internal_message
    }

# EXPORT: Place order
exports.place = (cart) ->

  # Unwrapped function
  place = () ->
    new Promise (resolve, reject) ->
      # New resource object based on config options
      resource = config
      # Add cart to resource
      resource.cart = cart
      # Construct HTTP request and send to Klarna
      request.post httpRequest.options(resource), (error, response, body) ->
        # Parse response for error.
        err = parseError(error, response, body)
        # If error -> reject with error as reason
        if err?
          return reject err
        # Else, if OK from Klarna -> resolve with order id from Klarna
        else if response.statusCode? and response.statusCode is 201
          # Get order url
          location = response.headers.location
          # Get id from url and resolve promise
          resolve location.slice(location.lastIndexOf('/') + 1)

  # Apply wrapper
  wrapper(place)()

# EXPORT: Fetch order
exports.fetch = (id) ->

  # Unwrapped function
  fetch = () ->
    new Promise (resolve, reject) ->
      # Construct HTTP request and send to Klarna
      request.get httpRequest.options(null, id), (error, response, body) ->
        # If OK -> resolve promise with order
        if response.statusCode? and response.statusCode is 200
          resolve JSON.parse(body)
        # Else -> reject with error
        else
          reject parseError(error, response, JSON.parse(body))

  # Apply wrapper
  wrapper(fetch)()

# EXPORT: Update order
exports.update = (id, data) ->

  # Unwrapped function
  update = () ->
    new Promise (resolve, reject) ->
      # Construct HTTP request and send to Klarna
      request.post httpRequest.options(data, id), (error, response, body) ->
        # If OK -> resolve promise with order
        if response.statusCode? and response.statusCode is 200
          resolve body
        # Else -> reject promise with error
        else
          reject parseError(error, response, body)

  # Apply wrapper
  wrapper(update)()

# EXPORT: Confirm order (with or without merchant order ids"
exports.confirm = (id, orderid1, orderid2) ->

  # Unwrapped function
  confirm = () ->
    new Promise (resolve, reject) ->
      # New status
      data = {status: 'created'}
      # If merchant reference(s), add to data to send
      if orderid1?
        data.merchant_reference = {orderid1: orderid1}
      if orderid2?
        data.merchant_reference.orderid2 = orderid2
      # Update order
      exports.update(id, data).then(
        (order) ->
          resolve order
        (error) ->
          reject error
      )

  # Apply wrapper
  wrapper(confirm)()