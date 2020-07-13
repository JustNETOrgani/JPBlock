<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea" v-loading="loadingJcreationPage">
          <el-row>
            <el-col>
              <img id="jCreatImg" src="../../assets/imgs/jCreation.png" />
            </el-col>
          </el-row>
          <el-row>
            <el-col :span="14" :offset="3">
              <h2>Journal creation center</h2>
            </el-col>
            <el-col :span="4" :offset="1">
              <img id="jCreatImgTwo" src="../../assets/imgs/createAccount.png" />
            </el-col>
          </el-row>
            <el-row>
                <el-col :span="20" :offset="1">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="jCreateForm"
                            :rules="rules"
                            ref="jCreateForm"
                            label-width="240px"
                        >
                            <el-form-item label="Name of the Journal" prop="jName">
                                <el-input v-model="jCreateForm.jName" placeholder="Please enter name of the Journal."></el-input>
                            </el-form-item>
                            <el-form-item label="URL of the Journal" prop="jURL">
                                <el-input v-model="jCreateForm.jURL" placeholder="Please enter URL of the Journal."></el-input>
                            </el-form-item>
                            <el-form-item label="Current Impact Factor" prop="jIF">
                                <el-input v-model="jCreateForm.jIF" placeholder="Example: 39 for Impact Factor of 3.9"></el-input>
                            </el-form-item>
                            <el-form-item label="Price for Open Access Publication in Eth" prop="jOAPrice">
                                <el-input-number v-model="jCreateForm.jOAPrice"  :min="1"></el-input-number>
                            </el-form-item>
                            <el-form-item label="Price for Non Open Access Publication in Eth" prop="jnOAPrice">
                                <el-input-number v-model="jCreateForm.jnOAPrice"  :min="1"></el-input-number>
                            </el-form-item>
                            <el-form-item label="Price for restricted paper in Eth" prop="jRestrictedPrice">
                                <el-input-number v-model="jCreateForm.jRestrictedPrice" :min="1"></el-input-number>
                            </el-form-item>
                            <el-form-item label="Public Key of Journal" prop="jPubKey">
                                <el-input v-model="jCreateForm.jPubKey" placeholder="Please enter Public Key of the Journal."></el-input>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="jCreateBtnLoadState" @click="submitForm('jCreateForm')">Create</el-button>
                                <el-button @click="resetForm('jCreateForm')">Reset</el-button>
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
      jCreateForm: {
        jName: '',
        jURL: '',
        jIF: '',
        jOAPrice: null,
        jnOAPrice: null,
        jRestrictedPrice: null,
        jPubKey: ''
      },
      jAccountNumForm: { accountNum: '' },
      jAccountIndexEntered: '',
      loadingJcreationPage: false,
      jCreateBtnLoadState: false,
      journalAccountDialog: false,
      getJAccountLoadState: false,
      rules: {
        jName: [
          { required: true, message: 'Please input Journal name', trigger: 'blur' },
          { min: 2, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        jURL: [
          { required: true, message: 'Please input Journal URL', trigger: 'blur' },
          { min: 2, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        jIF: [
          { required: true, message: 'Please input Journal Impact Factor', trigger: 'blur' },
          { min: 0, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        jOAPrice: [
          { required: true, message: 'Please input OA amount required in Eth', trigger: 'blur' }
        ],
        jnOAPrice: [
          { required: true, message: 'Please input Non-OA amount in Eth', trigger: 'blur' }
        ],
        jRestrictedPrice: [
          { required: true, message: 'Please input amount required in Eth', trigger: 'blur' }
        ],
        jPubKey: [
          { required: true, message: 'Please input Journal Public key', trigger: 'blur' },
          { min: 63, message: 'Length should be at least 63', trigger: 'blur' }
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

#jCreatImg{
    margin-top: 0.1rem;
    width: 5rem;
    height: 4rem;
}

#jCreatImgTwo{
    margin-top: 1.2rem;
    width: 3rem;
    height: 2rem;
}
</style>
