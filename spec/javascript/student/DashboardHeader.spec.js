import 'axios'
import { shallowMount, createLocalVue } from '@vue/test-utils'
import Vuex from 'vuex'

import mockStore from 'student/store/__mocks__'
import DashboardHeader from 'student/DashboardHeader'
import DropDown from 'components/DropDown'

const localVue = createLocalVue()
localVue.use(Vuex)

describe("student/DashboardHeader.vue", () => {
  let defaultWrapper

  beforeEach(() => {
    const defaultStore = mockStore.createMocks()

    defaultWrapper = shallowMount(
      DashboardHeader,
      {
        localVue,
        store: new Vuex.Store({
          modules: {
            authenticated: {
              namespaced: true,
              state: defaultStore.state,
              getters: defaultStore.getters,
              mutations: defaultStore.mutations,
            },
          },
        })
      }
    )
  })

  it("contains the two headers", () => {
    expect(defaultWrapper.findAll('.dashboard-notices .grid__col-sm-6').length).toEqual(2)
  })

  it("contains the resources drop-down", () => {
    const dropDown = defaultWrapper.find(DropDown)
    expect(dropDown.exists()).toBe(true)
    expect(dropDown.vm.label).toEqual("More Information")
  })

  it("displays the currentAccount's name", () => {
    defaultWrapper.vm.$store.commit('authenticated/htmlDataset', {
      currentAccount: '{"data":{"attributes":{"name":"Saul Goodman"}}}'
    })

    expect(defaultWrapper.find(
      '.dashboard-notices .grid__col-sm-6:nth-child(2)'
    ).text()).toContain("Saul Goodman")
  })

  describe("when the RA has not provided an intro", () => {
    it("displays the default left header", () => {
      defaultWrapper.setProps({
        defaultTitle: "Student Dashboard",
        resourceLinks: [
          {
            url: 'something',
            text: 'something',
            isSurveyLink: true
          }
        ]
      })

      expect(defaultWrapper.find(
        '.dashboard-notices .grid__col-sm-6:first-child'
      ).text()).toContain("Student Dashboard")

      expect(defaultWrapper.find(
        '.dashboard-notices .grid__col-sm-6:first-child h1 small a'
      ).exists()).toBe(true)
    })
  })

  describe("when the RA has provided an intro ", () => {
    beforeEach(() => {
      defaultWrapper.vm.$store.commit('authenticated/htmlDataset', {
        regionalAmbassador: '{"data":{"attributes":{"name":"Jean Weiss","programName":"Technovation[MN]","hasProvidedIntro":true}}}'
      })
    })

    it("displays the RA intro header", () => {
      const text = defaultWrapper.find(
        '.dashboard-notices .grid__col-sm-6:first-child'
      ).text()

      expect(text).toContain("Technovation[MN]")
    })
  })
})