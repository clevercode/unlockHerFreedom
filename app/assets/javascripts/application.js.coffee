#= require jquery
#= require jquery_ujs
#= require spin
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
  $('.notice').on 'click', ->
    $notice = $ event.currentTarget
    $notice.fadeOut -> $notice.remove()

  # Handles clicks on our overlay
  $('#darknessification').on 'click', ->
    $('#darknessification, #new_payment .card-info').hide()

  # Grabs our public API key from the meta tag
  Stripe.setPublishableKey $('meta[name="stripe-key"]').attr 'content'
  payment.setupForm()

payment =
  setupForm: ->
    payment.attachEventListeners()

  attachEventListeners: ->
    $('#new_payment button').on 'click', payment.onButtonClick
    $('#new_payment a.cancel').on 'click', payment.onCancelClick
    $('#new_payment #card-number').on 'keyup', payment.onCardKeyUp
    $('#new_payment #card-number').on 'blur', payment.onCardBlur
    $('#new_payment').on 'keypress', payment.onKeyPress
    $('#new_payment').on 'submit', payment.onSubmit

  onButtonClick: ->
    $($('#new_payment li.error')[0]).hide().text ''
    payment.checkRequiredFields()
    off

  onCancelClick: ->
    $('#darknessification').click()
    off

  onCardKeyUp: (event) ->
    $input = $(event.currentTarget)
    value  = $input.val().split('-').join ''

    # Unless we're deleting characters
    unless event.keyCode is 8
      length = value.length

      # If there is text
      if length > 3 and length < 13 and length % 4 is 0
        $input.attr 'value', $input.val() + '-'

    # visa
    if /^4[0-9]{12}(?:[0-9]{3})?$/.test value
      $input.css backgroundPosition: '3px -37px'

    # mastercard
    else if /^5[1-5][0-9]{14}$/.test value
      $input.css backgroundPosition: '3px -77px'

    # discover
    else if /^6(?:011|5[0-9]{2})[0-9]{12}$/.test value
      $input.css backgroundPosition: '3px -117px'

    # american express
    else if /^3[47][0-9]{13}$/.test value
      $input.css backgroundPosition: '3px -157px'

    # no known card
    else
      $input.css backgroundPosition: '3px 3px'

  onCardBlur: (event) ->
    $input   = $(event.currentTarget)
    value    = $input.val().split('-').join ''
    length   = value.length
    newValue = ''

    if length > 3
      for character, i in value
        newValue += character
        newValue += '-' if i % 4 is 3 and i < 13

      $input.attr 'value', newValue

  onKeyPress: (event) ->
    if event.keyCode is 13 and $('#new_payment .card-info').css('display') is 'none'
      $('#new_payment button').click()
      off

  onSubmit: ->
    $('input[type=submit]').attr 'disabled', true
    $('#new_payment').find('.card-info li.error').hide().text ''
    payment.processCard()
    off

  checkRequiredFields: ->
    $form  = $('#new_payment')
    errors = undefined
    for input in $form.find '#amount, #name, #email'
      $input = $(input).removeClass 'error'
      if $input.val().length < 1
        payment.throwError $input
        errors = true
        break

    unless errors?
      amount = $form.find('#amount').val()
      amount = amount.replace '$', ''
      if /[0-9]+\.[0-9][0-9](?:[^0-9]|$)/.test amount
        amount = amount.replace '.', ''
        if amount < 50
          errors = true
          payment.throwError $form.find('#amount'), 'Please enter an amount over 50¢.'

        else if amount > 99999999
          errors = true
          payment.throwError $form.find('#amount'), 'Please enter an amount under $1,000,000.00.'

        else
          $form.find('#amount').attr 'data-value', amount

      else
        errors = true
        payment.throwError $form.find('#amount'), 'Invalid amount.'

    payment.showCardInfo() unless errors?

  showCardInfo: ->
    $('#darknessification').show()
    $cardInfo = $('#new_payment .card-info')
    $cardInfo.show()
    left = $(window).width()/2 - $cardInfo.outerWidth()/2
    top  = $(window).height()/2 - $cardInfo.outerHeight()/2
    $cardInfo.css top: top, left: left
    $($cardInfo.find('input')[0]).focus()

  processCard: ->
    payment.showLoader()
    card =
      number:    $("#card-number").val().split('-').join ''
      cvc:       $('#card-cvc').val()
      exp_month: $('#card-expiry-month').val()
      exp_year:  $('#card-expiry-year').val()

    Stripe.createToken card, payment.handleStripeResponse

  showLoader: ->
    options =
      lines:     9         # The number of lines to draw
      length:    5         # The length of each line
      width:     3         # The line thickness
      radius:    5         # The radius of the inner circle
      corners:   1         # Corner roundness (0..1)
      rotate:    0         # The rotation offset
      color:     '#fff'    # #rgb or #rrggbb
      speed:     1         # Rounds per second
      trail:     60        # Afterglow percentage
      shadow:    false     # Whether to render a shadow
      hwaccel:   false     # Whether to use hardware acceleration
      className: 'spinner' # The CSS class to assign to the spinner
      zIndex:    2e9       # The z-index (defaults to 2000000000)
      top:       'auto'    # Top position relative to parent in px
      left:      'auto'    # Left position relative to parent in px

    target  = $('#spinner')[0]
    spinner = new Spinner(options).spin target

  handleStripeResponse: (status, response) ->
    $('#spinner').empty()
    $form = $('#new_payment')

    if status is 200
      token = """
        <input type="hidden" name="stripeToken" value="#{response['id']}" />
      """

      amount = $form.find('#amount').data 'value'
      $form.find('#amount').attr 'value', amount
      $form.append token
      $form[0].submit()

    else
      errorMessage = response.error.message
      if errorMessage.search('exp_month') > -1
        errorMessage = 'Invalid expiration month.'

      else if errorMessage.search('exp_year') > -1
        errorMessage = 'Invalid expiration year.'

      $error = $form.find '.card-info li.error'
      $error.show().text errorMessage
      $submit = $form.find 'input[type=submit]'
      $submit.attr 'disabled', false
      $submit.removeAttr 'disabled'

  throwError: ($input, message = 'Required.') ->
    $($('#new_payment li.error')[0]).show().text message
    $input.addClass 'error'
