window.addEventListener("scroll", function() {
    var fixedButtonsContainer = document.getElementById("fixed-buttons-container");
    var scrollPosition = window.scrollY || window.pageYOffset;
  
    if (scrollPosition > 200) {
      fixedButtonsContainer.style.position = "fixed";
    } else {
      fixedButtonsContainer.style.position = "static";
    }
});
  