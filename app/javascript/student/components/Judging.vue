<template>
  <div class="tabs tabs--vertical tabs--css-only grid">
    <div :class="['tabs__content', mainContainerGridColumn]">
      <div class="grid">
        <div class="grid__col-8">
          <router-view :key="$route.name">
            <div slot="events"><slot name="events" /></div>
          </router-view>
        </div>
      </div>
    </div>

    <div class="grid__col-3" v-if="!embedded">
      <div v-sticky-sidebar="stickySidebarClasses">
        <judging-menu />
      </div>
    </div>
  </div>
</template>

<script>
import StickySidebar from 'directives/sticky-sidebar'

import JudgingMenu from 'student/menus/Judging'

export default {
  directives: {
    'sticky-sidebar': StickySidebar,
  },

  components: {
    JudgingMenu,
  },

  props: {
    stickySidebarClasses: {
      type: Array,
      default () {
        return []
      },
    },

    embedded: {
      type: Boolean,
      required: false,
      default: false,
    },
  },

  computed: {
    mainContainerGridColumn () {
      if (this.embedded)
        return 'grid__col-12 tabs__content--embedded'

      return 'grid__col-9'
    },
  },
}
</script>

<style lang="scss" scoped>
</style>