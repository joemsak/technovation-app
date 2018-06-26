import axios from 'axios'

// Polyfill Promise for IE11 to support axios
require('es6-promise').polyfill()

window.axios = axios

document.addEventListener('turbolinks:load', () => {
  const csrfTokenMetaTag = document.querySelector('meta[name="csrf-token"]')

  if (csrfTokenMetaTag) {
    window.axios.defaults.headers.common = {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-TOKEN' : csrfTokenMetaTag.getAttribute('content')
    }
  }
})