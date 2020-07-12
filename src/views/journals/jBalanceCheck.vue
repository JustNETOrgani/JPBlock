<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea">
          <el-row>
            <el-col :span="6" :offset="9">
              <img id="accBalImg" src="../../assets/imgs/accountBal.png" />
            </el-col>
          </el-row>
            <h2>Journal account balance tracker</h2>
            <el-row>
                <el-col :span="18" :offset="3">
                    <div class="grid-content bg-purple-dark">
                        <el-button :loading="getAccBalLoadBtn" @click="getJBalance" type="primary" round>Check balance</el-button>
                        <p class="hashValues"><i>{{jAccountBalance}}</i></p>
                    </div>
                </el-col>
            </el-row>
        </div>
        <el-dialog title="User's Ethereum Account" width="30%" :visible.sync="jAccountDialog">
            <el-form :model="userAccountNumForm"
            :rules="rules"
            ref="userAccountNumForm">
                <el-form-item label="Account Number" prop="accountNum">
                <el-input v-model="userAccountNumForm.accountNum" autocomplete="off"></el-input>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="pgReload()">Cancel</el-button>
                <el-button :loading="getJaccountLoadState" type="primary" @click="getUseraccountOnPageLoad('userAccountNumForm')">Confirm</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
// import Head from '@/components/header'
import web3 from '@/assets/js/web3'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
// import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      userAccountNumForm: { accountNum: '' },
      jAccountBalance: '',
      userAccountIndexEntered: '',
      paperTrackBtnLoadState: false,
      jAccountDialog: false,
      getJaccountLoadState: false,
      getAccBalLoadBtn: false,
      rules: {
        accountNum: [
          { required: true, message: 'Please input address of the journal.', trigger: 'blur' },
          { min: 1, max: 1, message: 'Can only be a number from 0 to 9', trigger: 'blur' }
        ]
      }
    }
  },
  components: {
    // Head
    // Footer
  },
  created () {
    this.jAccountDialog = true
  },
  methods: {
    getJBalance () {
      this.getAccBalLoadBtn = true
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance created.')
      // Smart contract and other logic continues.
      jpBlockContract.methods.getAmtAccrued().call({ from: web3.eth.defaultAccount }).then(res => {
        this.getAccBalLoadBtn = false
        this.jAccountBalance = web3.utils.fromWei(res, 'ether') + ' Ether'
      }).catch((error) => {
        console.log('Error occurred.', error)
        this.getAccBalLoadBtn = false
        this.$message.error('Sorry! Transaction error. Please, try again later.')
      })
    },
    getUseraccountOnPageLoad (formName) {
      this.$refs[formName].validate(valid => {
        if (valid) {
          this.getJaccountLoadState = true
          this.userAccountIndexEntered = this.userAccountNumForm.accountNum
          // Get and use web3 object.
          try {
            web3.eth.getAccounts().then(accounts => {
              console.log('Ethereum address of this Journal is: ', accounts[this.userAccountIndexEntered])
              web3.eth.defaultAccount = accounts[this.userAccountIndexEntered]
            })
          } catch { console.log('Error occured with web3') }
          this.getJaccountLoadState = false
          this.jAccountDialog = false
        }
      })
    },
    backToPrvPack () {
      this.$router.push('/')
    },
    pgReload () {
      window.location.reload()
    }
  }
}
</script>

<style scoped>
#pageContainer {
  height: 100%;
  display: flex;
  flex-direction: column;
}

#topNav{
  width: 100%;
  height: 5%;
}

.formArea {
  background-color: #ffffff;
  border-radius: 4px;
  margin: 2.5% auto;
  width: 48%;
  padding: 1rem 1.5rem;
}

#accBalImg{
    margin-top: 0.4rem;
    width: 7rem;
    height: 5rem;
    border-radius: 30rem;
}
</style>
