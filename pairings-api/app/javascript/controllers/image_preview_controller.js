import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "container"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewTarget.src = e.target.result
      if (this.hasContainerTarget) {
        this.containerTarget.classList.remove("hidden")
      }
    }
    reader.readAsDataURL(file)
  }
}
