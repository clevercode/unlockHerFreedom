#= require jquery
#= require jquery_ujs
#= require spin
#= require stripe.checkout
#= require underscore.min
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
  setupForms: ->
    @attachEventListeners()

  attachEventListeners: ->
    $(window).on 'submit', '#new_message', $.proxy @, '_onMessageFormSubmit'
    $(window).on 'submit', '#new_payment', $.proxy @, '_onDonationFormSubmit'

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
    @_checkDonationFields()
    off

  # private
  # 

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
        @_throwError $amount, 'Invalid amount. Ex: 5.00'

    # Show the stripe form unless we came across some problems
    @_showStripeForm() unless errors?

  _showStripeForm: ->
    @form.find('input[type=submit]').attr 'disabled', false
    StripeCheckout.open
      key: $('meta[name="stripe-key"]').attr 'content'
      amount: @form.find('#payment_amount').val()
      name: 'Unlock Her Freedom'
      description: "Donation (#{@form.find('#amount').val()})"
      panelLabel: 'Donate'
      token: $.proxy @, '_handleStripeResponse'
      image: '/assets/logo-stripe.jpg'

  _handleStripeResponse: (response) ->
    newFields = """
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
