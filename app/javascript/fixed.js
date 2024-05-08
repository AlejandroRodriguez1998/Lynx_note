window.addEventListener("scroll", function() {
  var fixedButtonsContainer = document.getElementById("fixed-buttons-container");
  var scrollPosition = window.scrollY || window.pageYOffset;

  if (fixedButtonsContainer) {
      var threshold = 200;
      var tolerance = 30; 

      // Solo actualiza el estilo si el scrollPosition pasa el umbral con una tolerancia significativa
      if (scrollPosition > threshold + tolerance && fixedButtonsContainer.style.position !== "fixed") {
        fixedButtonsContainer.style.position = "fixed";
      } else if (scrollPosition < threshold - tolerance && fixedButtonsContainer.style.position !== "static") {
        fixedButtonsContainer.style.position = "static";
      }
  }
});
