const { description } = require('../../package')

module.exports = {
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#title
   */
  title: 'Spree Gladly Integration',
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#description
   */
  description: description,

  /**
   * Extra tags to be injected to the page HTML `<head>`
   *
   * ref：https://v1.vuepress.vuejs.org/config/#head
   */
  head: [
    ['meta', { name: 'theme-color', content: '#3eaf7c' }],
    ['meta', { name: 'apple-mobile-web-app-capable', content: 'yes' }],
    ['meta', { name: 'apple-mobile-web-app-status-bar-style', content: 'black' }]
  ],

  base: '/spree-gladly/',

  /**
   * Theme configuration, here is the default theme configuration for VuePress.
   *
   * ref：https://v1.vuepress.vuejs.org/theme/default-theme-config.html
   */
  themeConfig: {
    repo: '',
    editLinks: false,
    docsDir: '',
    editLinkText: '',
    lastUpdated: false,
    nav: [
      {
        text: 'Upside',
        link: 'https://upsidelab.io',
      },
      {
        text: 'Gladly',
        link: 'https://gladly.com',
      },
      {
        text: 'Github',
        link: 'https://github.com/upsidelab/spree_gladly',
      },
    ],
    sidebar: {
      '/': [
        {
          title: 'Setup',
          collapsable: false,
          children: [
            '/',
          ]
        },
        {
          title: 'Configuration',
          collapsable: false,
          children: [
            '/configuration/spree-store',
            '/configuration/gladly',
          ]
        },
        {
          title: 'Usage',
          collapsable: false,
          children: [
            '/usage/basic-lookup',
            '/usage/detailed-lookup',
            '/usage/search',
          ]
        },
        {
          title: 'Customization',
          collapsable: false,
          children: [
            '/customization'
          ]
        }
      ],
    }
  },

  /**
   * Apply plugins，ref：https://v1.vuepress.vuejs.org/zh/plugin/
   */
  plugins: []
}
