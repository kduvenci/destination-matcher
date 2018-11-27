const choice = document.getElementByID("flight-radio-btn");
choice.style.display = "none";

choice.addEventListener("input", () => {
  choice.style.display = "block";
});
