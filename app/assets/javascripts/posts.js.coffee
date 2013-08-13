window.posts =

  initialize: ->
    @view = $ '#content.posts'
    @attachEventListeners()

  on: (event, target, handler) ->
    @view.on event, target, $.proxy this, handler

  attachEventListeners: ->
    @on 'change', 'input:checkbox', '_onCheckboxChange'

  # event handlers

  _onCheckboxChange: (event) ->
    $paymentFields = @view.find 'form .disclosure'
    switch $(event.currentTarget).is ':checked'
      when on then $paymentFields.show()
      else $paymentFields.hide()

$ -> posts.initialize()
