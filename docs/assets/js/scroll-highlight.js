$(function() {
  $(window).scroll(function() {
    $("h1, h2, h3").each(function() {
      if ($(window).scrollTop() >= $(this).offset().top - 200) {
        var id = $(this).attr('id');
        $('.nav-list a').removeClass('active');
        $('.nav-list a[href="#' + id + '"]').addClass('active');
      }
    });
  });
});
