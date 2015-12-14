klarna = require './../src/klarna'

klarna.init {
  eid: '4421', secret: 'OLBJFchrgUm7u14'
}

cart = {
  items: [
    {
      name: 'Tin of spam'
      reference: 'food-1234',
      quantity: 1,
      unit_price: 3400,
      tax_rate: 2500
    }
  ]
}

klarna.place(cart).then (result) ->
    console.log "ID: " + result
  , (error) ->
    console.log error