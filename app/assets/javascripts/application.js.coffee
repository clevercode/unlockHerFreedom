#= require jquery
#= require jquery_ujs
#= require spin
#= require stripe.checkout
#= require underscore.min
#= require jquery.event.move
#= require jquery.event.swipe
#= require unslider
#= require_tree .

String.prototype.splice = (index, rem, s) ->
  (this.slice(0, index) + s + this.slice(index + Math.abs(rem)))

jQuery ->
  # Adds a class of alone for a sign post
  for item in $ 'header nav li'
    $item = $ item
    if $item.children().length < 1
      $item.addClass 'alone'

  # Handles flash notices
  $notices = $('.notice, .alert')
  if $notices.length
    setTimeout =>
      $notices.css top: -$notices.outerHeight()
      setTimeout =>
        $notices.remove()
      , 300
    , 5000

  # Grabs our API key from the meta tag
  Stripe.setPublishableKey $('meta[name="stripe-key"]').attr 'content'
  app.setupForms()

app =
  EVENT_TURN_PRICE: 20
  EVENT_TICKET_PRICE: 25

  setupForms: ->
    @_turns  = 0
    @_guests = 1
    @attachEventListeners()

  on: (event, selector, handler) ->
    $(window).on event, selector, $.proxy this, handler

  attachEventListeners: ->
    @on 'submit', '#new_message',       '_onMessageFormSubmit'
    @on 'submit', 'form.donation',      '_onDonationFormSubmit'
    @on 'submit', 'form.event',         '_onFundraiserFormSubmit'
    @on 'change', '#guests',            '_onNumberOfGuestsChange'
    @on 'change', '#turns',             '_onNumberOfTurnsChange'
    @on 'keyup',  'form.event #amount', '_onPaymentAmountKeyup'

  # event handlers
  # 

  _onMessageFormSubmit: (event) ->
    @form = $(event.currentTarget)
    @form.find('.inline-hints').hide().text ''
    @form.find('input[type=submit]').attr 'disabled', true
    errorsExist = @_checkMessageFields()
    off if errorsExist?

  _onDonationFormSubmit: (event) ->
    @form = $(event.currentTarget)
    @form.find('.inline-hints').hide().text ''
    @form.find('input[type=submit]').attr 'disabled', true
    @_showDonationStripeForm() unless @_checkDonationFields()
    off

  _onFundraiserFormSubmit: (event) ->
    @form = $(event.currentTarget)
    @form.find('.inline-hints').hide().text ''
    @form.find('input[type=submit]').attr 'disabled', true
    errors = @_checkDonationFields()
    if not errors?
      fundraiserErrors = @_checkFundraiserFields()
      if not fundraiserErrors?
        @_showFundraiserStripeForm()

    off

  _onNumberOfGuestsChange: (event) ->
    $input   = $ event.currentTarget
    @_guests = parseInt $input.val()
    @form    = $input.parents 'form'
    @_changePaymentAmount()

  _onNumberOfTurnsChange: (event) ->
    $input  = $ event.currentTarget
    @_turns = parseInt $input.val()
    @form   = $input.parents 'form'
    @_changePaymentAmount()

  _onPaymentAmountKeyup: (event) ->
    clearTimeout @_timeout
    @_timeout = setTimeout =>
      $input = $ event.currentTarget
      @form  = $input.parents 'form'
      @_changePaymentAmount yes
    , 500


  # private
  # 

  _clearErrors: ->
    @form.find('input').removeClass 'error'
    @form.find('.inline-hints').hide()

  _changePaymentAmount: (showError = no) ->
    @_clearErrors()
    errors  = undefined
    $input  = @form.find '#amount'
    value   = parseInt $input.val().replace '$', ''
    tickets = @_guests * @EVENT_TICKET_PRICE
    turns   = @_turns  * @EVENT_TURN_PRICE
    minimum = tickets + turns
    if value < minimum
      errors = true
      $input.val "$#{minimum}.00"
      if showError
        message = if @_turns > 0
          "A minimum of $#{@EVENT_TICKET_PRICE} per guest and $#{@EVENT_TURN_PRICE} per turn is required."
        else
          "A minimum of $#{@EVENT_TICKET_PRICE} per guest is required."

        @_throwError $input, message

    return errors

  _checkMessageFields: ->
    errors = undefined
    for input in @form.find 'input, textarea'
      $input = $(input).removeClass 'error'
      if $input.val().length < 1
        @_throwError $input
        errors = true
        break

    errors

  _checkDonationFields: ->
    errors = undefined
    for input in @form.find '#amount, #payment_email'
      $input = $(input).removeClass 'error'
      if $input.val().length < 1
        @_throwError $input
        errors = true
        break

    # If all inputs have something in them
    unless errors?
      $amount = @form.find '#amount'
      amount  = $amount.val().replace '$', ''
      amount  = amount.replace /,/g, ''

      # If it's a valid currency entry
      if /[0-9]+\.[0-9][0-9](?:[^0-9]|$)/.test amount
        amount = amount.replace /\./g, ''

        # If it's less than 50 cents
        if amount < 50
          errors = true
          @_throwError $amount, 'Please enter over 50¢.'

        # If it's a million dollars or more
        else if amount > 99999999
          errors = true
          @_throwError $amount, 'Sorry, UHF cannot process donations over $1,000,000.00.'

        # If it's an acceptable, valid amount, store it on the input
        else
          @form.find('#payment_amount').attr 'value', amount

      # If it's an invalid amount
      else
        errors = true
        @_throwError $amount, 'Invalid amount. Ex: $20.00'

    # Show the stripe form unless we came across some problems
    return errors

  _checkFundraiserFields: ->
    # Makes sure guests and turns are ints
    errors = undefined
    for input in @form.find '#guests, #turns'
      $input = $ input
      value  = parseInt $input.val()
      if not value and value isnt 0
        @_throwError $input, 'Invalid number. Ex: 2'
        errors = true
        break

    # Fix speedy users issue
    return true if errors?
    @_guests = parseInt @form.find('#guests').val()
    @_turns  = parseInt @form.find('#turns').val()
    errors   = @_changePaymentAmount()
    @form.find('input[type=submit]').attr('disabled', false) if errors?

    return errors

  _showDonationStripeForm: ->
    @form.find('input[type=submit]').attr 'disabled', false
    StripeCheckout.open
      key: $('meta[name="stripe-key"]').attr 'content'
      amount: @form.find('#payment_amount').val()
      name: 'Unlock Her Freedom'
      description: "Donation (#{@form.find('#amount').val()})"
      panelLabel: 'Donate'
      token: $.proxy @, '_handleStripeResponse'
      image: '/assets/logo-stripe.jpg'

  _showFundraiserStripeForm: ->
    description  = "#{@form.find('#guests').val()} "
    description += if @_guests > 1 then 'Tickets' else 'Ticket'
    if turns > 0
      description += " & #{turns} "
      description += if @_turns > 1 then 'Turns' else 'Turn'
      description += ' at the gift card tree.'

    @form.find('input[type=submit]').attr 'disabled', false
    StripeCheckout.open
      key: $('meta[name="stripe-key"]').attr 'content'
      amount: @form.find('#payment_amount').val()
      name: 'A Night For Freedom'
      description: description
      panelLabel: 'Pay'
      token: $.proxy @, '_handleStripeResponse'
      image: '/assets/logo-stripe.jpg'

  _handleStripeResponse: (response) ->
    guests    = parseInt @form.find('#guests').val()
    turns     = parseInt @form.find('#turns').val()
    newFields = """
      <input type="hidden" name="turns" value="#{turns}" />
      <input type="hidden" name="guests" value="#{guests}" />
      <input type="hidden" name="stripeToken" value="#{response.id}" />
      <input type="hidden" name="name" value="#{response.card.name}" />
    """

    @form.append newFields
    @form[0].submit()

  # Shows the error message and adds a class of error
  _throwError: ($input, message = 'Required.') ->
    @form.find('input[type=submit]').attr 'disabled', false
    $input.siblings('.inline-hints').show().text message
    $input.focus().addClass 'error'
