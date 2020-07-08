import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../views/Home.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  // Journal tasks.
  {
    path: '/journals/createJournal',
    name: 'JCreate',
    component: () => import('@/views/journals/createJournal.vue')
  },
  {
    path: '/journals/updateJournal',
    name: 'JInfoUpdate',
    component: () => import('@/views/journals/updateJournal.vue')
  },
  {
    path: '/journals/activateOrDeActJournal',
    name: 'JActOrDeAct',
    component: () => import('@/views/journals/activateOrDeActJournal.vue')
  },
  {
    path: '/journals/reviewOrAccept',
    name: 'paperReviewOrAccep',
    component: () => import('@/views/journals/reviewOrAccept.vue')
  },
  {
    path: '/journals/resubOrRejectPaper',
    name: 'paperResubOrReject',
    component: () => import('@/views/journals/resubOrRejectPaper.vue')
  },
  {
    path: '/journals/jBalanceCheck',
    name: 'getJsBalance',
    component: () => import('@/views/journals/jBalanceCheck.vue')
  },
  {
    path: '/journals/publishPaper',
    name: 'publishPaper',
    component: () => import('@/views/journals/publishPaper.vue')
  },
  {
    path: '/journals/jDashboard',
    name: 'jsDashboard',
    component: () => import('@/views/journals/jDashboard.vue')
  },
  // Author routes.
  {
    path: '/authors/submitPaper',
    name: 'authorPsubmit',
    component: () => import('@/views/authors/submitPaper.vue')
  },
  {
    path: '/authors/authorDashboard',
    name: 'aDashboard',
    component: () => import('@/views/authors/authorDashboard.vue')
  },
  // GLobal use
  {
    path: '/paperTrackingService',
    name: 'paperTracker',
    component: () => import('@/views/paperTrackingService.vue')
  },
  {
    path: '/proveOfAuthorship',
    name: 'authorProvenance',
    component: () => import('@/views/proveOfAuthorship.vue')
  },
  {
    path: '/voteOnJreputation',
    name: 'voteForJ',
    component: () => import('@/views/voteOnJreputation.vue')
  },
  {
    path: '/payForPaperPublication',
    name: 'paperForAcceptedPaper',
    component: () => import('@/views/payForPaperPublication.vue')
  },
  {
    path: '/payToGetRestrictedPaper',
    name: 'subscriptionLikePay',
    component: () => import('@/views/payToGetRestrictedPaper.vue')
  },
  {
    path: '/authorProfile',
    name: 'authProfile',
    component: () => import('@/views/authorProfile.vue')
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
