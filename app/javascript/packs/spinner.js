console.log("hello from webpack spinner");

const searchButton = document.querySelector(".spin-trigger");
console.log(searchButton);


searchButton.addEventListener("click", (event) => {
  // event.preventDefault();
  console.log(event);
  const spin = document.querySelector(".spinner-modal");
  spin.style.display = "block";

});
