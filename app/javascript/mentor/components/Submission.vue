<template>
  <div class="grid">
    <div class="grid__col-12">
      <slot name="submission" />
    </div>
  </div>
</template>

<script>
import StickySidebar from 'directives/sticky-sidebar'

export default {
  directives: {
    'sticky-sidebar': StickySidebar,
  },

  props: {
    stickySidebarClasses: {
      type: Array,
      default () {
        return []
      },
    },
  },
}
</script>

<style lang="scss" scoped>
</style>