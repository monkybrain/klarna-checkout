request = require 'request'
crypto = require 'crypto'
Promise = require 'promise'

# General flags
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
    terms_uri: 'http://www.example.com'
    cancellation_terms_uri: 'http://www.example.com'
    checkout_uri: 'http://www.example.com'
    confirmation_uri: 'http://www.example.com'
    push_uri: 'http://www.example.com'
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
  options: (data) ->

    # Return HTTP request options
    url: if flags.test then klarna.url.test else klarna.url.live
    headers: this.headers(data),
    body: data,
    json: true
}

# EXPORT: Initialize
exports.init = (input) ->
  if input.eid?
    credentials.eid = input.eid
    config.merchant.id = input.eid
  if input.secret?
    credentials.secret = input.secret
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
    f = () ->
      new Promise (resolve, reject) ->
        reject 'Klarna module not initialized. Please use init() method.'

  # All uris set?
  for key, value of config.uris
    if not value?
      f = () ->
        new Promise (resolve, reject) ->
          reject "'" + key + "'" + ' not set'
      break

  return f

# EXPORT: Place order
exports.place = (cart) ->

  # Define function
  place = () ->
    new Promise (resolve, reject) ->
      data = config
      data.cart = cart
      request.post httpRequest.options(data), (error, response, body) ->
        if error
          reject "HTTP Request error: " + error.code
          return
        if body
          reject "Klarna Error: " + body.http_status_code + ", " + body.http_status_message + " - " + body.internal_message
          return
        if response.statusCode?
          if response.statusCode is 201
            location = response.headers.location
            id = location.slice(location.lastIndexOf('/') + 1)
            resolve id

  # Apply wrapper
  wrapper(place)()


exports.fetch = (id) ->
  new Promise (resolve, reject) ->

exports.update = (id, data) ->
  new Promise (resolve, reject) ->

exports.confirm = (id, reference) ->
  new Promise (resolve, reject) ->

exports.test = () ->
  console.log httpRequest.options({test: 'fisk'})