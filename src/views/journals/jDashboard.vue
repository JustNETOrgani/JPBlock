<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div id="heading">
            <h2>Journal dashboard - Activity hub</h2>
        </div>
        <div id="midLeft">
            <h3 class="textPlacements">Task selection area</h3>
            <el-form
                :model="jBoardTasks"
                :rules="rules"
                ref="jBoardTasks"
                label-width="180px"
            >
            <div id="taskSelectArea">
                <el-form-item class="textPlacements" label="Required task" prop="jTask">
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
            </div>
                <div id="btnSection">
                <el-form-item>
                    <el-button type="primary" :loading="jDashboardTaskBtnLoadState" @click="submitForm('jBoardTasks')">Retrieve information</el-button>
                </el-form-item>
                </div>
            </el-form>
        </div>
        <div id="midCenter">
            <h4>Retrieved data appears below</h4>
            <div v-if="receivedSub">

            </div>
            <div v-else-if="revisedSub">

            </div>
            <div v-else-if="paidPapers">

            </div>
            <div v-else-if="reqPaper">

            </div>
            <div v-else-if="sendPaperToUser">

            </div>
            <div v-else>
                <p>No records retrieved</p>
            </div>
        </div>
        <el-dialog title="Journal's Ethereum Account" width="30%" :visible.sync="journalAccountDialog">
            <el-form :model="jAccountNumForm"
            :rules="rules"
            ref="jAccountNumForm">
                <el-form-item label="Account Number" prop="accountNum">
                <el-input v-model="jAccountNumForm.accountNum" autocomplete="off"></el-input>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="journalAccountDialog = false">Cancel</el-button>
                <el-button :loading="getJAccountLoadState" type="primary" @click="getJaccountOnPageLoad('jAccountNumForm')">Confirm</el-button>
            </span>
        </el-dialog>
    </div>
</template>

<script>
// @ is an alias to /src
// import Head from '@/components/header'
import web3 from '@/assets/js/web3'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
// import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      jBoardTasks: {
        jTask: ''
      },
      jAccountNumForm: { accountNum: '' },
      jAccountIndexEntered: '',
      jDashboardTaskBtnLoadState: false,
      journalAccountDialog: false,
      getJAccountLoadState: false,
      rules: {
        jTask: [
          { required: true, message: 'Please input Journal name', trigger: 'blur' }
        ],
        accountNum: [
          { required: true, message: 'Please input account number', trigger: 'blur' },
          { min: 1, max: 1, message: 'Number can only be from 0 to 9', trigger: 'blur' }
        ]
      }
    }
  },
  components: {
    // Head
    // Footer
  },
  created () {
    this.journalAccountDialog = true
  },
  methods: {
    submitForm (formName) {
      if (this.jAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          this.jCreateBtnLoadState = true
          if (valid) {
            if (this.jNameValidation(this.jCreateForm.jName) === 1) {
              if (this.validateURLentry(this.jCreateForm.jURL) === 1) {
                if (this.jPubKeyInputValidation(this.jCreateForm.jPubKey) === 1) {
                  var data = {
                    jName: web3.utils.asciiToHex(this.jCreateForm.jName),
                    jURL: this.jCreateForm.jURL,
                    jIF: this.jCreateForm.jIF,
                    jOAPrice: (this.jCreateForm.jOAPrice) * 1000000000, // 1000000000 Gwei
                    jnOAPrice: (this.jCreateForm.jnOAPrice) * 1000000000,
                    jRestrictedPrice: (this.jCreateForm.jRestrictedPrice) * 1000000000,
                    jPubKey: this.jCreateForm.jPubKey
                  }
                  console.log('J creation data: ', data)
                  var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
                  console.log('Contract instance created.')
                  // Smart contract and other logic continues.
                  try {
                    jpBlockContract.methods.createJournal(data.jName, data.jURL, data.jIF, data.jOAPrice, data.jnOAPrice, data.jRestrictedPrice, data.jPubKey).send({
                      from: web3.eth.defaultAccount,
                      gas: 310000
                    }).on('transactionHash', (hash) => {
                      console.log('Trans. hash is: ', hash)
                    }).on('receipt', (receipt) => {
                      console.log('Trans. Block Number is: ', receipt.blockNumber)
                      // Display success note.
                      this.jCreateBtnLoadState = false
                      this.$message({
                        message: 'Congratulations. Journal created successfully.',
                        type: 'success'
                      })
                      this.$router.push('/')
                    }).on('error', (error) => {
                      console.log('Error occured', error)
                      this.jCreateBtnLoadState = false
                      this.$message.error('Oops. Eror occured during transaction processing.')
                    })
                  } catch {
                    console.log('Sorry! Error occured.')
                    this.jCreateBtnLoadState = false
                    this.$message.error('Non-transactional error. Please try again later.')
                  }
                } else {
                  this.jCreateBtnLoadState = false
                  this.$message('Invalid Public Key.')
                }
              } else {
                this.jCreateBtnLoadState = false
                this.$message('Invalid URL.')
              }
            } else {
              this.jCreateBtnLoadState = false
              this.$message('Invalid Journal name.')
            }
          } else {
            console.log('Submission error.')
            this.jCreateBtnLoadState = false
            return false
          }
        })
      } else {
        this.$message('Enter required journal account. Reloading page...')
        window.location.reload()
      }
    },
    resetForm (formName) {
      this.$refs[formName].resetFields()
    },
    jNameValidation (input) {
      if (input === '' || /[^a-zA-Z]/.test(input) === true || input == null) {
        return 0
      } else {
        return 1
      }
    },
    validateURLentry (input) {
      try {
        var url = new URL(input)
      } catch (_) {
        return 0
      }
      console.log('Correct url detected: ', url)
      return 1
    },
    jPubKeyInputValidation (input) {
      const count = input.toString().length
      if (input === '' || isNaN(input) === true || input < 0 || count <= 63) {
        return 0
      } else {
        return 1
      }
    },
    getJaccountOnPageLoad (formName) {
      this.$refs[formName].validate(valid => {
        if (valid) {
          this.getJAccountLoadState = true
          this.jAccountIndexEntered = this.jAccountNumForm.accountNum
          // Get and use web3 object.
          try {
            web3.eth.getAccounts().then(accounts => {
              console.log('Ethereum address of this Journal is: ', accounts[this.jAccountIndexEntered])
              web3.eth.defaultAccount = accounts[this.jAccountIndexEntered]
            })
          } catch { console.log('Error occured with web3') }
          this.getJAccountLoadState = false
          this.journalAccountDialog = false
        }
      })
    },
    backToPrvPack () {
      this.$router.push('/')
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

#heading {
  background-color: #ffffff;
  border-radius: 4px;
  margin: 0.6% auto;
  width: 100%;
  padding: 0.2rem 1.5rem;
}

#midLeft {
  background-color: #ffffff;
  margin: 0.1% auto;
  width: 25%;
  padding: 0.2rem 2.5rem;
  float: left;
}

.textPlacements{
    margin-left: -4rem;
}

#taskSelectArea{
    margin-top: 2rem;
}

#btnSection{
    margin-top: 13rem;
}

#midCenter{
  background-color: #ffffff;
  margin: 0.1% 0.4rem;
  width: 63%;
  padding: 0.2rem 2.5rem;
  float: right;
}

</style>
