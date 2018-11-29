const tooltips = document.querySelectorAll(".tooltip");

tooltips.forEach(tooltip => {
  tooltip.addEventListener("click", event => {
    console.log(event);
    event.preventDefault();
  })
})
