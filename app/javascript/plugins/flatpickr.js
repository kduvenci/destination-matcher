import flatpickr from "flatpickr"
import "flatpickr/dist/flatpickr.min.css" // Note this is important!
import rangePlugin from "flatpickr/dist/plugins/rangePlugin"

flatpickr(".depart-date", {
  minDate: "today",
  defaultDate:  new Date().fp_incr(1),
})

flatpickr(".return-date", {
  minDate: "today",
  defaultDate: new Date().fp_incr(8)
})

flatpickr("#range_start", {
  altInput: true,
  plugins: [new rangePlugin({ input: "#range_end"})]
})
