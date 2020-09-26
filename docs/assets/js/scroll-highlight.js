$(function() {
  $(window).scroll(function() {
    $("#top, h2, h3").each(function() {
      if ($(window).scrollTop() >= $(this).offset().top - 200) {
        var id = $(this).attr('id');
        $('.nav-list a').removeClass('active');
        $('.nav-list a[href="#' + id + '"]').addClass('active');
      } else if($(window).scrollTop() + $(window).height() == $(document).height()) {
        $('.nav-list a').removeClass('active');
        $('.nav-list a[href="#tests"').addClass('active');
      }
    });
  });
});
