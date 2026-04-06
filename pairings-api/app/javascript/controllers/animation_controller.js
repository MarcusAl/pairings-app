import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const delay = entry.target.dataset.animationDelay || 0
          setTimeout(() => entry.target.classList.add("animate--visible"), delay)
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.1 })

    this.itemTargets.forEach((el) => observer.observe(el))
    this.observer = observer
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
