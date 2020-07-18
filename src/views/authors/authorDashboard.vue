<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPage">Previous Page</el-link>
        </div>
        <el-row>
          <el-col :span="23" :offset="1">
            <el-col :span="7">
                    <h2 id="activityHub">Author dashboard - Activity hub</h2>
            </el-col>
            <el-col :span="5">
                    <h4 class="textPlacements">Task selection area</h4>
            </el-col>
            <el-col :span="7">
              <div class="rowAlignment">
                  <el-form
                      :model="authorBoardTasks"
                      :rules="rules"
                      ref="authorBoardTasks"
                      label-width="120px"
                  >
                      <el-form-item label="Required task" prop="authorTask">
                          <el-select
                              v-model="authorBoardTasks.authorTask"
                              style="width:100%"
                              placeholder="Please select the desired task.">
                              <el-option label="Submitted Papers" value="submittedPapers"></el-option>
                              <el-option label="Accepted papers" value="acceptedPapers"></el-option>
                              <el-option label="Papers to revise" value="papersToRevise"></el-option>
                              <el-option label="Rejected papers" value="rejectedPapers"></el-option>
                              <el-option label="Received paid papers" value="recPaidPapers"></el-option>
                              <el-option label="Published restricted papers" value="publishedRestrictedPapers"></el-option>
                          </el-select>
                      </el-form-item>
                    </el-form>
              </div>
            </el-col>
            <div class="rowAlignment">
            <el-col :span="5">
              <el-button type="primary" :loading="authorDashboardTaskBtnLoadState" @click="submitForm('authorBoardTasks')">Retrieve information</el-button>
            </el-col>
            </div>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24" :offset="0">
            <h4>Retrieved data appears below</h4>
            <div v-if="submittedPapers" v-loading="submittedPapersSubLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in submittedPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="acceptedPapers" v-loading="acceptedPapersSubLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in acceptedPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="papersToRevise" v-loading="papersToRevisebLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in papersToRevisetableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="rejectedPapers" v-loading="rejectedPapersLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in rejectedPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="recPaidPapers" v-loading="recPaidPapersLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in recPaidPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="publishedRestrictedPapers" v-loading="publishedRestrictedPapersLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in publishedRestrictedPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="defaultPageItem">
                <p>No data retrieved</p>
            </div>
          </el-col>
        </el-row>
    </div>
</template>

<script>
// @ is an alias to /src
import web3 from '@/assets/js/web3'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
import { getIPFSstring } from '@/assets/js/bufferConvert'
import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'

export default {
  // name: 'Home',
  data () {
    return {
      authorBoardTasks: {
        authorTask: ''
      },
      jSendPaperToUserForm: {
        ipfsHashOfRequestedPaper: ''
      },
      // Table data begins.
      pageTableData: [],
      reqPageTableData: [],
      // Table data ends.
      // Array to hold requested IPFS hashes of papers ends.
      submittedPapers: false,
      acceptedPapers: false,
      papersToRevise: false,
      rejectedPapers: false,
      recPaidPapers: false,
      publishedRestrictedPapers: false,
      defaultPageItem: false,
      jAccountIndexEntered: '',
      authorDashboardTaskBtnLoadState: false,
      submittedPapersSubLoading: false,
      acceptedPapersSubLoading: false,
      papersToRevisebLoading: false,
      rejectedPapersLoading: false,
      recPaidPapersLoading: false,
      publishedRestrictedPapersLoading: false,
      getRequestedLoadState: false,
      rules: {
        authorTask: [
          { required: true, message: 'Please select desired task', trigger: 'blur' }
        ],
        accountNum: [
          { required: true, message: 'Please input account number', trigger: 'blur' },
          { min: 1, max: 1, message: 'Number can only be from 0 to 9', trigger: 'blur' }
        ]
      },
      // Table labels begin.
      submittedPaperstableLabel: [
        { label: 'Title of submitted paper', prop: 'paperTitle', width: '360px' },
        { label: 'URL of Journal submitted', prop: 'jURL' }
      ],
      acceptedPaperstableLabel: [
        { label: 'Hash of accepted paper', prop: 'paperHash', width: '560px' },
        { label: 'Name of the Journal', prop: 'jName' }
      ],
      papersToRevisetableLabel: [
        { label: 'Hash of paper to revise', prop: 'paperHash', width: '560px' },
        { label: 'IPFS link to revision file', prop: 'revisionNote' }
      ],
      rejectedPaperstableLabel: [
        { label: 'Hash of rejected paper', prop: 'paperHash', width: '560px' },
        { label: 'IPFS link of rejection notice', prop: 'ipfsHashOfRejReason' }
      ],
      recPaidPaperstableLabel: [
        { label: 'IPFS link of requested paper', prop: 'paperIPFSHashReq', width: '560px' },
        { label: 'IPFS link to download file', prop: 'perUserIPFSencryptedLink' }
      ],
      publishedRestrictedPaperstableLabel: [
        { label: 'Title of paper', prop: 'paperTitle', width: '500px' },
        { label: 'IPFS hash of published paper', prop: 'paperIPFSHash' }
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
      inputPlaceholder: 'A number from 0 to 9.',
      inputPattern: /^[0-9]{1}$/
    }).then(({ value }) => {
      // Get and use web3 object.
      try {
        web3.eth.getAccounts().then(accounts => {
          console.log('Ethereum address of this author is: ', accounts[value])
          this.jAccountIndexEntered = value
          web3.eth.defaultAccount = accounts[value]
        })
      } catch {
        console.log('Error occured with web3')
        window.location.reload() // Reload page
      }
    }).catch((err) => {
      console.log('User has cancelled.', err)
      window.location.reload() // Reload page.
    })
  },
  methods: {
    submitForm (formName) {
      if (this.jAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          this.authorDashboardTaskBtnLoadState = true
          if (valid) {
            // Call different methods here based on journal's selection.
            if (this.authorBoardTasks.authorTask === 'submittedPapers') {
              this.getSubmittedPapers()
            } else if (this.authorBoardTasks.authorTask === 'acceptedPapers') {
              this.getAcceptedPapers()
            } else if (this.authorBoardTasks.authorTask === 'papersToRevise') {
              this.getPapersToRevise()
            } else if (this.authorBoardTasks.authorTask === 'rejectedPapers') {
              this.getRejectedPapers()
            } else if (this.authorBoardTasks.authorTask === 'recPaidPapers') {
              this.getReceivedPaidPapers()
            } else if (this.authorBoardTasks.authorTask === 'publishedRestrictedPapers') {
              this.getPublishedResPapers()
            }
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
    jPubKeyInputValidation (input) {
      const count = input.toString().length
      if (input === '' || isNaN(input) === true || input < 0 || count <= 63) {
        return 0
      } else {
        return 1
      }
    },
    backToPrvPage () {
      this.$router.push('/')
    },
    getSubmittedPapers () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.authorDashboardTaskBtnLoadState = true
      this.submittedPapersSubLoading = true
      // this.submittedPapers = false
      this.acceptedPapers = false
      this.papersToRevise = false
      this.rejectedPapers = false
      this.recPaidPapers = false
      this.publishedRestrictedPapers = false
      // Perform required task and return true.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance for access type retrieval created.')
      jpBlockContract.getPastEvents('paperSubDetails', { filter: { submittingAuthor: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
        (err, results) => {
          if (err) {
            this.submittedPapersSubLoading = false
            this.$message.error('Sorry! Error retrieving data. Please, try again later.')
          } else {
          // Get the data and display.
            if (Object.keys(results).length === 0) {
              this.authorDashboardTaskBtnLoadState = false
              this.defaultPageItem = true
            } else {
              // Results is not empty hence get and display.
              // console.log('Received submissions: ', results)
              console.log('Total submitted papers: ', Object.keys(results).length)
              for (let i = 0; i < Object.keys(results).length; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].paperTitle = web3.utils.hexToUtf8(results[i].returnValues.paperTitle)
                this.pageTableData[i].jURL = results[i].returnValues.jURL
              }
              this.authorDashboardTaskBtnLoadState = false
              this.submittedPapersSubLoading = false
              // console.log('Objet to display as table: ', this.pageTableData)
              this.submittedPapers = true
            }
          }
        })
    },
    getAcceptedPapers () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.authorDashboardTaskBtnLoadState = true
      this.acceptedPapersSubLoading = true
      this.submittedPapers = false
      // this.acceptedPapers = false
      this.papersToRevise = false
      this.rejectedPapers = false
      this.recPaidPapers = false
      this.publishedRestrictedPapers = false
      // Perform required task and return true.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance for access type retrieval created.')
      jpBlockContract.getPastEvents('noticeOfAcceptance', { filter: { submittingAuthor: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
        (err, results) => {
          if (err) {
            this.acceptedPapersSubLoading = false
            this.$message.error('Sorry! Error retrieving data. Please, try again later.')
          } else {
          // Get the data and display.
            if (Object.keys(results).length === 0) {
              this.authorDashboardTaskBtnLoadState = false
              this.defaultPageItem = true
            } else {
              // Results is not empty hence get and display.
              // console.log('Received submissions: ', results)
              console.log('Total accepted papers: ', Object.keys(results).length)
              for (let i = 0; i < Object.keys(results).length; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].paperHash = results[i].returnValues.paperHash
                this.pageTableData[i].jName = web3.utils.hexToAscii(results[i].returnValues.jName).replace(/[^a-z]/gi, '')
              }
              this.authorDashboardTaskBtnLoadState = false
              this.acceptedPapersSubLoading = false
              // console.log('Objet to display as table: ', this.pageTableData)
              this.acceptedPapers = true
            }
          }
        })
    },
    getPapersToRevise () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.authorDashboardTaskBtnLoadState = true
      this.papersToRevisebLoading = true
      this.submittedPapers = false
      this.acceptedPapers = false
      // this.papersToRevise = false
      this.rejectedPapers = false
      this.recPaidPapers = false
      this.publishedRestrictedPapers = false
      // Perform required task and return true.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance for access type retrieval created.')
      jpBlockContract.getPastEvents('noticeOfRevision', { filter: { submittingAuthor: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
        (err, results) => {
          if (err) {
            this.papersToRevisebLoading = false
            this.$message.error('Sorry! Error retrieving data. Please, try again later.')
          } else {
          // Get the data and display.
            if (Object.keys(results).length === 0) {
              this.authorDashboardTaskBtnLoadState = false
              this.defaultPageItem = true
            } else {
              // Results is not empty hence get and display.
              // console.log('Received submissions: ', results)
              console.log('Total of papers to revise: ', Object.keys(results).length)
              for (let i = 0; i < Object.keys(results).length; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].paperHash = results[i].returnValues.paperHash
                this.pageTableData[i].revisionNote = getIPFSstring(results[i].returnValues.revisionNote)
              }
              this.authorDashboardTaskBtnLoadState = false
              this.papersToRevisebLoading = false
              // console.log('Objet to display as table: ', this.pageTableData)
              this.papersToRevise = true
            }
          }
        })
    },
    getRejectedPapers () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.authorDashboardTaskBtnLoadState = true
      this.rejectedPapersLoading = true
      this.submittedPapers = false
      this.acceptedPapers = false
      this.papersToRevise = false
      // this.rejectedPapers = false
      this.recPaidPapers = false
      this.publishedRestrictedPapers = false
      // Perform required task and return true.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance for access type retrieval created.')
      jpBlockContract.getPastEvents('rejectionNotice', { filter: { submittingAuthor: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
        (err, results) => {
          if (err) {
            this.rejectedPapersLoading = false
            this.$message.error('Sorry! Error retrieving data. Please, try again later.')
          } else {
          // Get the data and display.
            if (Object.keys(results).length === 0) {
              this.authorDashboardTaskBtnLoadState = false
              this.defaultPageItem = true
            } else {
              // Results is not empty hence get and display.
              // console.log('Received submissions: ', results)
              console.log('Total number of rejected papers: ', Object.keys(results).length)
              for (let i = 0; i < Object.keys(results).length; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].paperHash = results[i].returnValues.paperHash
                this.pageTableData[i].ipfsHashOfRejReason = getIPFSstring(results[i].returnValues.ipfsHashOfRejReason)
              }
              this.authorDashboardTaskBtnLoadState = false
              this.rejectedPapersLoading = false
              // console.log('Objet to display as table: ', this.pageTableData)
              this.rejectedPapers = true
            }
          }
        })
    },
    getReceivedPaidPapers () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.authorDashboardTaskBtnLoadState = true
      this.recPaidPapersLoading = true
      this.submittedPapers = false
      this.acceptedPapers = false
      this.papersToRevise = false
      this.rejectedPapers = false
      // this.recPaidPapers = false
      this.publishedRestrictedPapers = false
      // Perform required task and return true.
      this.$prompt('Please enter the IPFS link you requested.', 'Information required', {
        confirmButtonText: 'Continue',
        cancelButtonText: 'Cancel',
        inputPlaceholder: 'IPFS hash of the paper.'
      }).then(({ value }) => {
        if (this.ipfsInputValidation(value) === 1) {
          console.log('Valid IPFS hash entered', value)
          var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
          console.log('Contract instance for received paid-for papers created.')
          jpBlockContract.getPastEvents('userRequestMet', { filter: { paperIPFSHashReq: [convertIPFSstringToBytes(value)] }, fromBlock: 0, toBlock: 'latest' },
            (err, results) => {
              if (err) {
                this.recPaidPapersLoading = false
                this.authorDashboardTaskBtnLoadState = false
                this.$message.error('Sorry! Error retrieving data. Please, try again later.')
              } else {
              // Get the data and display.
                if (Object.keys(results).length === 0) {
                  console.log('Empty data.')
                  this.authorDashboardTaskBtnLoadState = false
                  this.defaultPageItem = true
                } else {
                  // Results is not empty hence get and display.
                  console.log('Total paid for papers: ', Object.keys(results).length)
                  for (let i = 0; i < Object.keys(results).length; i++) {
                    this.pageTableData[i] = []
                    this.pageTableData[i].paperIPFSHashReq = getIPFSstring(results[i].returnValues.paperIPFSHashReq)
                    this.pageTableData[i].perUserIPFSencryptedLink = getIPFSstring(results[i].returnValues.perUserIPFSencryptedLink)
                  }
                  this.authorDashboardTaskBtnLoadState = false
                  this.recPaidPapersLoading = false
                  // console.log('Objet to display as table: ', this.pageTableData)
                  this.recPaidPapers = true
                }
              }
            })
        } else {
          this.recPaidPapersLoading = false
          this.authorDashboardTaskBtnLoadState = false
          this.$message('Invalid IPFS hash entered.')
        }
      }).catch((err) => {
        console.log('Error: ', err)
        this.authorDashboardTaskBtnLoadState = false
        this.$message('Operation canceled.')
      })
    },
    getPublishedResPapers () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.authorDashboardTaskBtnLoadState = true
      this.papersToRevisebLoading = true
      this.submittedPapers = false
      this.acceptedPapers = false
      this.papersToRevise = false
      this.rejectedPapers = false
      this.recPaidPapers = false
      // this.publishedRestrictedPapers = false
      // Perform required task and return true.
      this.$prompt('Please enter Ethereum address of the Journal.', 'Information required', {
        confirmButtonText: 'Continue',
        cancelButtonText: 'Cancel',
        inputPlaceholder: 'Eth address of the journal.',
        inputPattern: /^0x[0-9A-F]{40}$/i
      }).then(({ value }) => {
        if (web3.utils.isAddress(value) === true) {
          var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
          console.log('Contract instance for access type retrieval created.')
          jpBlockContract.getPastEvents('restrictedPaperPublished', { filter: { jAdd: [value] }, fromBlock: 0, toBlock: 'latest' },
            (err, results) => {
              if (err) {
                this.receivedSubLoading = false
                this.authorDashboardTaskBtnLoadState = false
                this.$message.error('Sorry! Error retrieving data. Please, try again later.')
              } else {
              // Get the data and display.
                if (Object.keys(results).length === 0) {
                  this.authorDashboardTaskBtnLoadState = false
                  this.defaultPageItem = true
                } else {
                  // Results is not empty hence get and display.
                  // console.log('Received submissions: ', results)
                  console.log('Total number of published papers: ', Object.keys(results).length)
                  for (let i = 0; i < Object.keys(results).length; i++) {
                    this.pageTableData[i] = []
                    this.pageTableData[i].paperTitle = web3.utils.hexToUtf8(results[i].returnValues.paperTitle)
                    this.pageTableData[i].paperIPFSHash = getIPFSstring(results[i].returnValues.paperIPFSHash)
                  }
                  this.authorDashboardTaskBtnLoadState = false
                  this.publishedRestrictedPapersLoading = false
                  // console.log('Objet to display as table: ', this.pageTableData)
                  this.publishedRestrictedPapers = true
                }
              }
            })
        } else {
          this.$message('Invalid Ethereum address. Please, reenter.')
        }
      }).catch((err) => {
        console.log('Error: ', err)
        this.authorDashboardTaskBtnLoadState = false
        this.$message('Operation canceled.')
      })
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
    margin-left: -2rem;
}

</style>
