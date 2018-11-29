const tips = document.querySelectorAll(".tip");
console.log(tips);

tips.forEach(tip => {
  tip.addEventListener("click", event => {
    console.log(event);
    event.preventDefault();
  })
})
