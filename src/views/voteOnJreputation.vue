<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea" v-loading="loadingJcreationPage">
            <h2>Voting on Journal's reputation</h2>
            <p>This pushes upwards the reputation of a Journal.</p>
            <el-row>
                <el-col :span="23" :offset="1">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="voteOnJForm"
                            :rules="rules"
                            ref="voteOnJForm"
                            label-width="180px">
                           <el-form-item label="**User's consent**" prop="authCheckBox">
                                <el-checkbox v-model="voteOnJForm.authCheckBox">I fully understand the implication of this action.</el-checkbox>
                            </el-form-item>
                            <el-form-item label="Journal's ethereum" prop="jAddress">
                                <el-input v-model="voteOnJForm.jAddress" placeholder="Please enter paper's title."></el-input>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="voteOnJBtnLoadState" @click="submitForm('voteOnJForm')">Vote now</el-button>
                                <el-button @click="resetForm('voteOnJForm')">Reset</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-col>
            </el-row>
        </div>
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
// import Head from '@/components/header'
import web3 from '@/assets/js/web3'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
// import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      voteOnJForm: {
        authCheckBox: '',
        jAddress: ''
      },
      userAccountNumForm: { accountNum: '' },
      userAccountIndexEntered: '',
      loadingJcreationPage: false,
      voteOnJBtnLoadState: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      rules: {
        authCheckBox: [
          { required: true, message: 'Please input hash of the paper', trigger: 'blur' }
        ],
        jAddress: [
          { required: true, message: 'Please input ethereum address of the journal.', trigger: 'blur' },
          { min: 20, message: 'Length should be at least 20', trigger: 'blur' }
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
    this.userAccountDialog = true
  },
  methods: {
    submitForm (formName) {
      if (this.userAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          this.voteOnJBtnLoadState = true
          if (valid) {
            var data = {
              jAddress: this.voteOnJForm.jAddress,
              authCheckBox: this.voteOnJForm.authCheckBox
            }
            console.log('Paper tracking data: ', data)
            if (data.authCheckBox === true) {
              if (web3.utils.isAddress(data.jAddress) === true) {
                var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
                console.log('Contract instance created.')
                // Smart contract and other logic continues.
                try {
                  jpBlockContract.methods.voteUpJreputation(data.jAddress).send({
                    from: web3.eth.defaultAccount,
                    gas: 265000
                  }).on('transactionHash', (hash) => {
                    console.log('Trans. hash is: ', hash)
                  }).on('receipt', (receipt) => {
                    console.log('Trans. Block Number is: ', receipt.blockNumber)
                    // Display success note.
                    this.voteOnJBtnLoadState = false
                    this.$message({
                      message: 'You have successfully voted on JPBlock.',
                      type: 'success'
                    })
                    this.$router.push('/')
                  }).on('error', (error) => {
                    console.log('Error occured', error)
                    this.voteOnJBtnLoadState = false
                    this.$message.error('Oops. Eror occured during transaction processing.')
                  })
                } catch {
                  console.log('Sorry! Error occured.')
                  this.voteOnJBtnLoadState = false
                  this.$message.error('Non-transactional error. Please try again later.')
                }
              } else {
                this.voteOnJBtnLoadState = false
                this.$message('Invalid Ethereum address.')
              }
            } else {
              this.voteOnJBtnLoadState = false
              this.$message('Please check the checkbox.')
            }
          } else {
            console.log('Submission error.')
            this.voteOnJBtnLoadState = false
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

.formArea {
  background-color: #ffffff;
  border-radius: 4px;
  margin: 2.5% auto;
  width: 48%;
  padding: 1rem 1.5rem;
}

</style>
