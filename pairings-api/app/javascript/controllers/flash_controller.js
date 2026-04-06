import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    requestAnimationFrame(() => this.element.classList.add("toast--visible"))
    this.timeout = setTimeout(() => this.dismiss(), 4000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.remove("toast--visible")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }
}
