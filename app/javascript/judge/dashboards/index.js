import Vue from 'vue'

import store from './scores/store'
import { router } from './scores/routes'

import LiveEventNav from './scores/LiveEventNav'
import VirtualNav from './scores/VirtualNav'

document.addEventListener('turbolinks:load', () => {
  const dashEl = document.querySelector('#judge-dashboard-scores-app')

  if (dashEl != undefined) {
    new Vue({
      el: dashEl,
      router,
      store,

      components: {
        LiveEventNav,
        VirtualNav,
      },

      mounted () {
        $.get("/judge/scores.json", null, resp => {
          this.$store.commit('populateScores', resp)
        })

        if (this.$refs.disableAssigned && !window.location.hash) {
          this.$router.push({ name: 'finished-scores' })
        } else if (!this.$refs.disableAssigned) {
          $.get("/judge/assigned_submissions.json", null, resp => {
            this.$store.commit('populateSubmissions', resp)
          })
        }

        if (this.$refs.deadline)
          this.$store.commit('deadline', this.$refs.deadline.dataset.date)
      },
    })
  }
})
