$(document).on("click", "#team_submissions--menu a", function(e) {
  e.preventDefault();

  var anchor = $(this).attr('href'),
      offset = 92;

  $(anchor)[0].scrollIntoView();
  location.href = anchor;

  scrollBy(0, -offset);
});
