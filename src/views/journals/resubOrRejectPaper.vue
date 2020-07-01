<template>
    <div class="body">
      <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="formArea">
            <h2>Journal paper review and acceptance</h2>
            <el-row>
                <el-col :span="22">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="revOrAcceptForm"
                            :rules="rules"
                            ref="revOrAcceptForm"
                            label-width="200px"
                        >
                            <el-form-item label="Required task" prop="jTask">
                                <el-select
                                    v-model="revOrAcceptForm.jTask"
                                    style="width:100%"
                                    placeholder="Please select the desired task.">
                                    <el-option label="Push paper for resubmission" value="paperResubmit"></el-option>
                                    <el-option label="Push paper for rejection" value="paperReject"></el-option>
                                </el-select>
                            </el-form-item>
                            <el-form-item label="Hash of Paper" prop="paperHash">
                                <el-input v-model="revOrAcceptForm.paperHash" placeholder="Please enter hash of the paper."></el-input>
                            </el-form-item>
                            <fieldset>
                                    <legend>File upload</legend>
                                        <el-form-item label="Supporting file" prop="taskReason">
                                            <el-upload
                                                class="upload-demo"
                                                action="taskReasonUpload"
                                                :http-request="beforeUpload"
                                                :on-remove="handleRemove"
                                                :before-remove="beforeRemove">
                                                <el-button slot="trigger" size="small" type="primary">Select file</el-button>
                                                <div class="el-upload__tip" slot="tip">.pdf,.doc,.docx files only with a size less than 10MB</div>
                                            </el-upload>
                                        </el-form-item>
                                        <p class="hashValues"><i>{{ipfsHashOfUploadedReasonFIle}}</i></p>
                                </fieldset>
                            <el-form-item label="**Journal's consent**" prop="authCheckBox">
                                <el-checkbox v-model="revOrAcceptForm.authCheckBox">I fully understand the implication of this action.</el-checkbox>
                            </el-form-item>
                            <el-form-item>
                                <el-button type="primary" :loading="revOrAcceptLoadBtn" @click="submitForm('revOrAcceptForm')">Submit</el-button>
                                <el-button @click="resetForm('revOrAcceptForm')">Reset</el-button>
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
                <el-button @click="journalAccountDialog = false">Cancel</el-button>
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
import { generateKeyPair, asymmEncrypt } from '@/assets/js/asyncAsym'
import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'
const ipfs = new window.Ipfs()
// import Footer from '@/components/Footer'

export default {
  // name: 'Home',
  data () {
    return {
      revOrAcceptForm: {
        jTask: '',
        paperHash: '',
        taskReason: '',
        authCheckBox: ''
      },
      jAccountNumForm: { accountNum: '' },
      jAccountIndexEntered: '',
      revOrAcceptLoadBtn: false,
      journalAccountDialog: false,
      getJAccountLoadState: false,
      pubKeyOfSubAuthor: '',
      ipfsHashOfUploadedReasonFIle: '',
      rules: {
        jTask: [
          { required: true, message: 'Please select the required task from the list.', trigger: 'blur' }
        ],
        paperHash: [
          { required: true, message: 'Please input hash of the paper', trigger: 'blur' },
          { min: 30, message: 'Length should be at least 30', trigger: 'blur' }
        ],
        authCheckBox: [
          { required: true, message: 'Please check the checkbox.', trigger: 'blur' }
        ],
        taskReason: [
          { required: true, message: 'Please select the required task from the list.', trigger: 'blur' }
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
          this.revOrAcceptLoadBtn = true
          if (valid) {
            var data = {
              jSelectedTask: this.revOrAcceptForm.jTask,
              paperHash: this.revOrAcceptForm.paperHash,
              chkBox: this.revOrAcceptForm.authCheckBox,
              convIPFShashlink: convertIPFSstringToBytes(this.ipfsHashOfUploadedReasonFIle)
            }
            console.log('J activation/deactivation data: ', data)
            if (data.chkBox === true) {
              var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
              console.log('Contract instance created.')
              // Smart contract and other logic continues.
              if (data.jSelectedTask === 'paperResubmit') {
                jpBlockContract.methods.pushPaperForRevisionAndReSub(data.paperHash, data.convIPFShashlink).send({
                  from: web3.eth.defaultAccount,
                  gas: 265000
                }).on('transactionHash', (hash) => {
                  console.log('Trans. hash is: ', hash)
                }).on('receipt', (receipt) => {
                  console.log('Trans. Block Number is: ', receipt.blockNumber)
                  // Display success note.
                  this.revOrAcceptLoadBtn = false
                  this.$message({
                    message: 'Paper successfully pushed for resubmission.',
                    type: 'success'
                  })
                  this.$router.push('/')
                }).on('error', (error) => {
                  console.log('Error occured', error)
                  this.revOrAcceptLoadBtn = false
                  this.$message.error('Oops. Eror occured during transaction processing.')
                })
              } else {
                jpBlockContract.methods.pushPaperForRejection(data.paperHash, data.convIPFShashlink).send({
                  from: web3.eth.defaultAccount,
                  gas: 265000
                }).on('transactionHash', (hash) => {
                  console.log('Trans. hash is: ', hash)
                }).on('receipt', (receipt) => {
                  console.log('Trans. Block Number is: ', receipt.blockNumber)
                  // Display success note.
                  this.revOrAcceptLoadBtn = false
                  this.$message({
                    message: 'Paper rejected successfully.',
                    type: 'success'
                  })
                  this.$router.push('/')
                }).on('error', (error) => {
                  console.log('Error occured', error)
                  this.revOrAcceptLoadBtn = false
                  this.$message.error('Oops. Eror occured during transaction processing.')
                })
              }
            } else {
              this.revOrAcceptLoadBtn = false
              this.$message('Please check the checkbox.')
            }
          } else {
            console.log('Submission error.')
            this.revOrAcceptLoadBtn = false
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
    beforeUpload (item) {
      const file = item.file
      console.log('File action:', item.action)
      const extensionDoc = file.name.split('.').pop() === 'doc'
      const extensionDocx = file.name.split('.').pop() === 'docx'
      const extensionPdf = file.name.split('.').pop() === 'pdf'
      const sizeLimit = file.size / 1024 / 1024 < 10
      if (!extensionDoc && !extensionDocx && !extensionPdf) {
        this.$message.warning('Sorry! The uploaded file can only be in pdf, doc, and docx format!')
        return
      }
      if (!sizeLimit) {
        this.$message.warning('Sorry! The upload file size cannot exceed 10MB!')
        return
      }
      console.log('Reason file: ', file)
      this.$prompt('Please input public key of the submitting author.', 'Information required', {
        confirmButtonText: 'OK',
        cancelButtonText: 'Cancel'
      }).then(({ value }) => {
        // Valid Public key before proceeding.
        this.pubKeyOfSubAuthor = this.convertHextoBytes(value.substring(2))
        // Create key pair.
        var jKeyPair = generateKeyPair()
        var journalsPrvKey = jKeyPair.secretKey
        // var journalsPubKey = jKeyPair.publicKey
        var reader = new FileReader()
        reader.readAsText(file)
        reader.onload = e => asymmEncrypt(journalsPrvKey, e.target.result, this.pubKeyOfSubAuthor) // e.target.result is the filestring or actual text within the file.
          .then(encryptedData => {
            this.pushToIPFShub(encryptedData)
          })
      })
    },
    pushToIPFShub (encryptedData) {
      var encryptedDataToSendToJviaIPFS = JSON.stringify({ encryptedData })
      // console.log('Connecting to IPFS.')
      const MyBuffer = window.Ipfs.Buffer
      var dataToBuffer = MyBuffer.from(encryptedDataToSendToJviaIPFS)
      // console.log('Buffer conversion done.')
      ipfs.add(dataToBuffer).then(res => {
        // console.log('Response object from IPFS: ', res)
        // console.log('Returned hash: ', res[0].hash)
        console.log('Data upload to IPFS sucessful')
        this.ipfsHashOfUploadedReasonFIle = res[0].hash
      })
    },
    convertHextoBytes (hexString) {
      var bytes = new Uint8Array(Math.ceil(hexString.length / 2))
      for (var i = 0; i < bytes.length; i++) bytes[i] = parseInt(hexString.substr(i * 2, 2), 16)
      return bytes
    },
    backToPrvPack () {
      this.$router.push('/')
    },
    handleRemove (file, fileList) {
      console.log(file, fileList)
    },
    beforeRemove (file, fileList) {
      return this.$confirm(`Cancel the transfert of ${file.name} ?`)
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

.hashValuesForIPFS{
  font-size: 0.8rem;
  color: rgb(113, 140, 189);
}

</style>
