/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue/dist/vue.esm'
import CertificateButton from '../components/CertificateButton'

import '../utilities/jquery-double-scroll'

import '../config/axios'

document.addEventListener('turbolinks:load', () => {
  const btnEls = document.querySelectorAll('.vue-enable-certificate-btn')

  btnEls.forEach((btnEl) => {
    new Vue({
      el: btnEl,

      components: {
        CertificateButton,
      },
    })
  })

  // Scrollable datagrid table dual scrollbars
  $('.table--scrollable').doubleScroll({
    resetOnWindowResize: true,
  })
})