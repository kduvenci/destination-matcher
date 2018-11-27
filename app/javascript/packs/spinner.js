// console.log("hello from webpack spinner");

const searchButton = document.querySelector(".spin-trigger");
// console.log(searchButton);

searchButton.addEventListener("click", (event) => {
  // event.preventDefault();
  const spin = document.querySelector(".spinner-modal");
  const searchForm = document.querySelector(".search-box .simple_form")
  const formValues = []
  searchForm.querySelectorAll("select").forEach((select) => {
    formValues.push(select.value)
  });
  if ( formValues.includes("")) {
    return false
  } else {spin.style.display = "flex" };
});
