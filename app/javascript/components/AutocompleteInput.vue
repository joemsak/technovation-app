<template>
  <div class="margin--b-medium">
    <input
      ref="valueInput"
      type="hidden"
      :name="name"
      :value="mutableValue"
    />
    <vue-select
      :select-on-tab="true"
      :input-id="id"
      :options="mutableOptions"
      v-model="mutableValue"
      taggable
    >
      <template slot="no-options">
        {{ noOptionsText }}
      </template>
    </vue-select>
  </div>
</template>

<script>

import VueSelect from '@vendorjs/vue-select'

export default {
  name: 'autocomplete-input',

  components: {
    VueSelect,
  },

  data() {
    return {
      autoCompleteInstance: null,
      mutableOptions: [],
      mutableValue: null,
    }
  },

  props: {
    id: {
      type: String,
      default: '',
    },

    name: {
      type: String,
      default: '',
    },

    noOptionsText: {
      type: String,
      default: '',
    },

    options: {
      type: Array,
      default() {
        return []
      },
    },

    url: {
      type: String,
      default: '',
    },

    value: {
      type: String,
      default: '',
    },
  },

  created () {
    if (this.url !== '') {
      window.axios.get(this.url)
        .then((response) => {
          this.mutableOptions = response.data.attributes
        })
    } else {
      this.mutableOptions = this.options
    }

    if (this.value !== null && this.value.length) {
      this.mutableValue = this.value
    }
  },

  watch: {
    value (newValue) {
      if (!newValue) {
        this.mutableValue = null
      } else {
        this.mutableValue = this.value
      }
    },

    mutableValue (newValue) {
      if (newValue && typeof newValue === 'object') {
        this.$emit('input', newValue.label)
      } else {
        this.$emit('input', newValue)
      }
    },
  },
}
</script>

<style scoped>
</style>