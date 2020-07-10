<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPage">Previous Page</el-link>
        </div>
        <el-row>
          <el-col :span="23" :offset="1">
            <el-col :span="2">
                    <img class="authorImgFirst" src="../../assets/imgs/gUser1.png" />
            </el-col>
            <el-col :span="5">
                <h2 id="activityHub">The Global Dashboard</h2>
            </el-col>
            <el-col :span="9">
              <div class="rowAlignment">
                  <el-form
                      :model="gUserTasks"
                      :rules="rules"
                      ref="gUserTasks"
                      label-width="160px"
                  >
                      <el-form-item label="Available tasks" prop="gTask">
                          <el-select
                              v-model="gUserTasks.gTask"
                              style="width:100%"
                              placeholder="Please select the desired task.">
                              <el-option label="Total Open Access Publications" value="totalOAPub"></el-option>
                              <el-option label="Get all Open Access Papers" value="oaPapers"></el-option>
                              <el-option label="Published restricted papers" value="pubNonOApapers"></el-option>
                              <el-option label="View Registered Journals" value="regJournals"></el-option>
                              <el-option label="View details about a Journal" value="journalDetail"></el-option>
                          </el-select>
                      </el-form-item>
                    </el-form>
              </div>
            </el-col>
            <div class="rowAlignment">
            <el-col :span="2">
              <el-button type="primary" :loading="gUserBtnLoadState" @click="submitForm('gUserTasks')">Get data</el-button>
            </el-col>
            <el-col :span="3">
                    <img class="authorImgSecond" src="../../assets/imgs/authorPix.png" />
            </el-col>
            </div>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24" :offset="0">
            <div v-if="gUserData" v-loading="gUserPageLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="450px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in gUserDataLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="defaultPageItem">
                <p>No data available</p>
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
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
import { getIPFSstring } from '@/assets/js/bufferConvert'
// import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'

export default {
  // name: 'Home',
  data () {
    return {
      gUserTasks: {
        gTask: ''
      },
      userAccountNumForm: { accountNum: '' },
      userAccountIndexEntered: '',
      pageTableData: [],
      gUserData: false,
      defaultPageItem: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      gUserPageLoading: false,
      gUserBtnLoadState: false,
      rules: {
        gTask: [
          { required: true, message: 'Please select a desired task', trigger: 'blur' }
        ],
        accountNum: [
          { required: true, message: 'Please input user account number', trigger: 'blur' },
          { min: 1, max: 1, message: 'Number can only be from 0 to 9', trigger: 'blur' }
        ]
      },
      // Table labels begin.
      gUserDataLabel: [
        { label: 'IPFS hashes Open Access publications', prop: 'OApapers', width: '420px' }
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
          if (valid) {
            this.gUserPageLoading = true
            this.gUserBtnLoadState = true
            // Call different methods here based on journal's selection.
            if (this.gUserTasks.gTask === 'totalOAPub') {
              this.getTotalOApaper()
            } else if (this.gUserTasks.gTask === 'oaPapers') {
              this.getOAPapersOnJPBlock()
            } else if (this.gUserTasks.gTask === 'oaPapers') {

            } else if (this.gUserTasks.gTask === 'pubNonOApapers') {

            } else if (this.gUserTasks.gTask === 'regJournals') {

            } else if (this.gUserTasks.gTask === 'journalDetail') {

            }
          } else {
            console.log('Submission error.')
            this.gUserPageLoading = false
            this.gUserBtnLoadState = false
            return false
          }
        })
      } else {
        this.$message('Enter required user account. Reloading page...')
        window.location.reload()
      }
    },
    getTotalOApaper () {
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance created.')
      jpBlockContract.methods.countOpenAccessPublications().call({ from: web3.eth.defaultAccount }).then(res => {
        this.gUserPageLoading = false
        this.gUserBtnLoadState = false
        this.$alert('Current Open Access Publications: ' + res, 'Total Open Access Publications', {
          confirmButtonText: 'OK',
          callback: action => {
            this.$message({
              type: 'info',
              message: `action: ${action}`
            })
          }
        })
      })
    },
    getOAPapersOnJPBlock () {
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance created.')
      jpBlockContract.methods.getOpenAccesspapers().call({ from: web3.eth.defaultAccount }).then(res => {
        if (res.length > 0) {
          for (let i = 0; res.length; i++) {
            this.pageTableData[i] = []
            this.pageTableData[i].OApapers = getIPFSstring(res[i])
            this.gUserPageLoading = false
            this.gUserBtnLoadState = false
            this.gUserData = true
          }
        } else {
          this.gUserPageLoading = false
          this.gUserBtnLoadState = false
          this.$alert('No Open Access Publications found.', 'Status of Open Access Papers', {
            confirmButtonText: 'OK',
            callback: action => {
              this.$message({
                type: 'info',
                message: `action: ${action}`
              })
            }
          })
        }
      })
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

.authorImgFirst{
    margin-top: 0.5rem;
    height: 3rem;
}

.authorImgSecond{
    height: 3rem;
}

h3{ color: rgb(15, 91, 94);}
h4{ color: rgb(15, 91, 94); font-style: italic;}
p{ color: rgb(78, 150, 192);}

</style>
