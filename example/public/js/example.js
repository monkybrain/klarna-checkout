// Example of a cart formatted according to Klarnas specification
var cart = {
    items: [
        {
            name: 'Tin of spam',
            reference: '1234',
            quantity: 2,
            unit_price: 3400,       // Instead of floats, Klarna uses integers representing
            tax_rate: 2500          // the original value x 100 (e.g. 34.00 SEK -> 3400)
        }
    ]
};

// On 'document ready' -> add eventlistener(s)
$(document).ready(function() {

    // Handle button click
    $("#button-order").on('click', function() {
        // Format and send HTTP request to local server
        $.ajax({
            url: '/order',
            type: 'POST',
            data: JSON.stringify(cart),
            contentType: 'application/json; charset=utf-8',
            // Handle successful response
            success: function(data)  {
                console.log("Received snippet");
                $("#klarna").html(data);
            },
            // Handle error
            error: function(response) {
                console.log(response);
                $("#klarna").html("Error: " + response.responseText);
            }
        })
    })
});

