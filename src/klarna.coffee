# Import modules
crypto = require 'crypto'
request = require 'request'
Promise = require 'promise'

# Flags
flags =
  live: false,
  initalized: false

# Credentials
credentials =
  eid: null
  secret: null

# Configuration (default: Sweden, SEK, Swedish)
config =
  purchase_country: 'SE'
  purchase_currency: 'SEK'
  locale: 'sv-se'
  merchant:
    id: null
    terms_uri: null
    checkout_uri: null
    confirmation_uri: null
    push_uri: null
  gui:
    layout: 'desktop'

# Klarna REST API constants
klarna =
  url:
    test: 'https://checkout.testdrive.klarna.com/checkout/orders'
    live: 'https://checkout.klarna.com/checkout/orders'
  headers:
    contentType: 'application/vnd.klarna.checkout.aggregated-order-v2+json'
    accept: 'application/vnd.klarna.checkout.aggregated-order-v2+json'


### PRIVATE ###

# Construct HTTP request according to Klarna specifications
httpRequest =

  # Set HTTP request headers
  headers: (payload) ->

    # Create (digestive) biscuit from payload and hash from biscuit
    biscuit = if payload? then JSON.stringify(payload) + credentials.secret else credentials.secret
    hash = crypto.createHash('sha256').update(biscuit, 'utf-8').digest('base64')

    # Return headers
    'Accept': klarna.headers.accept
    'Authorization': 'Klarna ' + hash,
    'Content-Type': klarna.headers.contentType

  # Set HTTP request options
  options: (data, id) ->
    # Set base url depending on live or test environment
    url = if flags.live then klarna.url.live else klarna.url.test
    # Return HTTP request options
    url: if id? then url + '/' + id else url
    headers: this.headers(data),
    body: data
    json: if data? then true else false

# Wrapper for all exported (order related) functions
wrapper = (f) ->

  # Module initalized?
  if not flags.initalized
    throw 'Klarna module not initialized. Please use init() method.'

  # All uris set?
  for key, value of config.merchant
    if not value?
      throw "Config error: #{key} not set"

  # If no problems -> return original function
  return f

# Parse HTTP response for error
parseError = (error, response, body) ->

  # If HTTP request error
  if error?
    return {
    type: 'HTTP'
    code: error.code
    message: error.message
    }

  # If Klarna error
  else if body
    body = if typeof body is 'string' then JSON.parse(body) else body
    return {
    type: 'Klarna'
    code: body.http_status_code + " - " + body.http_status_message
    message: body.internal_message
    }

### PUBLIC ###
publicMethods =

  # Initialize
  init: (input) ->

    if not input?
      throw "Missing init values"

    # Set merchant ID
    if input.eid?
      credentials.eid = input.eid
      config.merchant.id = input.eid

    # Set shared secret
    if input.secret?
      credentials.secret = input.secret

    # Set/unset test flag
    if input.live? and typeof input.live is 'boolean'
      flags.live = input.live

    # If success -> set flag 'initialized'
    if input.eid? and input.secret? then flags.initalized = true

  # Set config
  config: (input) ->

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

  # Place order
  place: (cart) ->
    f = () ->
      new Promise (resolve, reject) ->
        # New resource object based on config options
        resource = config
        # Add cart to resource
        resource.cart = cart
        # Construct HTTP request and send to Klarna

        request.post httpRequest.options(resource), (error, response, body) ->
          # Parse response for error.
          err = parseError(error, response, body)
          # If error -> reject with error
          if err?
            return reject err
          # Else, if OK from Klarna -> resolve with order id
          else if response.statusCode? and response.statusCode is 201
            # Get order url
            location = response.headers.location
            # Get id from url and resolve promise
            resolve location.slice(location.lastIndexOf('/') + 1)

    # Apply wrapper
    wrapper(f)()

  # Fetch order
  fetch: (id) ->
    f = () ->
      new Promise (resolve, reject) ->
        # Construct HTTP request and send to Klarna
        request.get httpRequest.options(null, id), (error, response, body) ->
          # If OK -> resolve promise with order
          if response?
            if response.statusCode is 200
              resolve JSON.parse(body)
          # Else -> reject with error
          else
            reject parseError(error, response, body)

    # Apply wrapper
    wrapper(f)()

  # Update order
  update: (id, data) ->
    f = () ->
      new Promise (resolve, reject) ->
        # Construct HTTP request and send to Klarna
        request.post httpRequest.options(data, id), (error, response, body) ->
          # If OK -> resolve promise with order
          if response?
            if response.statusCode? and response.statusCode is 200
              resolve body
          # Else -> reject promise with error
          else
            reject parseError(error, response, body)

    # Apply wrapper
    wrapper(f)()

  # Confirm order (with or without merchant order ids)
  confirm: (id, orderid1, orderid2) ->
    f = () ->
      new Promise (resolve, reject) ->
        # New status
        data = status: 'created'
        # If merchant reference(s), add to data to send
        if orderid1?
          data.merchant_reference = orderid1: orderid1
        if orderid2?
          data.merchant_reference.orderid2 = orderid2
        # Update order
        publicMethods.update(id, data).then(
          (order) ->
            resolve order
          (error) ->
            reject error
        )

    # Apply wrapper
    wrapper(f)()

# Export module
module.exports = publicMethods
