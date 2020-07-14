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
            <div v-if="gUserNonOAdata" v-loading="gUserNonOApageLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="450px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in gUserNonOAdataLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-if="jDetails" v-loading="jDetailspageLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="450px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in jDetailsDataLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-if="regJournalsData" v-loading="regJsPageLoading">
              <el-col :span="8">
                <h3>Total number of registered Journals:</h3>
              </el-col>
              <el-col :span="2">
                <h4>{{totalRegJ}}</h4>
              </el-col>
                <el-table
                :data="pageTableData.filter(data => !search || data.jName.toLowerCase().includes(search.toLowerCase()))"
                style="width: 100%"
                height="450px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in regJournalsDataLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
                <el-table-column
                  align="right">
                  <template slot="header">
                    <el-input
                      v-model="search"
                      size="mini"
                      placeholder="Search by Journal's name"/>
                  </template>
                </el-table-column>
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
      totalRegJ: '',
      pageTableData: [],
      search: '',
      gUserData: false,
      jDetails: false,
      gUserNonOAdata: false,
      regJournalsData: false,
      defaultPageItem: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      gUserPageLoading: false,
      jDetailspageLoading: false,
      regJsPageLoading: false,
      gUserNonOApageLoading: false,
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
        { label: 'IPFS hashes of Open Access publications', prop: 'OApapers', width: '420px' }
      ],
      gUserNonOAdataLabel: [
        { label: 'Title of paper', prop: 'paperTitle', width: '300px' },
        { label: 'IPFS hashes of non Open Access publications', prop: 'paperIPFSHash', width: '420px' }
      ],
      jDetailsDataLabel: [
        { label: 'Name of Journal', prop: 'jName', width: '150px' },
        { label: 'URL of Journal', prop: 'jURL', width: '190px' },
        { label: 'State of Journal', prop: 'jState', width: '150px' },
        { label: 'Public Key of Journal', prop: 'jPubKey', width: '300px' },
        { label: 'Reputation score', prop: 'jReputationScore', width: '100px' },
        { label: 'Impact Factor', prop: 'jIF', width: '80px' },
        { label: 'Publications', prop: 'jTotalPub', width: '110px' },
        { label: 'OA price', prop: 'jOAprice', width: '100px' },
        { label: 'Non-OA price', prop: 'jnOAprice', width: '90px' },
        { label: 'Request paper (Eth)', prop: 'jReqPrice', width: '125px' }
      ],
      regJournalsDataLabel: [
        { label: 'Name of journal', prop: 'jName', width: '360px' },
        { label: 'Eth address of journal', prop: 'jAdd', width: '380px' }
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
      } catch {
        console.log('Error occured with web3')
        window.location.reload() // Reload page.
      }
    }).catch((err) => {
      console.log('User has cancelled.', err)
      window.location.reload() // Reload page.
    })
  },
  methods: {
    submitForm (formName) {
      if (this.userAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          if (valid) {
            // Call different methods here based on journal's selection.
            if (this.gUserTasks.gTask === 'totalOAPub') {
              this.gUserPageLoading = true
              this.gUserBtnLoadState = true
              this.getTotalOApaper()
            } else if (this.gUserTasks.gTask === 'oaPapers') {
              this.gUserPageLoading = true
              this.gUserBtnLoadState = true
              this.getOAPapersOnJPBlock()
            } else if (this.gUserTasks.gTask === 'pubNonOApapers') {
              this.gUserNonOApageLoading = true
              this.gUserBtnLoadState = true
              this.getPubNonOApapers()
            } else if (this.gUserTasks.gTask === 'regJournals') {
              this.regJsPageLoading = true
              this.gUserBtnLoadState = true
              this.getRegJournals()
            } else if (this.gUserTasks.gTask === 'journalDetail') {
              this.jDetailspageLoading = true
              this.gUserBtnLoadState = true
              this.getAjournalDetail()
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
      this.gUserData = false
      this.jDetails = false
      this.gUserNonOAdata = false
      this.regJournalsData = false
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
      this.jDetails = false
      this.gUserNonOAdata = false
      this.regJournalsData = false
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance created.')
      jpBlockContract.methods.getOpenAccesspapers().call({ from: web3.eth.defaultAccount }).then(res => {
        if (res.length > 0) {
          for (let i = 0; i < res.length; i++) {
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
    getPubNonOApapers () {
      this.gUserData = false
      this.jDetails = false
      this.regJournalsData = false
      this.$prompt('Please enter Eth address of the journal.', 'Required information', {
        confirmButtonText: 'Continue',
        cancelButtonText: 'Cancel',
        inputPlaceholder: 'Eth address of the journal.',
        inputPattern: /^0x[0-9A-F]{40}$/i
      }).then(({ value }) => {
        if (web3.utils.isAddress(value) === true) {
          var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
          console.log('Contract instance created.')
          jpBlockContract.getPastEvents('restrictedPaperPublished', { filter: { jAdd: [value] }, fromBlock: 0, toBlock: 'latest' },
            (err, results) => {
              if (err) {
                this.gUserNonOApageLoading = false
                this.gUserBtnLoadState = false
                this.$message.error('Sorry! Error retrieving data. Please, try again later.')
              } else {
                if (Object.keys(results) > 0) {
                  for (let i = 0; i < Object.keys(results).length; i++) {
                    this.pageTableData[i] = []
                    this.pageTableData[i].paperTitle = web3.utils.hexToUtf8(results[i].returnValues.paperTitle)
                    this.pageTableData[i].paperIPFSHash = getIPFSstring(results[i].returnValues.paperIPFSHash)
                  }
                  this.gUserNonOApageLoading = false
                  this.gUserBtnLoadState = false
                  this.gUserNonOAdata = true
                } else {
                  this.gUserNonOApageLoading = false
                  this.gUserBtnLoadState = false
                  this.$alert('This journal has no non-OA Publications yet.', 'Status of non-Open Access papers.', {
                    confirmButtonText: 'OK',
                    callback: action => {
                      this.$message({
                        type: 'info',
                        message: `action: ${action}`
                      })
                    }
                  })
                }
              }
            })
        } else {
          this.gUserPageLoading = false
          this.gUserBtnLoadState = false
          this.$message('Invalid Ethereum address format.')
        }
      })
    },
    getAjournalDetail () {
      this.gUserData = false
      this.gUserNonOAdata = false
      this.regJournalsData = false
      this.$prompt('Please enter Eth address of the journal.', 'Required information', {
        confirmButtonText: 'Continue',
        cancelButtonText: 'Cancel',
        inputPlaceholder: 'Eth address of the journal.',
        inputPattern: /^0x[0-9A-F]{40}$/i
      }).then(({ value }) => {
        if (web3.utils.isAddress(value) === true) {
          var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
          console.log('Contract instance created.')
          jpBlockContract.methods.getAjournalDetail(value).call({ from: web3.eth.defaultAccount }).then(res => {
            // console.log('Total elements: ', Object.keys(res).length)
            if (Object.keys(res).length > 0) {
              for (let i = 0; i < 1; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].jName = web3.utils.hexToAscii(res[0]).replace(/[^a-z]/gi, '')
                this.pageTableData[i].jURL = res[1]
                this.pageTableData[i].jState = res[2]
                this.pageTableData[i].jReputationScore = res[3]
                this.pageTableData[i].jTotalPub = res[4]
                this.pageTableData[i].jIF = res[5] / 10 // To represent it as a decimal number.
                this.pageTableData[i].jOAprice = web3.utils.fromWei(res[6], 'ether')
                this.pageTableData[i].jnOAprice = web3.utils.fromWei(res[7], 'ether')
                this.pageTableData[i].jReqPrice = web3.utils.fromWei(res[8], 'ether')
                this.pageTableData[i].jPubKey = res[9]
              }
              this.jDetailspageLoading = false
              this.gUserBtnLoadState = false
              this.jDetails = true
            } else {
              this.jDetailspageLoading = false
              this.gUserBtnLoadState = false
              this.$message('Sorry! This is not a registered journal on JPBlock.')
            }
          }).catch((err) => {
            this.jDetailspageLoading = false
            this.gUserBtnLoadState = false
            console.log('Error getting journal detail: ', err)
            this.$message.error('Sorry! Error getting journal detail. Please, try again later.')
          })
        } else {
          this.jDetailspageLoading = false
          this.gUserBtnLoadState = false
          this.$message('Invalid Ethereum address format.')
        }
      })
    },
    getRegJournals () {
      this.gUserData = false
      this.gUserNonOAdata = false
      this.jDetails = false
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance created.')
      jpBlockContract.methods.getRegisteredJournals().call({ from: web3.eth.defaultAccount }).then(res => {
        console.log('Number of Journals: ', res[0])
        if (res[0] > 0) {
          for (let i = 0; i < res[1].length; i++) {
            this.pageTableData[i] = []
            this.pageTableData[i].jName = web3.utils.hexToAscii(res[2][i]).replace(/[^\w\s]/gi, '')
            this.pageTableData[i].jAdd = res[1][i]
          }
          this.totalRegJ = res[0]
          this.regJsPageLoading = false
          this.gUserBtnLoadState = false
          this.regJournalsData = true
        } else {
          this.regJsPageLoading = false
          this.gUserBtnLoadState = false
          this.$alert('Sorry! There is no registered journal at the moment on JPBlock.', 'Journals on JPBlock', {
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
