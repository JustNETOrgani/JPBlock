<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea" v-loading="loadingJcreationPage">
            <h2>Paper Tracking Service</h2>
            <el-row>
                <el-col :span="23" :offset="1">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="paperTrackingForm"
                            :rules="rules"
                            ref="paperTrackingForm"
                            label-width="180px"
                        >
                            <el-form-item label="Hash of Paper" prop="paperHash">
                                <el-input v-model="paperTrackingForm.paperHash" placeholder="Please enter hash of the paper."></el-input>
                            </el-form-item>
                            <el-form-item label="Name(s) of Author(s)" prop="namesOfAuthors">
                                <el-input v-model="paperTrackingForm.namesOfAuthors" placeholder="Please enter the name(s) of the author(s)."></el-input>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="paperTrackBtnLoadState" @click="submitForm('paperTrackingForm')">Track paper</el-button>
                                <el-button @click="resetForm('paperTrackingForm')">Reset</el-button>
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
import getHash from '@/assets/js/hashFunc'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
// import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      paperTrackingForm: {
        paperHash: '',
        namesOfAuthors: ''
      },
      userAccountNumForm: { accountNum: '' },
      userAccountIndexEntered: '',
      loadingJcreationPage: false,
      paperTrackBtnLoadState: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      rules: {
        paperHash: [
          { required: true, message: 'Please input hash of the paper', trigger: 'blur' },
          { min: 30, message: 'Length should be at least 30', trigger: 'blur' }
        ],
        namesOfAuthors: [
          { required: true, message: 'Please input name(s) of the author(s)', trigger: 'blur' },
          { min: 2, message: 'Length should be at least 2', trigger: 'blur' }
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
          this.paperTrackBtnLoadState = true
          if (valid) {
            var data = {
              paperHash: this.paperTrackingForm.paperHash,
              namesOfAuthors: this.paperTrackingForm.namesOfAuthors
            }
            console.log('Paper tracking data: ', data)
            getHash(data.namesOfAuthors).then(res => {
              var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
              console.log('Contract instance created.')
              // Smart contract and other logic continues.
              jpBlockContract.methods.checkPaperStatus(data.paperHash, res).call({ from: web3.eth.defaultAccount }).then(res => {
                this.paperTrackBtnLoadState = false
                this.$alert(res[0] + '' + web3.utils.hexToUtf8(res[1]), 'Result from Paper Tracking Service', {
                  confirmButtonText: 'OK',
                  callback: action => {
                    this.$message({
                      type: 'info',
                      message: `action: ${action}`
                    })
                  }
                })
              })
            })
          } else {
            console.log('Submission error.')
            this.paperTrackBtnLoadState = false
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
