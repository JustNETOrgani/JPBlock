<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea" v-loading="loadingJcreationPage">
            <h2>Payment center for restricted papers published on JPBlock</h2>
            <el-row>
                <el-col :span="23" :offset="1">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="payToGetPubPaperForm"
                            :rules="rules"
                            ref="payToGetPubPaperForm"
                            label-width="190px"
                        >
                            <el-form-item label="IPFS Hash of Paper" prop="ipfsHashOfPaperToGet">
                                <el-input v-model="payToGetPubPaperForm.ipfsHashOfPaperToGet" placeholder="Please enter hash of the paper."></el-input>
                            </el-form-item>
                            <el-form-item label="User's public key" prop="userPubKey">
                                <el-input v-model="payToGetPubPaperForm.userPubKey" placeholder="Please enter your public key."></el-input>
                            </el-form-item>
                            <el-form-item label="Subscription cost (Gwei)" prop="subFee">
                                <el-input-number v-model="payToGetPubPaperForm.subFee"  :min="1"></el-input-number>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="paymentBtnLoadState" @click="submitForm('payToGetPubPaperForm')">Pay</el-button>
                                <el-button @click="resetForm('payToGetPubPaperForm')">Reset</el-button>
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
import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'
// import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      payToGetPubPaperForm: {
        ipfsHashOfPaperToGet: '',
        userPubKey: '',
        subFee: ''
      },
      userAccountNumForm: { accountNum: '' },
      userAccountIndexEntered: '',
      loadingJcreationPage: false,
      paymentBtnLoadState: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      rules: {
        ipfsHashOfPaperToGet: [
          { required: true, message: 'Please input IPFS hash of the paper', trigger: 'blur' },
          { min: 46, message: 'Length should be at least 46', trigger: 'blur' }
        ],
        userPubKey: [
          { required: true, message: 'Please input your public key.', trigger: 'blur' },
          { min: 64, message: 'Length should be at least 64', trigger: 'blur' }
        ],
        subFee: [
          { required: true, message: 'Please input name required fee.', trigger: 'blur' }
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
          this.paymentBtnLoadState = true
          if (valid) {
            var data = {
              paperIPFShash: this.payToGetPubPaperForm.ipfsHashOfPaperToGet,
              userPubKey: this.payToGetPubPaperForm.userPubKey,
              subFee: (this.payToGetPubPaperForm.subFee) * 1000000000 // Gwei
            }
            if (this.ipfsInputValidation(data.paperIPFShash) === 1) {
              data.paperIPFShash = convertIPFSstringToBytes(data.paperIPFShash)
              if (this.pubKeyInputValidation(data.userPubKey) === 1) {
                console.log('Payment data: ', data)
                var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
                console.log('Contract instance created.')
                // Smart contract and other logic continues.
                try {
                  jpBlockContract.methods.payToGetRestrictedPaper(data.paperIPFShash, data.userPubKey, data.subFee).send({
                    from: web3.eth.defaultAccount,
                    gas: 265000,
                    value: data.subFee
                  }).on('transactionHash', (hash) => {
                    console.log('Trans. hash is: ', hash)
                  }).on('receipt', (receipt) => {
                    console.log('Trans. Block Number is: ', receipt.blockNumber)
                    // Display success note.
                    this.paymentBtnLoadState = false
                    this.$message({
                      message: 'Payment for requested paper successful. Journal has been notified.',
                      type: 'success'
                    })
                    this.$router.push('/')
                  }).on('error', (error) => {
                    console.log('Error occured', error)
                    this.paymentBtnLoadState = false
                    this.$message.error('Oops. Eror occured during transaction processing.')
                  })
                } catch {
                  console.log('Sorry! Error occured.')
                  this.paymentBtnLoadState = false
                  this.$message.error('Non-transactional error. Please try again later.')
                }
              } else {
                this.paymentBtnLoadState = false
                this.$message('Invalid public key entered. Please, reenter.')
              }
            } else {
              this.paymentBtnLoadState = false
              this.$message('Invalid IPFS hash entered. Please, reenter.')
            }
          } else {
            console.log('Submission error.')
            this.paymentBtnLoadState = false
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
    pubKeyInputValidation (input) {
      const count = input.toString().length
      if (input === '' || isNaN(input) === true || input < 0 || count <= 63) {
        return 0
      } else {
        return 1
      }
    },
    ipfsInputValidation (input) {
      const count = input.toString().length
      if (input === '' || count < 46 || input.startsWith('Qm') === false) {
        return 0
      } else {
        return 1
      }
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
