# Klarna Checkout example server #

### Install dependencies ###
`npm install`

Also make sure you've run `npm install` in the root folder

### Edit merchant ID and shared secret ###
If you have a CoffeeScript transpiler installed, make the following changes to app.coffee
```
klarna.init
	eid: <MERCHANT ID>
	secret: <SHARED SECRET>
```
and transpile into js/app.js.

If you don't like CoffeeScript or don't have a transpiler installed, you can edit js/app.js directly
```
klarna.init({
	eid: <MERCHANT ID>
	secret: <SHARED SECRET>
});
```
Merchant ids and shared secrets are supplied by Klarna upon request.

### Start server ###
`npm start`

### View example ###
Open `localhost:3000/` in browser

