import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    const text = this.sourceTarget.innerText.trim()

    navigator.clipboard.writeText(text).then(() => {
      this.buttonTarget.innerText = "Copié !"

      setTimeout(() => {
        this.buttonTarget.innerText = "Copier"
      }, 1500)
    })
  }
}
