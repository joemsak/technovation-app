<template>
  <form
    @submit.prevent="handleSubmit"
    class="panel panel--contains-bottom-bar panel--contains-top-bar"
  >
    <div class="panel__top-bar">
      Agree to our data use terms
    </div>

    <div class="panel__content">
      <h3>How Technovation uses your data</h3>

      <p>
        Please take a moment to read this before signing up.
        We have tried to make it very easy to understand.
        You can
        <a
          href="http://iridescentlearning.org/terms-of-use/"
          target="_blank"
        >read our full terms of use here</a>;
        below is a summary.
      </p>

      <hr />

      <p>Technovation is owned by a non-profit organization called Iridescent.</p>

      <h4>No advertising</h4>

      <p>
        We will never use, share, rent, or sell your personal data to
        anyone to advertise to you, or to manipulate you.
      </p>

      <h4>Your personal data</h4>

      <p>
        We will only use your data to help guide you through the
        Technovation program, and to learn how we can make the program
        better and easier for everyone.
      </p>

      <p>
        We may share your personal data and activity with a trusted volunteer
        manager in your region—who has been trained through a proper verification
        process—in order for them to support you and your team during the program.
      </p>

      <h4>Newsletters and informational email</h4>

      <p>
        You can unsubscribe from our <strong>newsletters</strong> about the
        curriculum and program at any time. This is different from
        <strong>informational email</strong> about your account and team
        activity, which you will continue to receive.
      </p>

      <h4>Deleting your account and data</h4>

      <p>
        You can delete your account and data, and get a copy of your data, at any time.
        Deleting your data will remove you from your team and our program.
      </p>


      <h4>Background Checks</h4>

      <p>
        Background checks are reports of your work and legal history.
        In the United States all mentors are required to complete and pass
        a background check in order to be allowed and verified on our site.
      </p>

      <p>
        In other countries and territories, we will randomly select mentors
        to provide references and legal certifications, and to submit to
        background checks where possible. If you are selected, we will
        contact you to complete this process. You must consent to this to
        be allowed and verified on our site.
      </p>

      <p>Thank you for helping us keep our students safe.</p>

      <div class="padding--t-b-large text-align--right">
        <label class="margin--none">
          <input
            type="checkbox"
            v-model="termsAgreed"
            :disabled="isLocked"
          />
          I agree to these data use terms
        </label>
      </div>
    </div>

    <div class="panel__bottom-bar">
      <button
        class="button"
        :disabled="!termsAgreed"
        @click="handleSubmit"
      >Next</button>
    </div>
  </form>
</template>

<script>
import { createNamespacedHelpers } from 'vuex'

const { mapState, mapGetters, mapActions } = createNamespacedHelpers('registration')

export default {
  name: 'data-use-terms',

  computed: {
    ...mapState(['isLocked']),

    termsAgreed: {
      get () {
        return this.$store.state.registration.termsAgreed
      },

      set (value) {
        this.updateTermsAgreed({ termsAgreed: value })
      }
    },
  },

  methods: {
    ...mapActions(['updateTermsAgreed']),

    handleSubmit () {
      if (!this.termsAgreed) return false
      this.$router.push({ name: 'location' })
    },
  },
}
</script>

<style scoped>
h3,
h4 {
  -webkit-font-smoothing: antialiased;
}

h4 {
  margin: 1rem 0 0;
  padding: 0;
}
</style>