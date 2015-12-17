prompt = require "prompt"
fs = require "fs"

# Define prompt schemas
schemas =
  input:
    properties:
      eid:
        required: true
        message: '\n  Merchant id (eid):'.white
      secret:
        required: true
        message: '  Shared secret:'.white
  confirmation:
    properties:
      confirmation:
        required: true
        default: 'yes'
        message: '\nIs this correct, yes/no?'.white

# Config prompt
prompt.message = ''
prompt.delimiter = ''

# Start prompt
prompt.start()

# Write welcome message to console
console.log "\nSetting up Klarna Checkout example server".green

# Main function
run = () ->
  prompt.get schemas.input, (err, result) ->
    # Create credentials object
    credentials =
      eid: result.eid
      secret: result.secret
    # Display entered input
    console.log '\nYou entered:'.green
    console.log '\n  eid: ' + result.eid
    console.log '  secret: ' + result.secret
    # Prompt for confirmation
    prompt.get schemas.confirmation, (err, result) ->
      # If no -> rinse and repeat
      if result.confirmation is 'no'
        run()
      # Else -> write to file and exit
      else
        fs.writeFileSync 'credentials.json', JSON.stringify(credentials)
        console.log "\nSetup complete!\n".green

# Run script
run()

