<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea" v-loading="loadingJcreationPage">
            <h2>Proof of paper authorship</h2>
            <p>Prove if you are an author or part of authors of a paper on JPBlock.</p>
            <el-row>
                <el-col :span="23" :offset="1">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="proveOfAuthForm"
                            :rules="rules"
                            ref="proveOfAuthForm"
                            label-width="180px"
                        >
                            <el-form-item label="Hash of Paper" prop="paperHash">
                                <el-input v-model="proveOfAuthForm.paperHash" placeholder="Please enter hash of the paper."></el-input>
                            </el-form-item>
                            <el-form-item label="Title of paper" prop="paperTitle">
                                <el-input v-model="proveOfAuthForm.paperTitle" placeholder="Please enter paper's title."></el-input>
                            </el-form-item>
                            <el-form-item label="Name(s) of Author(s)" prop="namesOfAuthors">
                                <el-input v-model="proveOfAuthForm.namesOfAuthors" placeholder="Please enter the name(s) of the author(s)."></el-input>
                            </el-form-item>
                            <el-form-item label="ID(s) of Author(s)" prop="idsOfAuthors">
                                <el-input v-model="proveOfAuthForm.idsOfAuthors" placeholder="Please enter the name(s) of the author(s)."></el-input>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="proveAuthBtnLoadState" @click="submitForm('proveOfAuthForm')">Get proof</el-button>
                                <el-button @click="resetForm('proveOfAuthForm')">Reset</el-button>
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
import getHash from '@/assets/js/hashFunc'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
// import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      proveOfAuthForm: {
        paperHash: '',
        paperTitle: '',
        namesOfAuthors: '',
        idsOfAuthors: ''
      },
      userAccountNumForm: { accountNum: '' },
      userAccountIndexEntered: '',
      loadingJcreationPage: false,
      proveAuthBtnLoadState: false,
      userAccountDialog: false,
      getUserAccountLoadState: false,
      rules: {
        paperHash: [
          { required: true, message: 'Please input hash of the paper', trigger: 'blur' },
          { min: 30, message: 'Length should be at least 30', trigger: 'blur' }
        ],
        paperTitle: [
          { required: true, message: 'Please input title of the paper', trigger: 'blur' },
          { min: 2, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        namesOfAuthors: [
          { required: true, message: 'Please input name(s) of the author(s)', trigger: 'blur' },
          { min: 2, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        idsOfAuthors: [
          { required: true, message: 'Please input ID(s) of the author(s)', trigger: 'blur' },
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
          this.proveAuthBtnLoadState = true
          if (valid) {
            var data = {
              paperHash: this.proveOfAuthForm.paperHash,
              paperTitle: web3.utils.utf8ToHex(this.proveOfAuthForm.paperTitle),
              namesOfAuthors: this.proveOfAuthForm.namesOfAuthors,
              idsOfAuthors: this.proveOfAuthForm.idsOfAuthors
            }
            console.log('Paper tracking data: ', data)
            getHash(data.namesOfAuthors).then(hashedNames => {
              getHash(data.idsOfAuthors).then(hashedIDs => {
                var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
                console.log('Contract instance created.')
                // Smart contract and other logic continues.
                jpBlockContract.methods.proveAuthorship(data.paperHash, data.paperTitle, hashedNames, hashedIDs).call({ from: web3.eth.defaultAccount }).then(res => {
                  if (res === 1) {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Congratulations. Proof Successful. This is a published paper.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  }
                  if (res === 2) {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Congratulations. Proof Successful.Paper has been accepted for publication.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  }
                  if (res === 3) {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Congratulations. Proof Successful.Paper is under review.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  }
                  if (res === 4) {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Congratulations. Proof Successful.Paper has been submitted to a Journal.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  }
                  if (res === 5) {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Congratulations. Proof Successful.This is a rejected paper.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  }
                  if (res === 6) {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Congratulations. Proof Successful.Paper to be revised and resubmitted.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  }
                  if (res === 7) {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Congratulations. Proof Successful.This is a revised and resubmitted paper.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  } else {
                    this.proveAuthBtnLoadState = false
                    this.$alert('Sorry! You Failed Proof Checks.', 'Result of prove of authorship', {
                      confirmButtonText: 'OK',
                      callback: action => {
                        this.$message({
                          type: 'info',
                          message: `action: ${action}`
                        })
                      }
                    })
                  }
                })
              })
            })
          } else {
            console.log('Submission error.')
            this.proveAuthBtnLoadState = false
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

</style>
