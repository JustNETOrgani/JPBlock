<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPage">Previous Page</el-link>
        </div>
        <el-row>
          <el-col :span="23" :offset="1">
            <el-col :span="7">
              <h3 id="activityHub">Journal dashboard - Activity hub</h3>
            </el-col>
            <el-col :span="5">
                    <h4 class="textPlacements">Task selection area</h4>
            </el-col>
            <el-col :span="7">
              <div class="rowAlignment">
                  <el-form
                      :model="jBoardTasks"
                      :rules="rules"
                      ref="jBoardTasks"
                      label-width="120px"
                  >
                      <el-form-item label="Required task" prop="jTask">
                          <el-select
                              v-model="jBoardTasks.jTask"
                              style="width:100%"
                              placeholder="Please select the desired task.">
                              <el-option label="Received Submissions" value="recSub"></el-option>
                              <el-option label="Revised Submissions" value="revisedSub"></el-option>
                              <el-option label="Paid papers" value="paymentsMade"></el-option>
                              <el-option label="Requested Papers" value="requestedPaper"></el-option>
                              <el-option label="Send Paper to user" value="sendPaperToUser"></el-option>
                          </el-select>
                      </el-form-item>
                    </el-form>
              </div>
            </el-col>
            <div class="rowAlignment">
            <el-col :span="5">
              <el-button type="primary" :loading="jDashboardTaskBtnLoadState" @click="submitForm('jBoardTasks')">Submit</el-button>
            </el-col>
            </div>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24" :offset="0">
            <h4>Retrieved data appears below</h4>
            <div v-if="receivedSub" v-loading="receivedSubLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in receivedPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="revisedSub" v-loading="revSubLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in revisedPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="paidPapers" v-loading="paidPapersbLoading">
                <el-table
                :data="pageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in paidPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="reqPaper" v-loading="reqPapersLoading">
                <el-table
                :data="reqPageTableData"
                style="width: 100%"
                height="550px"
                >
                <!--Building table body-->
                <template v-for="(item, index) in reqPaperstableLabel">
                  <el-table-column
                    :key="index"
                    :prop="item.prop"
                    :label="item.label" :width="item.width">
                  </el-table-column>
                </template>
              </el-table>
            </div>
            <div v-else-if="sendPaperToUser" v-loading="sendPaperLoading">
                <p>Sending paper to user initated...</p>
            </div>
            <div v-else-if="defaultPageItem">
                <p>No data retrieved</p>
            </div>
            <el-dialog title="Send requested paper to user" width="36%" :visible.sync="captureSendPaperToUserDialog">
                  <el-form :model="jSendPaperToUserForm"
                  :rules="rules"
                  ref="jSendPaperToUserForm">
                      <el-form-item label="IPFS has of requested paper" prop="ipfsHashOfRequestedPaper">
                        <el-select
                          v-model="jSendPaperToUserForm.ipfsHashOfRequestedPaper"
                          style="width:100%"
                          placeholder="Please select IPFS hash of requested paper"
                          value-key="id">
                          <el-option
                            v-for="reqIPFShash in reqIPFShashes"
                            :key="reqIPFShash.id"
                            :label="reqIPFShash.hash"
                            :value="reqIPFShash">
                          </el-option>
                        </el-select>
                      </el-form-item>
                  </el-form>
                  <span slot="footer" class="dialog-footer">
                      <el-button @click="captureSendPaperToUserDialog = false">Cancel</el-button>
                      <el-button :loading="getRequestedLoadState" type="primary" @click="sendReqPaperToUser('jSendPaperToUserForm')">Confirm</el-button>
                  </span>
                </el-dialog>
          </el-col>
        </el-row>
    </div>
</template>

<script>
// @ is an alias to /src
import web3 from '@/assets/js/web3'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
import { getIPFSstring } from '@/assets/js/bufferConvert'
import { generateKeyPair, asymmEncrypt } from '@/assets/js/asymmEncrypt'
import { symDecrypt } from '@/assets/js/symEncryptAndDec'
import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'
const ipfs = new window.Ipfs()

export default {
  // name: 'Home',
  data () {
    return {
      jBoardTasks: {
        jTask: ''
      },
      jSendPaperToUserForm: {
        ipfsHashOfRequestedPaper: ''
      },
      // Table data begins.
      pageTableData: [],
      reqPageTableData: [],
      // Table data ends.
      // Array to hold requested IPFS hashes of papers begins.
      reqIPFShashes: [],
      // Array to hold requested IPFS hashes of papers ends.
      receivedSub: false,
      revisedSub: false,
      paidPapers: false,
      reqPaper: false,
      sendPaperToUser: false,
      defaultPageItem: false,
      jAccountIndexEntered: '',
      jDashboardTaskBtnLoadState: false,
      captureSendPaperToUserDialog: false,
      getJAccountLoadState: false,
      receivedSubLoading: false,
      revSubLoading: false,
      paidPapersbLoading: false,
      reqPapersLoading: false,
      sendPaperLoading: false,
      getRequestedLoadState: false,
      rules: {
        jTask: [
          { required: true, message: 'Please select desired task', trigger: 'blur' }
        ],
        accountNum: [
          { required: true, message: 'Please input account number', trigger: 'blur' },
          { min: 1, max: 1, message: 'Number can only be from 0 to 9', trigger: 'blur' }
        ]
      },
      // Table labels begin.
      receivedPaperstableLabel: [
        { label: 'Paper Hash', prop: 'paperHash', width: '320px' },
        { label: 'IPFS hash', prop: 'paperIPFShash' },
        { label: 'Paper Title', prop: 'paperTitle' },
        { label: 'Submitting author', prop: 'submittingAuthor' },
        { label: 'Authors public key', prop: 'userPubKey' },
        { label: 'IPFS hash of Suppl. paper', prop: 'suppleFileIPFShash' }
      ],
      revisedPaperstableLabel: [
        { label: 'Hash of the original paper', prop: 'origPaperHash', width: '560px' },
        { label: 'Hash of the revised paper', prop: 'newPaperHash' }
      ],
      paidPaperstableLabel: [
        { label: 'Payee', prop: 'source', width: '380px' },
        { label: 'Hash of the paid paper', prop: 'paperHash' }
      ],
      reqPaperstableLabel: [
        { label: 'IPFS hash of requested paper', prop: 'IPFShash', width: '440px' },
        { label: 'Public key of requestee', prop: 'userPUbKey' }
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
    this.$prompt('Please enter Ethereum account of this journal.', 'Information required', {
      confirmButtonText: 'Continue',
      cancelButtonText: 'Cancel',
      inputPlaceholder: 'A number from 0 to 9.',
      inputPattern: /^[0-9]{1}$/
    }).then(({ value }) => {
      // Get and use web3 object.
      try {
        web3.eth.getAccounts().then(accounts => {
          console.log('Ethereum address of this Journal is: ', accounts[value])
          this.jAccountIndexEntered = value
          web3.eth.defaultAccount = accounts[value]
          // Get requested paper IPFS hashes into array.
          var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
          console.log('Contract instance for access type retrieval created.')
          jpBlockContract.getPastEvents('userRequestedPaper', { filter: { jAdd: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
            (err, results) => {
              if (err) {
                this.receivedSubLoading = false
                this.$message.error('Sorry! Error retrieving data. Please, try again later.')
              } else {
                // Get the data and display.
                if (Object.keys(results).length === 0) {
                  this.defaultPageItem = true
                  console.log('No requested papers yet.')
                } else {
                  // Results is not empty hence get and display.
                  // console.log('Received submissions: ', results)
                  console.log('Total of requested papers: ', Object.keys(results).length)
                  var tempArray = []
                  for (let i = 0; i < Object.keys(results).length; i++) {
                    this.reqPageTableData[i] = []
                    tempArray[i] = []
                    this.reqPageTableData[i].IPFShash = getIPFSstring(results[i].returnValues.IPFShash)
                    tempArray[i] = { id: i, hash: this.reqPageTableData[i].IPFShash }
                    this.reqPageTableData[i].userPUbKey = results[i].returnValues.userPUbKey
                  }
                  this.reqIPFShashes = [...new Set(tempArray.map(item => item.hash))]
                }
              }
            })
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
      if (this.jAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          this.jDashboardTaskBtnLoadState = true
          if (valid) {
            // Call different methods here based on journal's selection.
            if (this.jBoardTasks.jTask === 'recSub') {
              // console.log('Preparing to retrieve submitted papers')
              this.getReceivedSub()
              return
            } else if (this.jBoardTasks.jTask === 'revisedSub') {
              // console.log('Preparing to retrieve revised papers')
              this.getRevisedSub()
              return
            } else if (this.jBoardTasks.jTask === 'paymentsMade') {
              // console.log('Preparing to retrieve accepted paid papers')
              this.getPaidPapers()
              return
            } else if (this.jBoardTasks.jTask === 'requestedPaper') {
              // console.log('Preparing to retrieve requested papers')
              this.getReqPaper()
              return
            } else if (this.jBoardTasks.jTask === 'sendPaperToUser') {
              // console.log('Preparing for send paper to user procedure.')
              if (this.reqIPFShashes.length === 0) {
                this.defaultPageItem = true
                this.$alert('There exist no requested paper to be sent.', 'Status of requested papers.', {
                  confirmButtonText: 'OK',
                  callback: action => {
                    this.$message({
                      type: 'info',
                      message: `action: ${action}`
                    })
                  }
                })
              } else {
                this.captureSendPaperToUserDialog = true
              }
            }
            this.jDashboardTaskBtnLoadState = false
          } else {
            console.log('Submission error.')
            this.jDashboardTaskBtnLoadState = false
            return false
          }
        })
      } else {
        this.$message('Enter required journal account. Reloading page...')
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
    getReceivedSub () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.jDashboardTaskBtnLoadState = false
      this.receivedSubLoading = true
      this.defaultPageItem = false
      this.revisedSub = false
      this.reqPaper = false
      this.sendPaperToUser = false
      this.paidPapers = false
      // Perform required task and return true.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance for access type retrieval created.')
      jpBlockContract.getPastEvents('journalRecSub', { filter: { jAddress: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
        (err, results) => {
          if (err) {
            this.receivedSubLoading = false
            this.$message.error('Sorry! Error retrieving data. Please, try again later.')
          } else {
          // Get the data and display.
            if (Object.keys(results).length === 0) {
              this.jDashboardTaskBtnLoadState = false
              this.receivedSubLoading = false
              this.defaultPageItem = true
            } else {
              // Results is not empty hence get and display.
              // console.log('Received submissions: ', results)
              console.log('Total submissions: ', Object.keys(results).length)
              for (let i = 0; i < Object.keys(results).length; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].paperHash = results[i].returnValues.paperHash
                this.pageTableData[i].paperIPFShash = getIPFSstring(results[i].returnValues.paperIPFShash)
                this.pageTableData[i].paperTitle = web3.utils.hexToUtf8(results[i].returnValues.paperTitle)
                this.pageTableData[i].submittingAuthor = results[i].returnValues.submittingAuthor
                this.pageTableData[i].suppleFileIPFShash = getIPFSstring(results[i].returnValues.suppleFileIPFShash)
                this.pageTableData[i].userPubKey = results[i].returnValues.userPubKey
              }
              this.jDashboardTaskBtnLoadState = false
              this.receivedSubLoading = false
              // console.log('Objet to display as table: ', this.pageTableData)
              this.receivedSub = true
            }
          }
        })
    },
    getRevisedSub () {
      // console.log('Retrieving revised papers.')
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.revSubLoading = true
      this.defaultPageItem = false
      this.receivedSub = false
      this.reqPaper = false
      this.sendPaperToUser = false
      this.paidPapers = false
      // Perform required task and return true.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance for access type retrieval created.')
      jpBlockContract.getPastEvents('revisedAndReSubmittedManu', { filter: { jAddress: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
        (err, results) => {
          if (err) {
            this.receivedSubLoading = false
            this.$message.error('Sorry! Error retrieving data. Please, try again later.')
          } else {
          // Get the data and display.
            if (Object.keys(results).length === 0) {
              this.jDashboardTaskBtnLoadState = false
              this.receivedSubLoading = false
              this.defaultPageItem = true
            } else {
              // Results is not empty hence get and display.
              // console.log('Received submissions: ', results)
              console.log('Total revised papers: ', Object.keys(results).length)
              for (let i = 0; i < Object.keys(results).length; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].origPaperHash = results[i].returnValues.origPaperHash
                this.pageTableData[i].newPaperHash = results[i].returnValues.newPaperHash
              }
              this.jDashboardTaskBtnLoadState = false
              this.revSubLoading = false
              // console.log('Objet to display as table: ', this.pageTableData)
              this.revisedSub = true
            }
          }
        })
    },
    getPaidPapers () {
      this.pageTableData.splice(0, this.pageTableData.length) // Remove all previously stored values.
      this.jDashboardTaskBtnLoadState = true
      this.paidPapersbLoading = true
      this.defaultPageItem = false // 1
      this.receivedSub = false // 2
      this.reqPaper = false // 3
      this.sendPaperToUser = false // 4
      this.revisedSub = false // 5
      // Perform required task and return true.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance for access type retrieval created.')
      jpBlockContract.getPastEvents('paymentMade', { filter: { to: [web3.eth.defaultAccount] }, fromBlock: 0, toBlock: 'latest' },
        (err, results) => {
          if (err) {
            this.receivedSubLoading = false
            this.$message.error('Sorry! Error retrieving data. Please, try again later.')
          } else {
          // Get the data and display.
            if (Object.keys(results).length === 0) {
              this.jDashboardTaskBtnLoadState = false
              this.receivedSubLoading = false
              this.defaultPageItem = true
            } else {
              // Results is not empty hence get and display.
              // console.log('Received submissions: ', results)
              console.log('Total paid for papers: ', Object.keys(results).length)
              for (let i = 0; i < Object.keys(results).length; i++) {
                this.pageTableData[i] = []
                this.pageTableData[i].source = results[i].returnValues.source
                this.pageTableData[i].paperHash = results[i].returnValues.paperHash
              }
              this.jDashboardTaskBtnLoadState = false
              this.paidPapersbLoading = false
              // console.log('Objet to display as table: ', this.pageTableData)
              this.paidPapers = true
            }
          }
        })
    },
    getReqPaper () {
      // console.log('Retrieving requested papers.')
      this.jDashboardTaskBtnLoadState = true
      this.reqPapersLoading = true
      this.defaultPageItem = false // 1
      this.receivedSub = false // 2
      this.paidPapers = false // 3
      this.sendPaperToUser = false // 4
      this.revisedSub = false // 5
      this.receivedSubLoading = false
      // Set load button to false.
      this.jDashboardTaskBtnLoadState = false
      this.reqPapersLoading = false
      if (this.reqIPFShashes.length === 0) {
        this.defaultPageItem = true // 1
        this.$alert('There are no requested papers yet.', 'Status of requested papers.', {
          confirmButtonText: 'OK',
          callback: action => {
            this.$message({
              type: 'info',
              message: `action: ${action}`
            })
          }
        })
      } else {
        // Just display since it's table data was populated on page creation.
        this.reqPaper = true // 6
      }
    },
    getSendPaperToUser () {
      this.jDashboardTaskBtnLoadState = true
      this.sendPaperLoading = true
      this.defaultPageItem = false // 1
      this.receivedSub = false // 2
      this.reqPaper = false // 3
      this.paidPapers = false // 4
      this.revisedSub = false // 5
      // Perform required task and return true.
      this.sendPaperLoading = false
      this.sendPaperToUser = true // 6
    },
    sendReqPaperToUser (formName) {
      if (this.jAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          if (valid) {
            this.getRequestedLoadState = true
            // Get and decrypt the requested IPFS file.
            ipfs.cat(this.jSendPaperToUserForm.ipfsHashOfRequestedPaper).then(res => {
              console.log('IPFS cat success.')
              var ipfsEncryptedData = res.toString('utf8')
              // Perform decryption.
              this.$prompt('Please enter data decryption key.', 'Information required', {
                confirmButtonText: 'Continue',
                cancelButtonText: 'Cancel',
                inputPlaceholder: 'Decryption key.'
              }).then(({ value }) => {
                symDecrypt(ipfsEncryptedData, value).then(decryptedBytes => {
                  if (Object.keys(decryptedBytes).length !== 0) {
                    console.log('Decryption successful')
                    // Get user public key to encrypt the data.
                    this.$prompt('Please enter user public key to encrypt data.', 'Information required', {
                      confirmButtonText: 'Continue',
                      cancelButtonText: 'Cancel',
                      inputPlaceholder: 'Encryption key.',
                      inputPattern: /^0x[0-9A-F]{64}$/i
                    }).then(({ value }) => {
                      var userPubKey = this.convertHextoBytes(value.substring(2))
                      // Create key pair.
                      var journalKeyPair = generateKeyPair()
                      var jPrvKey = journalKeyPair.secretKey
                      // var jPubKey = journalKeyPair.publicKey
                      var encryptedUserData = asymmEncrypt(jPrvKey, decryptedBytes, userPubKey)
                      // Push to IPFS.
                      this.pushToIPFShub(encryptedUserData)
                    }).catch((err) => {
                      console.log('Error!', err)
                      this.getRequestedLoadState = false
                      this.$message.error('Sorry! Wrong or invalid public key.')
                    })
                  } else {
                    console.log('Error!')
                    this.getRequestedLoadState = false
                    this.$message.error('Sorry! No data found.')
                  }
                }).catch((err) => {
                  this.getRequestedLoadState = false
                  console.log('Error with', err)
                  this.$message.error('Error! Possible wrong decryption key.')
                })
              })
            }).catch((err) => {
              this.getRequestedLoadState = false
              console.log('Error pulling data from IPFS', err)
              this.$message.error('Error getting data from IPFS.')
            })
          } else {
            console.log('Submission error.')
            this.getRequestedLoadState = false
            return false
          }
        })
      }
    },
    convertHextoBytes (hexString) {
      var bytes = new Uint8Array(Math.ceil(hexString.length / 2))
      for (var i = 0; i < bytes.length; i++) bytes[i] = parseInt(hexString.substr(i * 2, 2), 16)
      return bytes
    },
    async pushToIPFShub (encryptedData) {
      var encryptedDataToSendToJviaIPFS = JSON.stringify({ encryptedData })
      // console.log('Connecting to IPFS.')
      const MyBuffer = window.Ipfs.Buffer
      var dataToBuffer = MyBuffer.from(encryptedDataToSendToJviaIPFS)
      // console.log('Buffer conversion done.')
      ipfs.add(dataToBuffer).then(res => {
        // console.log('Response object from IPFS: ', res)
        // console.log('Returned hash: ', res[0].hash)
        console.log('Data upload to IPFS sucessful')
        // Send to the user.
        this.sendToUserviaScontract(res[0].hash)
      }).catch((err) => {
        console.log('Error!', err)
        this.getRequestedLoadState = false
        this.$message.error('Sorry! Error adding to IPFS. Please, try again.')
      })
    },
    sendToUserviaScontract (ipfsHash) {
      console.log('IPFS hash is: ', ipfsHash)
      // Perform conversions.
      var convIPFShashOfUserReqMet = convertIPFSstringToBytes(ipfsHash)
      var convIPFShashUserRequsted = convertIPFSstringToBytes(this.jSendPaperToUserForm.ipfsHashOfRequestedPaper)
      // Send as transaction to the smart contract.
      var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
      console.log('Contract instance created.')
      try {
        jpBlockContract.methods.sendToPaidUser(convIPFShashUserRequsted, convIPFShashOfUserReqMet).send({
          from: web3.eth.defaultAccount,
          gas: 450000 // Check gas issues.
        }).on('transactionHash', (hash) => {
          console.log('Trans. hash is: ', hash)
        }).on('receipt', (receipt) => {
          console.log('Trans. Block Number is: ', receipt.blockNumber)
          // Set submit loading state to false.
          this.getRequestedLoadState = false
          this.captureSendPaperToUserDialog = false
          this.jDashboardTaskBtnLoadState = false
          this.$alert('Requested paper successfully sent to requestee.', 'Sent notification', {
            confirmButtonText: 'OK',
            callback: action => {
              this.$message({
                type: 'info',
                message: `action: ${action}`
              })
            }
          })
        }).on('error', (error) => {
          console.log('Error occured.', error)
          this.getRequestedLoadState = false
          this.$message.error('Sorry! Transaction error. Please, try again later.')
          // window.location.reload()
        })
      } catch {
        console.log('Sorry! Error occured.')
        this.getRequestedLoadState = false
        this.$message.error('Sorry! Non-transactional. Please try again later.')
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
