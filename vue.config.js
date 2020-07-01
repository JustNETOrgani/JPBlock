module.exports = {
  configureWebpack: {
    resolve: {
      alias: {
        assets: '@/assets',
        store: '@/store',
        components: '@/components',
        views: '@/views'
      }
    }
  },
  runtimeCompiler: true
}
