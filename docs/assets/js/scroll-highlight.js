$(document).ready(function () {
  $(".nav-list").addClass("navigation-list-child-list");
  // this waits until the document is fully loaded
  // Put custom logic here

  // cache the navigation links
  var $navigationLinks = $(".nav-list li > a");
  // cache (in reversed order) the sections
  var $sections = $($("h2, h3, h4, h5").get().reverse());

  // map each section id to their corresponding navigation link
  var sectionIdTonavigationLink = {};
  $sections.each(function () {
    var id = $(this).attr("id");

    sectionIdTonavigationLink[id] = $(
      ".nav-list li > a[href=\\#" + id + "]"
    );
  });

  // throttle function, enforces a minimum time interval
  function throttle(fn, interval) {
    var lastCall, timeoutId;
    return function () {
      var now = new Date().getTime();
      if (lastCall && now < lastCall + interval) {
        // if we are inside the interval we wait
        clearTimeout(timeoutId);
        timeoutId = setTimeout(function () {
          lastCall = now;
          fn.call();
        }, interval - (now - lastCall));
      } else {
        // otherwise, we directly call the function
        lastCall = now;
        fn.call();
      }
    };
  }

  function highlightNavigation() {
    console.log("Triggered");
    // get the current vertical position of the scroll bar
    var scrollPosition = $(window).scrollTop();

    // iterate the sections
    $sections.each(function () {
      var currentSection = $(this);
      // get the position of the section
      var sectionTop = currentSection.offset().top;
      sectionTop -= 50

      // if the user has scrolled over the top of the section
      if (scrollPosition >= sectionTop) {
        // get the section id
        var id = currentSection.attr("id");
        // get the corresponding navigation link
        var $navigationLink = sectionIdTonavigationLink[id];
        // if the link is not active

        if (!$navigationLink.hasClass("active")) {
          // remove .active class from all the links
          $navigationLinks.removeClass("active");

          // add .active class to the current link
          $navigationLink.addClass("active");
        }
        // we have found our section, so we return false to exit the each loop
        return false;
      }
    });
  }

  //$(document).scroll( highlightNavigation );
  $(".main-content-wrap").scroll(throttle(highlightNavigation, 100));
  $(".main-content-wrap").scroll(highlightNavigation);
});
