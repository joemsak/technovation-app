<template>
  <div>
    <dashboard-header
      default-title="Mentor Dashboard"
      :resource-links="resourceLinks"
    >
      <div slot="right-sidebar">
        <small><slot name="ra-switch-link" /></small>
        <small><slot name="judge-switch-link" /></small>
      </div>

      <div slot="ra-intro"><slot name="ra-intro" /></div>
    </dashboard-header>

    <div class="tabs tabs--vertical tabs--css-only tabs--content-first grid">
      <div class="tabs__content background-color--white grid__col-9">
        <router-view :key="$route.name" :profile-icons="profileIcons">
          <div slot="change-email"><slot name="change-email" /></div>
          <div slot="change-password"><slot name="change-password" /></div>
          <div slot="mentor-training"><slot name="mentor-training" /></div>
          <div slot="bio"><slot name="bio" /></div>
          <div slot="consent-waiver"><slot name="consent-waiver" /></div>
          <div slot="background-check"><slot name="background-check" /></div>
          <div slot="find-team"><slot name="find-team" /></div>
          <div slot="create-team"><slot name="create-team" /></div>
          <div slot="submission"><slot name="submission" /></div>
          <div slot="events"><slot name="events" /></div>
          <div slot="scores"><slot name="scores" /></div>
        </router-view>

        <slot></slot>
      </div>

      <div class="grid__col-3 grid__col--bleed">
        <dashboard-menu />
      </div>
    </div>
  </div>
</template>

<script>
import DashboardMenu from './DashboardMenu'
import DashboardHeader from './DashboardHeader'

export default {
  name: 'app',

  components: {
    DashboardMenu,
    DashboardHeader,
  },

  data () {
    return {
      resourceLinks: [
        {
          heading: 'Curriculum',
          url: 'https://www.technovationchallenge.org/curriculum-intro/registered',
          text: 'Open the Technovation Curriculum',
        },

        {
          heading: 'Help us improve!',
          url: this.surveyLink,
          text: this.surveyLinkText,
          isSurveyLink: true,
        },

        {
          heading: 'Submission Guide',
          url: 'https://www.technovationchallenge.org/submission-guidelines/',
          text: 'Read the Submission Guidelines',
        },

        {
          heading: 'Judging Rubric',
          url: 'https://www.technovationchallenge.org/judging-rubric/',
          text: 'Read the Judging Rubric',
        },
      ],
    }
  },

  props: {
    surveyLink: {
      type: String,
      required: false,
      default: '',
    },

    surveyLinkText: {
      type: String,
      required: false,
      default: '',
    },

    profileIcons: {
      type: Object,
      default () {
        return {
          profileIconMentor: '',
          profileIconMentorMale: '',
          profileIconStudent: '',
        }
      },
    },
  },
}
</script>

<style scoped lang="scss">
</style>