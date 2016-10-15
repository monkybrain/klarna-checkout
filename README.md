# Klarna Checkout for Node.js #

Library for using Klarna Checkout with Node.js. Works for merchants in Sweden, Norway, Finland, Austria and Germany.

Uses promises for async operations.

If you find this useful or want to contribute, please send me a line.

### Install ###
`npm install klarna-checkout`

### Usage ###

#### Initialize ####
```
klarna = require('klarna-checkout')

klarna.init({
  eid: <STRING>
  secret: <STRING>
  live: <BOOLEAN>
})
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
klarna.config({
  purchase_country: <STRING>			
  purchase_currency: <STRING>		
  locale: <STRING>											
  layout: <STRING>
  terms_uri: <STRING>
  cancellation_terms_uri: <STRING>
  checkout_uri: <STRING>
  confirmation_uri: <STRING>
  push_uri: <STRING>
})
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
klarna.place(cart)
```
Parameters
* cart (object)
  * See [API Docs: cart/cart item](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#cart-object-properties)  for instructions on how to format cart properly

Returns promise
  * resolved: Klarna order id (string)
  * rejected: [error (object)](#error)


#### Fetch order ####
```
klarna.fetch(id)
```
Parameters
* id (string): Klarna order id

Returns promise
  * resolved: order (object)
  * rejected: [error (object)](#error)

#### Confirm order ####
```
klarna.confirm(id, orderid1, orderid2)
```
Parameters
  * Required
    * id (string): Klarna order id
  * Optional
	* orderid1 (string): Merchant reference #1 (see [API docs: merchant reference](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#merchant_reference-object-properties))
	* orderid2 (string): Merchant reference #2 (see [API docs: merchant reference](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#merchant_reference-object-properties))

Returns promise
  * resolved: order (object)
  * rejected: [error (object)](#error)

#### Update order ####
```
klarna.update(id, data)
```
Parameters
* id (string)
* data (object)
  * See [API docs: update](https://developers.klarna.com/en/se+php/kco-v2/checkout-api#update) for valid keys

Returns promise
  * resolved: updated order (object)
  * rejected: error (string)

---
### <a name="error"></a> Error object ###

* type (string):
  * `'HTTP'` - HTTP request error (e.g. if network is down)
  * `'Klarna'` - HTTP request ok but Klarna responded with an error
* code (string)
* message (sting)

---

### Example ###
There is an example of a minimal Node.js Express server serving Klarna Checkout in [example/](./example/)

---

### To be implemented ###
* Recurring orders
* Customization options (colors etc)

Any help is greatly appreciated!

---

### API Documentation ###
Check out Klarna's API documentation [here](https://developers.klarna.com/en).
