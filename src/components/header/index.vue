<template>
  <div class="header">
    <img class="logo" src="../../assets/imgs/JPBlockLogo.png" />
    <div class="menu">
      <p id="appHeadingOne">Augmenting Journals and Paper Publication</p>
    </div>
    <div id="nav">
      <el-menu
    :default-active="activeIndex"
    class="el-menu-demo"
    mode="horizontal"
    @select="handleSelect"
    background-color="#545c64"
    text-color="#fff"
    active-text-color="#ffd04b">
    <el-menu-item index="1"><el-link style="color:#fff" href="/">Home</el-link></el-menu-item>
    <el-submenu index="2">
      <template slot="title">Journal Tasks</template>
      <el-menu-item index="2-1"><el-link style="color:#fff" href="journals/createJournal">Create Journal</el-link></el-menu-item>
      <el-menu-item index="2-2"><el-link style="color:#fff" href="journals/updateJournal">Update Journal</el-link></el-menu-item>
      <el-menu-item index="2-3"><el-link style="color:#fff" href="journals/activateOrDeActJournal">Activate/Deactivate Journal</el-link></el-menu-item>
      <el-menu-item index="2-4"><el-link style="color:#fff" href="journals/reviewOrAccept">Push for Review/Acceptance</el-link></el-menu-item>
      <el-menu-item index="2-5"><el-link style="color:#fff" href="journals/resubOrRejectPaper">Push for Re-submission</el-link></el-menu-item>
      <el-menu-item index="2-6"><el-link style="color:#fff" href="journals/resubOrRejectPaper">Reject Paper</el-link></el-menu-item>
      <el-menu-item index="2-7"><el-link style="color:#fff" href="journals/publishPaper">Publish Paper</el-link></el-menu-item>
      <el-menu-item index="2-8"><el-link style="color:#fff" href="journals/jDashboard">Journal Dashboard</el-link></el-menu-item>
      <el-menu-item index="2-9"><el-link style="color:#fff" href="journals/jBalanceCheck">Account Balance</el-link></el-menu-item>
    </el-submenu>
    <el-submenu index="3">
      <template slot="title">Author Tasks</template>
      <el-menu-item index="3-1"><el-link style="color:#fff" href="authors/submitPaper">Submit Paper</el-link></el-menu-item>
      <el-menu-item index="3-2"><el-link style="color:#fff" href="paperTrackingService">Track Submitted Paper</el-link></el-menu-item>
      <el-menu-item index="3-3"><el-link style="color:#fff" href="authors/authorDashboard">Author Dashboard</el-link></el-menu-item>
      <el-menu-item index="3-4"><el-link style="color:#fff" href="authorProfile">Check Author works</el-link></el-menu-item>
      <el-menu-item index="3-5"><el-link style="color:#fff" href="payForPaperPublication">Pay for Accepted Paper</el-link></el-menu-item>
      <el-menu-item index="3-6"><el-link style="color:#fff" href="payToGetRestrictedPaper">Pay to get restricted paper</el-link></el-menu-item>
      <el-menu-item index="3-7"><el-link style="color:#fff" href="voteOnJreputation">Vote on Journal reputation</el-link></el-menu-item>
    </el-submenu>
    <el-submenu index="4">
      <template slot="title">Global users</template>
      <el-menu-item index="4-1"><el-link style="color:#fff" href="globalDashboard">Global Dashboard</el-link></el-menu-item>
      <el-menu-item index="4-2"><el-link style="color:#fff" href="proveOfAuthorship">Proof of authorship</el-link></el-menu-item>
      <el-menu-item index="4-3"><el-link style="color:#fff" href="authorProfile">Check Author Profile</el-link></el-menu-item>
      <el-menu-item index="4-4"><el-link style="color:#fff" href="paperTrackingService">Track Paper Status</el-link></el-menu-item>
      <el-menu-item index="4-5"><el-link style="color:#fff" href="globalDashboard">Total Open Access Publications</el-link></el-menu-item>
      <el-menu-item index="4-6"><el-link style="color:#fff" href="globalDashboard">Get all Open Access Papers</el-link></el-menu-item>
      <el-menu-item index="4-7"><el-link style="color:#fff" href="payForPaperPublication">Pay for Accepted Paper</el-link></el-menu-item>
      <el-menu-item index="4-8"><el-link style="color:#fff" href="payToGetRestrictedPaper">Pay to get restricted paper</el-link></el-menu-item>
      <el-menu-item index="4-9"><el-link style="color:#fff" href="voteOnJreputation">Vote on Journal reputation</el-link></el-menu-item>
    </el-submenu>
  </el-menu>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Head',
  data () {
    return {
      activeIndex: '1'
    }
  },
  methods: {
    handleSelect (key, keyPath) {
      console.log(key, keyPath)
    }
  }
}
</script>

<style scoped>
.header {
  height: 4.5rem;
  padding: 0.5rem 1rem;
  display: flex;
  background-color: #ffffff;
}
.logo {
  height: 3rem;
}

.menu {
  flex: 1;
  display: flex;
  /* align-items: center; */
  justify-content: flex-end;
}

.menu-item {
  text-decoration: none;
  color: #60bdfa;
  margin: 0 0.5rem;
}

#appHeadingOne{
    color: rgb(60, 87, 117);
    font-size: 2.3rem;
    font-family: sans-serif;
    margin: 0.5% auto;
}
el-menu-item:hover{
  text-decoration: cadetblue;
}
</style>
