// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open() {
    this.element.classList.remove("hidden")
  }

  close() {
    this.element.classList.add("hidden")
  }
}
