(function linkImgElements($, window, document) {
  $(document).ready(function() {
    $('img').each(function() {
      $(this).wrap(function() {
        return '\
<a target="_blank" rel="noopener noreferrer" href="' + $(this).attr('src') + '"></a>';
      })
    })
  });
}(jQuery, window, document));
