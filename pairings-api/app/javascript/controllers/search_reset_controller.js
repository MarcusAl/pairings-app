import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "clear"]

  reset() {
    if (this.inputTarget.value === "") {
      this.element.requestSubmit()
    }
  }

  toggleClear() {
    if (this.hasClearTarget) {
      this.clearTarget.classList.toggle("hidden", this.inputTarget.value === "")
    }
  }

  clearAndSubmit() {
    this.inputTarget.value = ""
    this.toggleClear()
    this.element.requestSubmit()
  }
}
