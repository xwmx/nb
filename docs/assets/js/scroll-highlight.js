$(function() {
  $(window).scroll(function() {
    $("#home, h2, h3").each(function() {
      if ($(window).scrollTop() >= $(this).offset().top - 200) {
        var id = $(this).attr('id');

        if (id.indexOf("-import--export") !== -1) {
          id = '%EF%B8%8F-import--export';
        }

        if (id.indexOf("-set--settings") !== -1) {
          id = '%EF%B8%8F-set--settings';
        }

        if (id.indexOf("-tasks") !== -1) {
          id = '%EF%B8%8F-tasks';
        }

        if (
            id.indexOf("nb-markdown-bookmark-file-format")  !== -1 ||
            id.indexOf("nb-markdown-todo-file-format")      !== -1 ||
            id.indexOf("nb-notebook-specification")         !== -1
        ) {
          id = 'specifications';
        }

        $('.nav-list a').removeClass('active');
        $('.nav-list a[href="#' + id + '"]').addClass('active');
      } else if($(window).scrollTop() + $(window).height() == $(document).height()) {
        $('.nav-list a').removeClass('active');
        $('.nav-list a[href="#tests"').addClass('active');
      }
    });
  });
});

