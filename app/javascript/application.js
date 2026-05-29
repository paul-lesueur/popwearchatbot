// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

// Confirmation stylée : remplace le confirm() natif du navigateur pour data-turbo-confirm
const confirmMethod = (message) => {
  const dialog = document.getElementById("confirm-dialog")
  if (!dialog) return Promise.resolve(window.confirm(message))

  dialog.querySelector("[data-confirm-message]").textContent = message
  dialog.showModal()

  return new Promise((resolve) => {
    dialog.addEventListener(
      "close",
      () => resolve(dialog.returnValue === "confirm"),
      { once: true }
    )
  })
}

if (window.Turbo) {
  if (window.Turbo.config?.forms) {
    window.Turbo.config.forms.confirm = confirmMethod
  } else if (typeof window.Turbo.setConfirmMethod === "function") {
    window.Turbo.setConfirmMethod(confirmMethod)
  }
}
