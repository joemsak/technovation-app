//= require application

//= require search

document.addEventListener("turbolinks:load", function() {
  $("[data-keep-count-of]").each(function() {
    var $source = $($(this).data('keep-count-of')),
        $that = $(this);

    $source.on("input", function() {
      var numChars = $(this).val().length,
          counted = "character";

      $that.find('span:first-child').text(numChars);

      if (numChars !== 1)
        counted += "s";

      $that.find('span:last-child').text(counted);
    });
  });
});
