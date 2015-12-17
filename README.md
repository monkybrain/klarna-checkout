# Klarna Checkout for nodejs #

Library for integrating Klarna Checkout in a nodejs environment. Works for merchants in Sweden, Norway, Finland, Austria and Germany.

Written in CoffeeScript for clarity, as are the examples below. JavaScript users, sprinkle curly braces accordingly...

Uses promises to handle async operations.

If you find this useful or want to contribute, please send me a line.

### Install ###
`npm install klarna-checkout`

### Usage ###

#### Initialize ####
```
klarna = require 'klarna-checkout'

klarna.init
  eid: <EID>
  secret <SHARED SECRET>
  live: <BOOLEAN>
```
Pass an object containing

* eid (string)
  * Merchant ID supplied by Klarna
* secret (string)
  * Shared secret supplied by Klarna
* live (boolean)
  * `true` Live environment
  * `false`  Test environment (default)

#### Configure ####
```
klarna.config
  purchase_country: <COUNTRY CODE>			
  purchase_currency: <CURRENCY CODE>		
  locale: <LOCALE CODE>											
  layout: <STRING>
  terms_uri: <URI>
  cancellation_terms_uri: <URI>
  checkout_uri: <URI>
  confirmation_uri: <URI>
  push_uri: <URI>
``` 

Pass an object containing
* purchase_country (string)
  * e.g. `'SE'` for Sweden (default)
* purchase_currency (string)
  * e.g. `'SEK'`  for Swedish Krona (default)
* locale (string)
  * e.g. `'sv-se'` for Swedish/Sweden (default)
* layout (string)
  * `'desktop'` (default)
  * `'mobile'`
* terms_uri (string)
* cancellation_terms_uri (string)
* checkout_uri (string)
* confirmation_uri (string)
* push_uri (string)

See [API Docs: resource](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#resource-properties) for more information



#### Place order ####
```
klarna.place cart 
```
Parameters
* cart (object)
  * See [API Docs: cart/cart item](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#cart-object-properties)  for instructions on how to format cart properly

Returns promise
  * resolved: Klarna Order ID (string)
  * rejected: error (string)


#### Fetch order ####
```
klarna.fetch id
```
Parameters
* id (string): Klarna Order ID

Returns promise
  * resolved: order (object)
  * rejected: error (string)

#### Confirm order ####
```
klarna.confirm id, orderid1, orderid2
```
Parameters
  * Required
    * id (string): Klarna Order ID
  * Optional
	* orderid1 (string): Merchant reference #1 (see [API docs: merchant reference](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#merchant_reference-object-properties))
	* orderid2 (string): Merchant reference #2 (see [API docs: merchant reference](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#merchant_reference-object-properties))

Returns promise
  * resolved: order (object)
  * rejected: error (string)

#### Update order ####
```
klarna.update id, data
```
Parameters
* id (string)
* data (object)
  * See [API docs: update](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#update) for valid keys

Returns promise
  * resolved: updated order (object)
  * rejected: error (string)

---

### Example ###
There is an example of a minimal nodejs server serving Klarna Checkout in the directory [`example/`](./example/)

---

### Used by ###
Hairtorial ([hairtorial.io](http://hairtorial.io))

---

### To be implemented ###
* Recurring orders
* Customization options (colors etc)

Any help is greatly appreciated!

---

### API Documentation ###
Check out Klarna's API documentation [here](https://developers.klarna.com/en).