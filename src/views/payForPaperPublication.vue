<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea" v-loading="loadingJcreationPage">
          <el-col :span="4">
                    <img id="ethImg" src="../assets/imgs/ethWallet.png" />
            </el-col>
            <h2>Payment center for accepted papers of authors by journals on JPBlock</h2>
            <el-row>
                <el-col :span="23" :offset="1">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="payAcceptedpaperForm"
                            :rules="rules"
                            ref="payAcceptedpaperForm"
                            label-width="180px"
                        >
                            <el-form-item label="Hash of Paper" prop="paperHash">
                                <el-input v-model="payAcceptedpaperForm.paperHash" placeholder="Please enter hash of the paper."></el-input>
                            </el-form-item>
                            <el-form-item label="Journal's Eth address" prop="jEthAddress">
                                <el-input v-model="payAcceptedpaperForm.jEthAddress" placeholder="Please enter the Eth address of the journal."></el-input>
                            </el-form-item>
                            <el-form-item label="Publication cost (Eth)" prop="pubFee">
                                <el-input-number v-model="payAcceptedpaperForm.pubFee"  :min="1"></el-input-number>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="paymentBtnLoadState" @click="submitForm('payAcceptedpaperForm')">Pay</el-button>
                                <el-button @click="resetForm('payAcceptedpaperForm')">Reset</el-button>
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
                <el-button @click="pgReload()">Cancel</el-button>
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
      payAcceptedpaperForm: {
        paperHash: '',
        jEthAddress: '',
        pubFee: ''
      },
      userAccountNumForm: { accountNum: '' },
      userAccountIndexEntered: '',
      loadingJcreationPage: false,
      paymentBtnLoadState: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      rules: {
        paperHash: [
          { required: true, message: 'Please input hash of the paper', trigger: 'blur' },
          { min: 30, message: 'Length should be at least 30', trigger: 'blur' }
        ],
        jEthAddress: [
          { required: true, message: 'Please input Eth address of the Journal.', trigger: 'blur' },
          { min: 20, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        pubFee: [
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
              paperHash: this.payAcceptedpaperForm.paperHash,
              jEthAddress: this.payAcceptedpaperForm.jEthAddress,
              pubCost: ((this.payAcceptedpaperForm.pubFee) * 1000000000000000000).toString() // Ether
            }
            if (web3.utils.isAddress(data.jEthAddress) === true) {
              if (this.hashInputValidation(data.paperHash) === 1) {
                console.log('Payment data: ', data)
                var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
                console.log('Contract instance created.')
                // Smart contract and other logic continues.
                try {
                  jpBlockContract.methods.payForPaperPublication(data.paperHash, data.jEthAddress, data.pubCost).send({
                    from: web3.eth.defaultAccount,
                    gas: 265000,
                    value: data.pubCost
                  }).on('transactionHash', (hash) => {
                    console.log('Trans. hash is: ', hash)
                  }).on('receipt', (receipt) => {
                    console.log('Trans. Block Number is: ', receipt.blockNumber)
                    // Display success note.
                    this.paymentBtnLoadState = false
                    this.$message({
                      message: 'Payment successful. Journal has been notified.',
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
                this.$message('Invalid paper hash entered. Please, reenter.')
              }
            } else {
              this.paymentBtnLoadState = false
              this.$message('Invalid Ethereum address entered. Please, reenter.')
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
    hashInputValidation (input) {
      const count = input.length
      if (input === '' || isNaN(input) === true || count <= 63) {
        return 0
      } else {
        return 1
      }
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

#ethImg{
    margin-top: 1.2rem;
    width: 5rem;
    height: 4rem;
}

</style>
