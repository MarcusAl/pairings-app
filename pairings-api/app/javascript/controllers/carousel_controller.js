import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "track"]
  static values = { index: { type: Number, default: 0 }, interval: { type: Number, default: 5000 } }

  connect() {
    this.startAutoplay()
  }

  disconnect() {
    this.stopAutoplay()
  }

  next() {
    this.indexValue = (this.indexValue + 1) % this.slideTargets.length
    this.scrollToSlide()
  }

  previous() {
    this.indexValue = (this.indexValue - 1 + this.slideTargets.length) % this.slideTargets.length
    this.scrollToSlide()
  }

  scrollToSlide() {
    const slide = this.slideTargets[this.indexValue]
    if (slide) {
      this.trackTarget.scrollTo({ left: slide.offsetLeft, behavior: "smooth" })
    }
  }

  startAutoplay() {
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  stopAutoplay() {
    if (this.timer) clearInterval(this.timer)
  }

  pause() {
    this.stopAutoplay()
  }

  resume() {
    this.startAutoplay()
  }
}
