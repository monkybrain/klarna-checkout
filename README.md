# Klarna Checkout integration with nodejs #

Library for integrating Klarna Checkout in a nodejs environment.
Uses promises to handle async operations.
Still working on the first version of this project.
I hope to push it to this repository by the end of this week (i.e. by 18 dec 2015).

## Install ##
`npm install klarna-checkout`

## Usage ##

### Get started ###
CoffeeScript:
```
klarna = require 'klarna-checkout'

# Initalize
klarna.init
  eid: <EID>
  secret <SHARED SECRET>

# Configure
klarna.config
  purchase_country: <COUNTRY CODE (ISO-3166-alpha2)>    # default: SE (Sweden)
  purchase_currency: <CURRENCY CODE (ISO-4217)>         # default: SEK (Swedish Krona)
  locale: <LOCALE (RFC1766)>                            # default: sv-se (Swedish, Sweden)
  terms_uri: <URI>
  cancellation_terms_uri: <URI>
  checkout_uri: <URI>
  confirmation_uri: <URI>
  push_uri: <URI>
``` 
JavaScript:
```
var klarna = require('klarna-checkout')

// Initialize
klarna.init({
  eid: <EID>,
  secret <SHARED SECRET>
})

// Configure
klarna.config({
  purchase_country: <COUNTRY CODE (ISO-3166-alpha2)>,   // default: SE (Sweden)
  purchase_currency: <CURRENCY CODE (ISO-4217)>,        // default: SEK (Swedish Krona)
  locale: <LOCALE (RFC1766)>,                           // default: sv-se (Swedish, Sweden)
  terms_uri: <URI>,
  cancellation_terms_uri: <URI>,
  checkout_uri: <URI>,
  confirmation_uri: <URI>,
  push_uri: <URI>
})
```

### Place order ###
CoffeeScript:
```
klarna.place cart 
```
JavaScript:
```
klarna.place(cart)
```
Parameters:
* cart (object):
  * See Klarna's API Documentation for instructions on how to format cart properly

Returns:
* Promise
  * resolve: id (string)
  * reject: error (string)


### Fetch order ###
CoffeeScript:
```
klarna.fetch id
```
JavaScript:
```
klarna.fetch(id)
```
Parameters:
* id (string)

Returns:
* Promise
  * resolve: order (object)
  * reject: error (string)

### Update order ###
CoffeeScript:
```
klarna.update id, data
```
JavaScript:
```
klarna.fetch(id, data)
```
Parameters:
* id (string)
* data (object)
  * See Klarna's API documentation for valid keys

Returns:
* Promise
  * resolve: updated order (object)
  * reject: error (string)


## To be implemented ##
* Recurring orders
* Custom options

Any help is greatly appreciated!

## API Documentation ##
Check out Klarna's API documentation [here](https://developers.klarna.com/en'). 