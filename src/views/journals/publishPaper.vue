<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="body" v-loading="loadingData">
            <h3 id="pageInfo">Welcome to Journal Paper Publication.</h3>
            <h4> Upload final paper and fill the form.</h4>
            <el-row>
                <el-col :span="22">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="jPaperPubForm"
                            :rules="rules"
                            ref="jPaperPubForm"
                            label-width="180px"
                        >
                        <div class="separator">
                            <el-row>
                                <el-col :span="20" :offset="3">
                                    <fieldset>
                                        <legend>File upload</legend>
                                        <p id="instructionText"><b>Instruction:</b><i> Please, enter the hash of the original paper before uploading the final paper to be published.</i></p>
                                    <el-col :span="11" :offset="0">
                                        <el-button type="text" @click="origManuHashDialog = true">**Click here to enter Hash of original paper**</el-button>
                                        <el-dialog title="Information required" :visible.sync="origManuHashDialog" width="40%">
                                            <el-form :model="origPaperHashForm" :rules="rules" ref="origPaperHashForm">
                                                <el-form-item label="Hash of original paper" label-width="50" prop="origManuPaperHash">
                                                <el-input v-model="origPaperHashForm.origManuPaperHash" autocomplete="off"></el-input>
                                                </el-form-item>
                                            </el-form>
                                            <span slot="footer" class="dialog-footer">
                                                <el-button @click="origManuHashDialog = false">Cancel</el-button>
                                                <el-button type="primary" @click="getOrigManuHash('origPaperHashForm')">Confirm</el-button>
                                            </span>
                                            </el-dialog>
                                    </el-col>
                                            <el-col :span="11" :offset="0">
                                                <el-form-item label="Final paper to publish" prop="finalPubPaper">
                                                    <el-upload
                                                    class="upload-demo"
                                                    action="finalPaperUpload"
                                                    :http-request="beforeUpload">
                                                    <el-button slot="trigger" size="small" type="primary">Select file</el-button>
                                                    <div class="el-upload__tip" slot="tip">.pdf,.doc,.docx files only with a size less than 10MB</div>
                                                    </el-upload>
                                                </el-form-item>
                                            </el-col>
                                    </fieldset>
                                </el-col>
                            </el-row>
                        </div>
                        <div class="separator">
                            <el-row>
                                <el-col :span="20" :offset="3">
                                    <fieldset>
                                        <legend>Paper's information</legend>
                                            <el-row>
                                                <el-col :span="11" :offset="0">
                                                    <p>Hash of uploaded final paper appears below.</p>
                                                    <p class="hashValuesForIPFS">{{hashOfFinalPaper}}</p>
                                                </el-col>
                                                <el-col :span="11" :offset="0">
                                                    <p>IPFS Hash of uploaded final paper appears below.</p>
                                                    <p class="hashValuesForIPFS">{{IPFSHashOfFinalPaper}}</p>
                                                </el-col>
                                            </el-row>
                                            <el-row>
                                                <el-col :span="11" :offset="0">
                                                    <el-form-item label="Eth Address of author" prop="subAuthEthAddress">
                                                        <el-input clearable v-model="jPaperPubForm.subAuthEthAddress" placeholder="Input Eth address of submitting author."></el-input>
                                                    </el-form-item>
                                                </el-col>
                                                <el-col :span="11" :offset="0">
                                                    <el-form-item label="Paper Title" prop="paperTitle">
                                                        <el-input clearable v-model="jPaperPubForm.paperTitle" placeholder="Please enter the title of the paper."></el-input>
                                                    </el-form-item>
                                                </el-col>
                                            </el-row>
                                    </fieldset>
                                </el-col>
                            </el-row>
                        </div>
                        <el-col :span="20" :offset="3">
                        <el-row>
                            <el-form-item label="**Journal's consent**" prop="authCheckBox">
                                <el-col :span="16" :offset="2">
                                    <el-checkbox v-model="jPaperPubForm.authCheckBox">I have checked the authenticity of the above provided details.</el-checkbox>
                                </el-col>
                            </el-form-item>
                        </el-row>
                        </el-col>
                        <el-form-item>
                            <el-button class="btnSection" type="primary" :loading="journalPubSubBtnLoadState" @click="submitForm('jPaperPubForm')">Publish</el-button>
                            <el-button class="btnSection" @click="resetForm('jPaperPubForm')">Reset</el-button>
                        </el-form-item>
                    </el-form>
                    </div>
                </el-col>
            </el-row>
        <el-dialog title="Journa's ethereum account" width="30%" :visible.sync="accountDialog">
            <el-form :model="accountNumForm"
            :rules="rules"
            ref="accountNumForm">
                <el-form-item label="Account Number" prop="accountNum">
                <el-input v-model="accountNumForm.accountNum" autocomplete="off"></el-input>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="accountDialog = false">Cancel</el-button>
                <el-button :loading="getAccountLoadState" type="primary" @click="getAccountOnPageLoad('accountNumForm')">Confirm</el-button>
            </span>
        </el-dialog>
        </div>
        <!---<Footer></Footer>--->
    </div>
</template>

<script>
// @ is an alias to /src
// import Footer from '@/components/Footer'
import web3 from '@/assets/js/web3'
// import Web3 from 'web3'
import getHash from '@/assets/js/hashFunc'
import { symEncrypt } from '@/assets/js/symEncryptAndDec'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'
// const CryptoJs = new window.CrytoJs()
const ipfs = new window.Ipfs()
// Or import web3 <script> at index page and set the provider you want from Web3.providers as below.
// const web3 = new window.Web3(new window.Web3.providers.HttpProvider('http://localhost:8545')) // This node address should be same for Ganache.
// console.log('Crypto Js: ', CryptoJs)
export default {
  name: 'authorSubmit',
  data () {
    return {
      jPaperPubForm: {
        finalPubPaper: '',
        subAuthEthAddress: '',
        paperTitle: '',
        authCheckBox: ''
      },
      origPaperHashForm: { origManuPaperHash: '' },
      origPaperHash: '',
      authorPubKey: '',
      // Dynamic variables.
      journals: [],
      hashOfFinalPaper: '',
      IPFSHashOfFinalPaper: '',
      openAccessChoiceOfAuthor: '',
      accountNumForm: { accountNum: '' },
      accountIndexEntered: '',
      loadingData: false,
      origManuHashDialog: false,
      journalPubSubBtnLoadState: false,
      accountDialog: false,
      getAccountLoadState: false,
      buffer: '',
      rules: {
        origManuPaperHash: [
          { required: true, message: 'Please enter the hash of the original paper.', trigger: 'blur' },
          { min: 64, message: 'Length should be at least 64', trigger: 'blur' }
        ],
        subAuthEthAddress: [
          { required: true, message: 'Please input Eth address of submitting author', trigger: 'blur' },
          { min: 20, message: 'Length should be at least 20', trigger: 'blur' }
        ],
        paperTitle: [
          { required: true, message: 'Please input title of the paper', trigger: 'blur' },
          { min: 2, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        authCheckBox: [
          { required: true, message: 'Please check the checkbox.', trigger: 'blur' }
        ],
        accountNum: [
          { required: true, message: 'Please input address of the journal.', trigger: 'blur' },
          { min: 1, max: 1, message: 'Can only be a number from 0 to 9', trigger: 'blur' }
        ]
      }
    }
  },
  components: {
    // Head
    // Footer
  },
  created () {
    this.$alert('Please, provide the required information when prompted.', 'Notification!', {
      confirmButtonText: 'OK',
      callback: action => {
        this.$message({
          type: 'info',
          message: `action: ${action}`
        })
      }
    })
    // Open the account dialog box.
    this.accountDialog = true
  },
  watch: {
    'authorSubForm.authorsIDs' () {
      this.computeHash()
    },
    // Can also be done without reference to the form but validation rules must be checked.
    // authorsIDs: function () {
    //   this.computeHash()
    // },
    'authorSubForm.namesOfAuthors' () {
      this.computeHash()
    }
  },
  methods: {
    computeHash: function () {
      if (this.authorSubForm.authorsIDs.length !== 0) {
        getHash(this.authorSubForm.authorsIDs)
          .then(res => {
            this.hashedIDsOfAuthors = res
          })
      }
      if (this.authorSubForm.namesOfAuthors.length !== 0) {
        getHash(this.authorSubForm.namesOfAuthors)
          .then(res => {
            this.hashedNamesOfAuthors = res
          })
      } else {
        this.hashedIDsOfAuthors = ''
        this.hashedNamesOfAuthors = ''
      }
    },
    submitForm (formName) {
      if (this.accountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          if (valid) {
            // get input data and continue.
            var data = {
              origPaperHash: this.origPaperHash,
              hashOfFinalFile: this.hashOfFinalPaper,
              ipfsHashOfFinalFile: this.IPFSHashOfFinalPaper,
              paperTitle: this.jPaperPubForm.paperTitle,
              subAuthEthAddress: this.jPaperPubForm.subAuthEthAddress,
              oaChoice: this.openAccessChoiceOfAuthor,
              chkBox: this.jPaperPubForm.authCheckBox
            }
            // Set submit loading state to true.
            this.journalPubSubBtnLoadState = true
            console.log('Data to submit is: ', data)
            if (data.chkBox === true) {
              // User has checked validity of provided information. Proceed.
              if (web3.utils.isAddress(data.subAuthEthAddress) === true) {
                // All validation checks completed. Proceed to required conversions.
                var convertedPaperTitle = web3.utils.utf8ToHex(data.paperTitle)
                var convIPFSHashOfFinalPaper = convertIPFSstringToBytes(data.ipfsHashOfFinalFile)
                var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
                console.log('Contract instance created.')
                try {
                  jpBlockContract.methods.createPublication(data.subAuthEthAddress, convertedPaperTitle, data.origPaperHash, data.hashOfFinalFile, convIPFSHashOfFinalPaper).send({
                    from: web3.eth.defaultAccount,
                    gas: 450000 // Check gas issues.
                  }).on('transactionHash', (hash) => {
                    console.log('Trans. hash is: ', hash)
                  }).on('receipt', (receipt) => {
                    console.log('Trans. Block Number is: ', receipt.blockNumber)
                    // Set submit loading state to false.
                    this.journalPubSubBtnLoadState = false
                    // this.$message('Do not forgot to copy and keep hash of the submitted paper.')
                    // Display success note.
                    this.$message({
                      message: 'Paper publication on JPBlock successful.',
                      type: 'success'
                    })
                  }).on('error', (error) => {
                    console.log('Error occured.', error)
                    this.journalPubSubBtnLoadState = false
                    this.$message.error('Sorry! Transaction error. Please, try again later.')
                    // window.location.reload()
                  })
                } catch {
                  console.log('Sorry! Error occured.')
                  this.journalPubSubBtnLoadState = false
                  this.$message.error('Sorry! Non-transactional. Please try again later.')
                }
              } else {
                this.journalPubSubBtnLoadState = false
                this.$message('Invalid Ethereum address entered. Please, reenter.')
              }
            } else {
              this.journalPubSubBtnLoadState = false
              this.$message('Please check the checkbox.')
            }
          } else {
            console.log('Submission error.')
            this.journalPubSubBtnLoadState = false
            return false
          }
        })
      } else {
        this.$message('Enter required author account. Reloading page...')
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
    hashInputValidation (input) {
      const count = input.toString().length
      if (isNaN(input) === true || input < 0 || count <= 63) {
        return 0
      } else {
        return 1
      }
    },
    getAccountOnPageLoad (formName) {
      this.$refs[formName].validate(valid => {
        if (valid) {
          this.getAccountLoadState = true
          this.accountIndexEntered = this.accountNumForm.accountNum
          // Get and use web3 object.
          // console.log('web3 object is:', web3)
          web3.eth.getAccounts().then(res => {
            // console.log('Response from web3: ', res)
            web3.eth.defaultAccount = res[this.accountIndexEntered]
            console.log('Ethereum address of this author is: ', web3.eth.defaultAccount)
          })
          this.getAccountLoadState = false
          this.accountDialog = false
        }
      })
    },
    beforeUpload (item) {
      if (this.hashInputValidation(this.origPaperHash) === 1) {
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
        console.log('Final file: ', file)
        var reader = new FileReader()
        reader.readAsText(file)
        reader.onload = e => getHash(e.target.result) // e.target.result is the filestring or actual text within the file.
          .then(res => {
            this.hashOfFinalPaper = res
            // Check OpenAccess choice based on the orignal paper's hash entered.
            var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
            console.log('Contract instance for access type retrieval created.')
            this.loadingData = true
            // Smart contract and other logic continues.
            jpBlockContract.methods.authorPublicationChoice(this.origPaperHash).call({ from: web3.eth.defaultAccount }).then(res => {
              this.openAccessChoiceOfAuthor = res
              console.log('Author OA choice: ', res)
              if (res === '1') { // Remember to change this to '1'
              // Open access hence no encryption. Send to IPFS.
                this.fileExtractor(file)
              } else {
              // Restricted hence encrypt and send to IPFS.
                this.resManuscriptFileExtractor(file)
              }
            }).catch((error) => {
              console.log('Error occurred.', error)
              this.getAccBalLoadBtn = false
              this.$message.error('Sorry! Transaction error. Please, try again later.')
            })
          })
      } else {
        this.$message({
          showClose: true,
          message: 'Invalid hash. Please, first, enter the hash of the original file and try again.'
        })
      }
    },
    resManuscriptFileExtractor (file) {
      // console.log('Inside restricted manuscript file extractor.')
      var exAndEncrptReader = new FileReader()
      exAndEncrptReader.readAsText(file)
      exAndEncrptReader.onload = this.finalFileLoaded
    },
    fileExtractor (file) {
      // console.log('Inside file extractor.')
      var rawReader = new FileReader()
      rawReader.readAsText(file)
      rawReader.onload = this.finalFileRawPush
    },
    async finalFileRawPush (evt) {
      // console.log('Inside finalFile raw push aync function.')
      var fileString = evt.target.result
      // console.log('Encryption done.')
      // console.log('Encrypted manuscript data is: ', encryptedData)
      this.pushRawToIPFShub(fileString)
    },
    async finalFileLoaded (evt) {
      // console.log('Inside finalFileLoaded aync function.')
      var fileString = evt.target.result
      // console.log('filestring done.', fileString)
      this.$prompt('Restricted paper. Please input encryption key.', 'Information required', {
        confirmButtonText: 'Continue',
        cancelButtonText: 'Cancel',
        inputPlaceholder: 'Enter encryption key for the journal.'
      }).then(({ value }) => {
        symEncrypt(fileString, value).then(encryptedData => {
          console.log('Encryption done.')
          // console.log('Encrypted manuscript data is: ', encryptedData)
          this.pushToIPFShub(encryptedData)
        }).catch((error) => {
          this.loadingData = false
          this.$message.error('Error encrypting data. Please, try again..')
          console.log('Error with encryption:', error)
        }
        )
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
        this.loadingData = false
        this.$message('File upload success.')
        this.IPFSHashOfFinalPaper = res[0].hash
      })
    },
    pushRawToIPFShub (data) {
      const MyBuffer = window.Ipfs.Buffer
      var dataToBuffer = MyBuffer.from(data)
      // console.log('Buffer conversion done.')
      ipfs.add(dataToBuffer).then(res => {
        // console.log('Response object from IPFS: ', res)
        // console.log('Returned hash: ', res[0].hash)
        console.log('Data upload to IPFS sucessful')
        this.loadingData = false
        this.$message('File upload success.')
        this.IPFSHashOfFinalPaper = res[0].hash
      })
    },
    // Some helper functions during encryption.
    convertHextoBytes (hexString) {
      var bytes = new Uint8Array(Math.ceil(hexString.length / 2))
      for (var i = 0; i < bytes.length; i++) bytes[i] = parseInt(hexString.substr(i * 2, 2), 16)
      return bytes
    },
    // Function to convert BytesArray to Hex.
    convertBytesArrayToHex (bytes) {
      var convertedBytes = ''
      for (var i = 0; i < bytes.length; i++) {
        if (bytes[i] < 16) convertedBytes += '0'
        convertedBytes += bytes[i].toString(16)
      }
      return '0x' + convertedBytes
    },
    getOrigManuHash (formName) {
      if (this.accountIndexEntered.length !== 0) {
        this.$refs[formName].validate(valid => {
          if (valid) {
            this.origPaperHash = this.origPaperHashForm.origManuPaperHash
            console.log('Orig. Hash is: ', this.origPaperHash)
            this.origManuHashDialog = false
            this.$message('Hash captured.')
          }
        })
      }
    },
    handleRemove (file, fileList) {
      console.log(file, fileList)
    },
    beforeRemove (file, fileList) {
      return this.$confirm(`Cancel the transfert of ${file.name} ?`)
    },
    onRadioSelect (data) {
      this.radio = data
      console.log('Author has selected:', this.radio)
    },
    handleClose (done) {
      this.$confirm('Are you sure to close this dialog?')
        .then(_ => {
          done()
        })
        .catch(_ => {})
    },
    backToPrvPack () {
      this.$router.push('/')
    }
  },
  computed: {
    // IPFSHashOfSupPaper () {
    // return 'Qm12345'
    // }
  }
}
</script>

<style scoped>
.pageContainer {
  height: 100%;
}

#topNav{
  width: 100%;
  height: 4%;
}

#pageInfo{
    margin-top: 0.2rem;
}

fieldset {
  border-radius: 8px;
}

legend {
 font-style: italic;
}

#hashCopyNote{
    color: cornflowerblue;
}

.hashValues{
    font-size: 0.7rem;
}

#instructionText{
    font-size: 0.8rem;
}

.hashValuesForIPFS{
  font-size: 0.8rem;
  color: rgb(113, 140, 189);
}

.separator{
    margin-top: 1rem;
}

.btnSection{
    margin-top: 1rem;
}

</style>
