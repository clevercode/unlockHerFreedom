jQuery(document).ready( function($) {
  var $menu = $("nav > ul");
  $menu.superfish({
    animation: {
      opacity: "show",
      height: "show"
    },
    speed: "fast",
    delay:250
  });

  var $slideshow = $(".slideshow");
  $slideshow.cycle({
    prev: "#prevSlide",
    next: "#nextSlide",
    fx: "scrollRight"
  });
});


