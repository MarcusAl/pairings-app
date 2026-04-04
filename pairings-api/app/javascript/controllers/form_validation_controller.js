import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.validate()
  }

  validate() {
    const form = this.element
    const requiredFields = form.querySelectorAll("[required]")
    const allFilled = Array.from(requiredFields).every((field) => field.value.trim() !== "")

    this.submitTarget.disabled = !allFilled
    this.submitTarget.classList.toggle("opacity-50", !allFilled)
    this.submitTarget.classList.toggle("cursor-not-allowed", !allFilled)
  }
}
