# Klarna Checkout for nodejs #

Library for integrating Klarna Checkout in a nodejs environment. Works for merchants in Sweden, Norway, Finland, Austria and Germany. Uses promises to handle async operations.

Work still in progress...

If you find this useful or want to contribute, please send me a line.

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
  test: true											# default: true

# Configure
klarna.config
  purchase_country: <COUNTRY CODE (ISO-3166-alpha2)>    # default: 'SE' (Sweden)
  purchase_currency: <CURRENCY CODE (ISO-4217)>         # default: 'SEK' (Swedish Krona)
  locale: <LOCALE (RFC1766)>                            # default: 'sv-se' (Swedish, Sweden)
  layout: <'desktop' or 'mobile'>						# default: 'desktop'
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
  secret <SHARED SECRET>,
  test: true											// default: true
});

// Configure
klarna.config({
  purchase_country: <COUNTRY CODE (ISO-3166-alpha2)>,   // default: 'SE' (Sweden)
  purchase_currency: <CURRENCY CODE (ISO-4217)>,        // default: 'SEK' (Swedish Krona)
  locale: <LOCALE (RFC1766)>,                           // default: 'sv-se' (Swedish, Sweden)
  layout: <'desktop' or 'mobile'>						// default: 'desktop'
  terms_uri: <URI>,
  cancellation_terms_uri: <URI>,
  checkout_uri: <URI>,
  confirmation_uri: <URI>,
  push_uri: <URI>
});
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
  * See [API Docs: cart/cart item](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#cart-object-properties)  for instructions on how to format cart properly

Returns:
* Promise
  * result: Klarna ID (string)
  * reason: error (string)


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
* id (string): Klarna ID

Returns:
* Promise
  * result: order (object)
  * reason: error (string)

### Confirm order ###
CoffeeScript:
```
klarna.confirm id, [orderid1, orderid2]
```
JavaScript:
```
klarna.confirm(id, [orderid1, orderid2])
```
Parameters:
  * Required:
    * id (string): Klarna ID
  * Optional:
	* orderid1 (string, optional): Merchant reference #1 (see [API docs: merchant reference](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#merchant_reference-object-properties))
	* orderid2 (string): Merchant reference #2 (see [API docs: merchant reference](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#merchant_reference-object-properties))

Returns:
* Promise
  * result: order (object)
  * reason: error (string)

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
  * See [API docs: update](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#update) for valid keys

Returns:
* Promise
  * result: updated order (object)
  * reason: error (string)

## Example ##
See the test folder for a (somewhat) working example of a minimal nodejs server serving Klarna Checkout.

## Used by ##
Hairtorial ([hairtorial.io](http://hairtorial.io))

## To be implemented ##
* Recurring orders
* Custom options

Any help is greatly appreciated!

## API Documentation ##
Check out Klarna's API documentation [here](https://developers.klarna.com/en).