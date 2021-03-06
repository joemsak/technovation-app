<template>
  <div class="grid grid--align-start grid--justify-space-between ">
    <div :class="solo ? 'grid__col-md-6' : 'grid__col-12'">
      <h3>{{ title }}</h3>

      <p class="refer-to">Refer to the {{ referTo }}</p>

      <score-entry :questions="questions">
        <slot />
      </score-entry>
    </div>

    <div :class="solo ? 'grid__col-md-6' : 'grid__col-12'">
      <h3>{{ section | capitalize }} comment</h3>

      <h5 class="heading--reset">Please keep in mind</h5>

      <slot name="comment-tips" />

      <div class="grid grid--bleed grid--justify-space-between">
        <div class="grid__col-6"></div>

        <div class="grid__col-6">
          <p class="word-count">
            <span :style="`color: ${colorForWordCount}`">
              {{ wordCount }}
              {{ wordCount | pluralize('word') }}
            </span>

            <br />

            <span :style="`font-size: ${fontSizeForBadWordCount}; color: ${colorForBadWordCount}`">
              {{ badWordCount }}
              {{ badWordCount | pluralize('prohibited word') }}
            </span>
          </p>
        </div>
      </div>

      <div class="comment-sentiment">
        <div
          v-tooltip.top-center="sentimentTooltip('positive')"
          :style="`width: ${sentimentPercentage('positive')}`"
        ></div>

        <div
          v-tooltip.top-center="sentimentTooltip('neutral')"
          :style="`width: ${sentimentPercentage('neutral')}`"
        ></div>

        <div
          v-tooltip.top-center="sentimentTooltip('negative')"
          :style="`width: ${sentimentPercentage('negative')}`"
        ></div>
      </div>

      <textarea ref="commentText" :value="comment.text" @input="updateCommentText" />

      <div class="grid grid--bleed grid--justify-space-between">
        <div class="grid__col-12">
          <small>(please write at least 40 words, with less than 20% negativity)</small>
        </div>

        <div class="grid__col-6 nav-btns--left">
          <p>
            <router-link
              v-if="!!prevSection"
              :to="{ name: prevSection }"
              class="button button--small btn-prev"
            >
              Back: {{ prevBtnTxt }}
            </router-link>
          </p>
        </div>

        <div class="grid__col-6 nav-btns--right">
          <p>
            <span v-tooltip="nextDisabledMsg">
              <router-link
                v-if="!!nextSection"
                :to="{ name: nextSection }"
                :disabled="goingNextIsDisabled"
                class="button button--small btn-next"
              >
                Next: {{ nextBtnTxt }}
              </router-link>
            </span>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import capitalize from 'lodash/capitalize'
import { mapState, mapGetters } from 'vuex'

import { debounce } from '../../utilities/utilities'
import ScoreEntry from './ScoreEntry'

export default {
  name: 'QuestionSection',

  data () {
    return {
      detectedProfanity: {},
      commentInitiated: false,
    }
  },

  watch: {
    commentText () {
      this.$nextTick(() => {
        this.$store.commit('setComment', {
          sectionName: this.section,
          word_count: this.wordCount,
        })

        this.debouncedCommentWatcher()
      })
    },

    commentStorageKey () {
      this.initiateComment()
    },
  },

  computed: {
    ...mapState(['submission']),
    ...mapGetters(['sectionQuestions']),

    comment () {
      return this.$store.getters.comment(this.section)
    },

    commentIsSentimentAnalyzed () {
      return this.comment.isSentimentAnalyzed
    },

    commentIsProfanityAnalyzed () {
      return this.comment.isProfanityAnalyzed
    },

    commentText () {
      return this.comment.text
    },

    nextDisabledMsg () {
      if (this.goingNextIsDisabled) {
        return 'Please write a substantial comment, ' +
               'keep it clean, and be friendly'
      } else {
        return false
      }
    },

    goingNextIsDisabled () {
      return this.wordCount < 40 ||
               this.badWordCount > 0 ||
                 this.comment.sentiment.negative > 0.2
    },

    wordCount () {
      let text = this.commentText

      if (!this.commentText) text = ''

      return text.split(' ').filter(word => {

        return word.split('').filter(char => {
          return char.match(/\w/)
        }).length > 2

      }).length
    },

    badWordCount () {
      return Object.keys(this.detectedProfanity).reduce((acc, key) => {
        return acc += this.detectedProfanity[key]
      }, 0)
    },

    colorForWordCount () {
      if (this.wordCount >= 40) {
        return 'darkgreen'
      } else if (this.wordCount >= 30) {
        return 'orange'
      } else if (this.wordCount >= 20) {
        return 'darkyellow'
      } else {
        return 'darkred'
      }
    },

    colorForBadWordCount () {
      if (this.badWordCount < 1) {
        return 'darkgreen'
      } else {
        return 'darkred'
      }
    },

    fontSizeForBadWordCount () {
      if (this.badWordCount < 1) {
        return 'inherit'
      } else {
        return '1.3rem'
      }
    },

    questions () {
      return this.sectionQuestions(this.section)
    },

    commentStorageKey () {
      return `${this.section}-comment-${this.submission.id}`
    },

    nextBtnTxt () {
      return this.nextSectionTitle || capitalize(this.nextSection)
    },

    prevBtnTxt () {
      return capitalize(this.prevSection)
    },

    shouldRunSentimentAnalysis () {
      return (
        this.wordCount > 19 &&
          (this.wordCount % 5 === 0 ||
            !this.commentIsSentimentAnalyzed)
      )
    },

    shouldRunProfanityAnalysis () {
      return (
        this.wordCount > 0 &&
          (this.wordCount % 2 === 0 ||
            !this.commentIsProfanityAnalyzed)
      )
    },
  },

  props: [
    'title',
    'referTo',
    'nextSection',
    'prevSection',
    'section',
    'nextSectionTitle',
    'solo',
  ],

  components: {
    ScoreEntry,
  },

  methods: {
    initiateComment () {
      let comment = Object.assign({}, this.comment, { sectionName: this.section })

      if (!comment.text) {
        comment.text = ''
      }

      this.$store.commit('setComment', comment)

      const positiveSentiment = parseFloat(comment.sentiment.positive)
      const neutralSentiment = parseFloat(comment.sentiment.neutral)
      const negativeSentiment = parseFloat(comment.sentiment.negative)

      if (!!positiveSentiment || !!neutralSentiment || !!negativeSentiment) {
        this.$store.commit('setComment', {
          sectionName: this.section,
          isSentimentAnalyzed: true,
        })
      }

      this.commentInitiated = true
    },

    sentimentTooltip (slant) {
      return 'Your comment seems ' +
             this.sentimentPercentage(slant) + ' ' +
             slant
    },

    sentimentPercentage (slant) {
      return `${Math.round(parseFloat(this.comment.sentiment[slant]) * 100)}%`
    },

    handleCommentChange () {
      if (this.commentInitiated) {
        if (this.commentText.length) {
          this.runSentimentAnalysis().then(() => {
            this.runProfanityAnalysis().then(() => {
              this.saveComment()
            })
          })
        } else {
          this.$store.commit('resetComment', this.section)
          this.saveComment()
        }
      }
    },

    runSentimentAnalysis () {
      return new Promise((resolve, reject) => {
        if (this.shouldRunSentimentAnalysis) {
          Algorithmia.client("sim7BOgNHD5RnLXe/ql+KUc0O0r1")
            .algo("nlp/SocialSentimentAnalysis/0.1.4")
            .pipe({ sentence: this.commentText })
            .then(resp => {
              this.$store.commit('setComment', {
                sectionName: this.section,
                sentiment: resp.result[0],
                isSentimentAnalyzed: true,
              })
              resolve()
            })
        } else {
          resolve()
        }
      })
    },

    runProfanityAnalysis () {
      return new Promise((resolve, reject) => {
        if (this.shouldRunProfanityAnalysis) {
          Algorithmia.client("sim7BOgNHD5RnLXe/ql+KUc0O0r1")
            .algo("nlp/ProfanityDetection/1.0.0")
            .pipe([this.commentText, ['suck', 'sucks'], false])
            .then(resp => {
              this.detectedProfanity = resp.result

              this.$store.commit('setComment', {
                sectionName: this.section,
                bad_word_count: this.badWordCount,
                isProfanityAnalyzed: true,
              })

              resolve()
            })
        } else {
          resolve()
        }
      })
    },

    updateCommentText (e) {
      this.$store.commit('setComment', {
        sectionName: this.section,
        text: e.target.value,
      })
    },

    saveComment () {
      this.$store.commit('saveComment', this.section)
    },
  },

  mounted () {
    if (!!this.submission.id)
      this.initiateComment()
  },

  created () {
    this.debouncedCommentWatcher = debounce(() => {
      this.handleCommentChange()
    }, 500)
  }
}
</script>

<style lang="scss" scoped>
  .grid {
    background: white;
  }

  .refer-to {
    font-size: 0.9rem;
    font-style: italic;
    margin: 0;
  }

  textarea {
    width: 100%;
    height: 35vh;
    margin: 0;
    padding: 1rem;
    box-shadow: inset 0.2rem 0.2rem 0.2rem rgba(0, 0, 0, 0.2);
  }

  .nav-btns--right {
    text-align: right;
  }

  .word-count {
    text-align: right;
    font-size: 1rem;
    font-weight: bold;
    margin: 0.5rem 0;
  }

  .word-count__note {
    font-weight: normal;
  }

  .comment-sentiment {
    display: flex;

    color: white;
    font-weight: bold;
    font-size: 0.9rem;

    div {
      transition: width 1s ease-in-out;
      overflow: hidden;
      background: IndianRed;
      padding: 0.5rem 0;

      &:first-child {
        background: MediumSeaGreen;
      }

      &:nth-child(2) {
        background: SteelBlue;
      }
    }
  }
</style>
