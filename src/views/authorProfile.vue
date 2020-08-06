<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPage">Previous Page</el-link>
        </div>
        <el-row>
          <el-col :span="23" :offset="1">
            <el-col :span="2">
                    <img class="authorImgFirst" src="../assets/imgs/authorPix.png" />
            </el-col>
            <el-col :span="3">
                <h2 id="activityHub">Author Profile</h2>
            </el-col>
            <el-col :span="5">
              <h4 class="textPlacements">Author's Ethereum address</h4>
            </el-col>
            <el-col :span="9">
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
            <el-col :span="2">
              <el-button type="primary" :loading="authorProfileBtnLoadState" @click="submitForm('authorProfileForm')">Get Profile</el-button>
            </el-col>
            <el-col :span="3">
                    <img class="authorImgSecond" src="../assets/imgs/authorWorks1.png" />
            </el-col>
            </div>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24" :offset="0">
            <h4>Retrieved data appears below</h4>
            <div v-if="authorProfile" v-loading="authorProfileLoading">
              <el-col :span="5">
                <h3>Publication Statistics:</h3>
              </el-col>
              <el-col :span="5">
                <p>Total Publications</p><h4>{{totalPubs}}</h4>
              </el-col>
              <el-col :span="5">
                <p>Total Open Access</p><h4>{{totalOAPubs}}</h4>
              </el-col>
              <el-col :span="5">
                <p>Total non-Open Access</p><h4>{{totalNonOAPubs}}</h4>
              </el-col>
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="450px"
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
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
import { getIPFSstring } from '@/assets/js/bufferConvert'
// import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'

export default {
  // name: 'Home',
  data () {
    return {
      authorProfileForm: {
        authorEthAddress: ''
      },
      totalPubs: '',
      totalOAPubs: '',
      totalNonOAPubs: '',
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
          { required: true, message: 'Please input Eth address of the author', trigger: 'blur' },
          { min: 20, message: 'Please input a valid Eth address', trigger: 'blur' }
        ],
        accountNum: [
          { required: true, message: 'Please input user account number', trigger: 'blur' },
          { min: 1, max: 1, message: 'Number can only be from 0 to 9', trigger: 'blur' }
        ]
      },
      // Table labels begin.
      authorProfileLabel: [
        { label: 'Paper Hashes', prop: 'pubHashes', width: '460px' },
        { label: 'Journals', prop: 'pubJournals', width: '180px' },
        { label: 'IPFS hashes OA papers', prop: 'OApapers', width: '410px' },
        { label: 'Paper title', prop: 'paperTitles' }
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
          this.authorProfileBtnLoadState = true
          this.authorProfileLoading = true
          if (web3.utils.isAddress(this.authorProfileForm.authorEthAddress) === true) {
            var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
            console.log('Contract instance created.')
            // Smart contract and other logic continues.
            jpBlockContract.methods.retrieveAuthorWorks(this.authorProfileForm.authorEthAddress).call({ from: web3.eth.defaultAccount }).then(res => {
              console.log('Retrieved author package: ', res)
              // var tempTable = []
              console.log('Items: ', res[0])
              if (res[0] >= 1) { // Checking for zero publications.
                for (let i = 0; i < Object.keys(res[1]).length; i++) {
                  this.pageTableData[i] = []
                  // this.pageTableData[i].totalPublications = res[0]
                  this.pageTableData[i].pubHashes = res[1][i] // Paper hashes.
                  this.pageTableData[i].pubJournals = web3.utils.hexToAscii(res[2][i]).replace(/[^a-z]/gi, '') // Journals.
                  // Regrex for ^ negation of the set (word, underscores and whitespace) enclosed in [] and making them global and case-insenstitive.
                  this.pageTableData[i].paperTitles = web3.utils.hexToAscii(res[5][i]).replace(/[^\w\s]/gi, '') // Paper titles.
                  if (res[4].length > 0) {
                    for (let x = 0; x < res[4].length; x++) {
                      this.pageTableData[x].OApapers = getIPFSstring(res[4][x]) // All OA papers.
                    }
                  }
                }
                this.totalPubs = res[0]
                this.totalOAPubs = res[3]
                this.totalNonOAPubs = this.totalPubs - this.totalOAPubs
                this.authorProfileBtnLoadState = false
                this.authorProfileLoading = false
                this.authorProfile = true
              } else {
                this.authorProfileBtnLoadState = false
                this.authorProfileLoading = false
                this.authorProfile = false
                this.$alert('This author has no publication on JPBlock.', 'Author Profile on JPBlock', {
                  confirmButtonText: 'OK',
                  callback: action => {
                    this.$message({
                      type: 'info',
                      message: `action: ${action}`
                    })
                  }
                })
              }
            }).catch((err) => {
              this.authorProfileBtnLoadState = false
              this.authorProfileLoading = false
              console.log('Error occured.', err)
            })
          } else {
            this.authorProfileBtnLoadState = false
            this.authorProfileLoading = false
            this.$message('Invalid Ethereum address entered. Please, reenter.')
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
