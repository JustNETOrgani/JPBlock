<template>
    <div class="body">
      <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea">
            <h2>Journal activation and deactivation page</h2>
            <el-row>
                <el-col :span="19">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="jActOrDeActForm"
                            :rules="rules"
                            ref="jActOrDeActForm"
                            label-width="180px"
                        >
                            <el-form-item label="Journal's name" prop="jTask">
                                <el-select
                                    v-model="jActOrDeActForm.jTask"
                                    style="width:100%"
                                    placeholder="Please select the desired task.">
                                    <el-option label="Activate Journal" value="jActivate"></el-option>
                                    <el-option label="Deactivate Journal" value="jDeactivate"></el-option>
                                </el-select>
                            </el-form-item>
                            <el-form-item label="**Journal's consent**" prop="authCheckBox">
                                <el-checkbox v-model="jActOrDeActForm.authCheckBox">I fully understand the implication of this action.</el-checkbox>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="jActOrDeActSubLoadBtn" @click="submitForm('jActOrDeActForm')">Submit</el-button>
                                <el-button @click="resetForm('jActOrDeActForm')">Reset</el-button>
                            </el-form-item>
                        </el-form>
                    </div>
                </el-col>
            </el-row>
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
                <el-button @click="pgReload()">Cancel</el-button>
                <el-button :loading="getJAccountLoadState" type="primary" @click="getJaccountOnPageLoad('jAccountNumForm')">Confirm</el-button>
            </span>
        </el-dialog>
    <!--<Footer></Footer>-->
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
      jActOrDeActForm: {
        jTask: '',
        authCheckBox: ''
      },
      jAccountNumForm: { accountNum: '' },
      jAccountIndexEntered: '',
      jActOrDeActSubLoadBtn: false,
      journalAccountDialog: false,
      getJAccountLoadState: false,
      rules: {
        jTask: [
          { required: true, message: 'Please select the required task from the list.', trigger: 'blur' }
        ],
        authCheckBox: [
          { required: true, message: 'Please check the checkbox.', trigger: 'blur' }
        ]
      }
    }
  },
  components: {
    // Head,
    // Footer
  },
  created () {
    this.journalAccountDialog = true
  },
  methods: {
    submitForm (formName) {
      if (this.jAccountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          this.jActOrDeActSubLoadBtn = true
          if (valid) {
            var data = {
              jSelectedTask: this.jActOrDeActForm.jTask,
              chkBox: this.jActOrDeActForm.authCheckBox
            }
            console.log('J activation/deactivation data: ', data)
            if (data.chkBox === true) {
              var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
              console.log('Contract instance created.')
              // Smart contract and other logic continues.
              if (data.jSelectedTask === 'jActivate') {
                try {
                  jpBlockContract.methods.activateJournal().send({
                    from: web3.eth.defaultAccount,
                    gas: 265000
                  }).on('transactionHash', (hash) => {
                    console.log('Trans. hash is: ', hash)
                  }).on('receipt', (receipt) => {
                    console.log('Trans. Block Number is: ', receipt.blockNumber)
                    // Display success note.
                    this.jActOrDeActSubLoadBtn = false
                    this.$message({
                      message: 'Congratulations. Journal activated successfully.',
                      type: 'success'
                    })
                    this.$router.push('/')
                  }).on('error', (error) => {
                    console.log('Error occured', error)
                    this.jActOrDeActSubLoadBtn = false
                    this.$message.error('Oops. Eror occured during transaction processing.')
                  })
                } catch {
                  console.log('Sorry! Error occured.')
                  this.jActOrDeActSubLoadBtn = false
                  this.$message.error('Non-transactional error. Please try again later.')
                }
              } else {
                try {
                  jpBlockContract.methods.makeJournalInactive().send({
                    from: web3.eth.defaultAccount,
                    gas: 265000
                  }).on('transactionHash', (hash) => {
                    console.log('Trans. hash is: ', hash)
                  }).on('receipt', (receipt) => {
                    console.log('Trans. Block Number is: ', receipt.blockNumber)
                    // Display success note.
                    this.jActOrDeActSubLoadBtn = false
                    this.$message({
                      message: 'Congratulations. Journal deactivated successfully.',
                      type: 'success'
                    })
                    this.$router.push('/')
                  }).on('error', (error) => {
                    console.log('Error occured', error)
                    this.jActOrDeActSubLoadBtn = false
                    this.$message.error('Oops. Eror occured during transaction processing.')
                  })
                } catch {
                  console.log('Sorry! Error occured.')
                  this.jActOrDeActSubLoadBtn = false
                  this.$message.error('Non-transactional error. Please try again later.')
                }
              }
            } else {
              this.jActOrDeActSubLoadBtn = false
              this.$message('Please check the checkbox.')
            }
          } else {
            console.log('Submission error.')
            this.jActOrDeActSubLoadBtn = false
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
    },
    pgReload () {
      window.location.reload()
    }
  }
}
</script>

<style scoped>
.body {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
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
