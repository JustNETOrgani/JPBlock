<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPage">Previous Page</el-link>
        </div>
        <el-row>
          <el-col :span="23" :offset="1">
            <el-col :span="2">
                    <img class="authorImgs" src="../assets/imgs/authorWorks1.png" />
            </el-col>
            <el-col :span="3">
                <h2 id="activityHub">Author Profile</h2>
            </el-col>
            <el-col :span="6">
                    <h4 class="textPlacements">Author's Ethereum address</h4>
            </el-col>
            <el-col :span="7">
              <div class="rowAlignment">
                  <el-form
                      :model="authorProfileForm"
                      :rules="rules"
                      ref="authorProfileForm"
                      label-width="120px"
                  >
                      <el-form-item prop="authorEthAddress">
                            <el-input clearable v-model="authorProfileForm.authorEthAddress" placeholder="Please enter Eth address of author."></el-input>
                        </el-form-item>
                    </el-form>
              </div>
            </el-col>
            <div class="rowAlignment">
            <el-col :span="3">
              <el-button type="primary" :loading="authorProfileBtnLoadState" @click="submitForm('authorProfileForm')">Get Profile</el-button>
            </el-col>
            <el-col :span="3">
                    <img class="authorImgs" src="../assets/imgs/authorWorks2.png" />
            </el-col>
            </div>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24" :offset="0">
            <h4>Retrieved data appears below</h4>
            <div v-if="authorProfile" v-loading="authorProfileLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in authorProfileLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="defaultPageItem">
                <p>No author profile data retrieved</p>
            </div>
          </el-col>
        </el-row>
        <el-dialog title="User's Ethereum Account" width="30%" :visible.sync="userAccountDialog">
            <el-form :model="userAccountNumForm"
            :rules="rules"
            ref="userAccountNumForm">
                <el-form-item label="Account Number" prop="accountNum">
                <el-input v-model="userAccountNumForm.accountNum" autocomplete="off"></el-input>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="userAccountDialog = false">Cancel</el-button>
                <el-button :loading="getUserAccountLoadState" type="primary" @click="getUseraccountOnPageLoad('userAccountNumForm')">Confirm</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
// @ is an alias to /src
import web3 from '@/assets/js/web3'
// import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
// import { getIPFSstring } from '@/assets/js/bufferConvert'
// import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'

export default {
  // name: 'Home',
  data () {
    return {
      authorProfileForm: {
        authorEthAddress: ''
      },
      userAccountNumForm: { accountNum: '' },
      userAccountIndexEntered: '',
      pageTableData: [],
      authorProfile: false,
      defaultPageItem: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      authorProfileLoading: false,
      authorProfileBtnLoadState: false,
      rules: {
        authorEthAddress: [
          { required: true, message: 'Please input Eth address of author', trigger: 'blur' },
          { min: 20, message: 'Please input a valid Eth address', trigger: 'blur' }
        ],
        accountNum: [
          { required: true, message: 'Please input user account number', trigger: 'blur' },
          { min: 1, max: 1, message: 'Number can only be from 0 to 9', trigger: 'blur' }
        ]
      },
      // Table labels begin.
      authorProfileLabel: [
        { label: 'Title of submitted paper', prop: 'paperTitle', width: '360px' },
        { label: 'URL of Journal submitted', prop: 'jURL' }
      ]
      // Table labels end.
    }
  },
  components: {
    // Head
    // Footer
  },
  created () {
    this.defaultPageItem = true
    this.$prompt('Please enter your Ethereum account.', 'Information required', {
      confirmButtonText: 'Continue',
      cancelButtonText: 'Cancel',
      inputPlaceholder: 'A number from 0 to 9.'
    }).then(({ value }) => {
      // Get and use web3 object.
      try {
        web3.eth.getAccounts().then(accounts => {
          console.log('Ethereum address of this author is: ', accounts[value])
          this.userAccountIndexEntered = value
          web3.eth.defaultAccount = accounts[value]
        })
      } catch { console.log('Error occured with web3') }
    })
  },
  methods: {
    submitForm (formName) {
      if (this.userAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          this.authorProfileBtnLoadState = true
          if (valid) {
            console.log('Getting profile of author with address: ', this.authorProfileForm.authorEthAddress)
          } else {
            console.log('Submission error.')
            this.authorDashboardTaskBtnLoadState = false
            return false
          }
        })
      } else {
        this.$message('Enter required user account. Reloading page...')
        window.location.reload()
      }
    },
    getAuthorProfile () {
      console.log('Inside author profile')
      this.authorProfile = false
    },
    backToPrvPage () {
      this.$router.push('/')
    },
    convertHextoBytes (hexString) {
      var bytes = new Uint8Array(Math.ceil(hexString.length / 2))
      for (var i = 0; i < bytes.length; i++) bytes[i] = parseInt(hexString.substr(i * 2, 2), 16)
      return bytes
    },
    ipfsInputValidation (input) {
      const count = input.toString().length
      if (input === '' || count < 46 || input.startsWith('Qm') === false) { // More validation needed.
        return 0
      } else {
        return 1
      }
    },
    getUseraccountOnPageLoad (formName) {
      this.$refs[formName].validate(valid => {
        if (valid) {
          this.getUserAccountLoadState = true
          this.userAccountIndexEntered = this.userAccountNumForm.accountNum
          // Get and use web3 object.
          try {
            web3.eth.getAccounts().then(accounts => {
              console.log('Ethereum address of this Journal is: ', accounts[this.userAccountIndexEntered])
              web3.eth.defaultAccount = accounts[this.userAccountIndexEntered]
            })
          } catch { console.log('Error occured with web3') }
          this.getUserAccountLoadState = false
          this.userAccountDialog = false
        }
      })
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
  margin-top: 0.5rem;
  width: 100%;
  height: 5%;
}

#headingTop {
  background-color: #ffffff;
  border-radius: 4px;
  margin: 0.6% auto;
  width: 100%;
  padding: 0.2rem 1.5rem;
}

#headingTitle{
  width: 30%;
  float: left;
}

#topRight{
  background-color: #ffffff;
  width: 68%;
}

#activityHub{
  text-align: left;
}

#midLeft {
  background-color: #ffffff;
  margin: 0.1% auto;
  width: 20%;
  padding: 0.2rem 2.5rem;
  float: left;
}

.rowAlignment{
  margin-top: 0.8rem;
}

.textPlacements{
    margin-left: 3rem;
}

.authorImgs{
    height: 3rem;
}

</style>
