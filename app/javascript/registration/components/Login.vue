<template>
  <form
    id="login-form"
    class="panel panel--contains-bottom-bar panel--contains-top-bar"
    action="/registration/account"
    method="post"
  >
    <input type="hidden" name="account[wizard_token]" :value="wizardToken" />

    <div class="panel__top-bar">
      Set your email & password for logging in
    </div>

    <div class="panel__content">
      <EmailInput v-model="emailComplete" />
      <PasswordInput v-model="passwordComplete" />
    </div>

    <div class="panel__bottom-bar">
      <a
        class="button float--left"
        @click.prevent="navigateBack"
      >
        Back
      </a>
      <button
        type="submit"
        class="button"
        :disabled="!nextStepEnabled"
      >
        Next
      </button>
    </div>
  </form>
</template>

<script>
import { createNamespacedHelpers } from 'vuex'

import EmailInput from './EmailInput'
import PasswordInput from './PasswordInput'

const { mapState, mapGetters } = createNamespacedHelpers('registration')

export default {
  name: 'login',

  components: {
    EmailInput,
    PasswordInput,
  },

  data () {
    return {
      emailComplete: false,
      passwordComplete: false,
    }
  },

  beforeRouteEnter (_to, from, next) {
    next(vm => {
      if (vm.readyForAccount) {
        next()
      } else {
        vm.$router.replace(from.path)
      }
    })
  },

  computed: {
    ...mapState(['wizardToken']),
    ...mapGetters(['readyForAccount']),

    nextStepEnabled () {
      return this.emailComplete && this.passwordComplete
    },
  },

  methods: {
    navigateBack () {
      this.$router.push({ name: 'basic-profile' })
    },
  },
}
</script>

<style lang="scss">
</style>