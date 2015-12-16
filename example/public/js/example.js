var cart = {
    items: [
        {
            name: 'Tin of spam',
            reference: '1234',
            quantity: 2,
            unit_price: 3400,
            tax_rate: 2500
        }
    ]
};

$(document).ready(function() {

    $("#button-order").on('click', function() {
        $.ajax({
            url: '/order',
            type: 'POST',
            data: JSON.stringify(cart),
            contentType: 'application/json; charset=utf-8',
            success: function(data)  {
                console.log("Received snippet");
                $("#klarna").html(data);
            },
            error: function(response) {
                console.log(response);
                $("#klarna").html("Error: " + response.responseText);
            }


        })
    })
});

