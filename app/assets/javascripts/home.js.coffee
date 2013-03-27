home = 
  init: ->
    $('#gallery').unslider
      fluid: true
      speed: 500
      dots:  true

$ -> home.init()
