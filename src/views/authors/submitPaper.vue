<template>
    <div class="pageContainer">
        <div id="topNav">
          <el-link icon="el-icon-arrow-left" style="font-size:17px;float:left;" @click="backToPrvPack">Previous Page</el-link>
        </div>
        <div class="body" v-loading="loadingData">
            <h3 id="pageInfo">Welcome to Paper Submission/Resubmission</h3>
            <h4>Please upload files and fill the form</h4>
            <el-row>
                <el-col :span="22">
                    <div class="grid-content bg-purple-dark">
                        <el-form
                            :model="authorSubForm"
                            :rules="rules"
                            ref="authorSubForm"
                            label-width="180px"
                        >
                        <el-row>
                            <el-col :span="20" :offset="3">
                                <fieldset>
                                    <legend>File uploads</legend>
                                        <el-col :span="11" :offset="1">
                                            <el-form-item label="Main paper" prop="mainPaper">
                                                <el-upload
                                                  class="upload-demo"
                                                  action="mainPaperUpload"
                                                  :http-request="beforeUpload"
                                                  :on-remove="handleRemove"
                                                  :before-remove="beforeRemove">
                                                  <el-button slot="trigger" size="small" type="primary">Select file</el-button>
                                                  <div class="el-upload__tip" slot="tip">.pdf,.doc,.docx files only with a size less than 10MB</div>
                                                </el-upload>
                                            </el-form-item>
                                        </el-col>
                                        <el-col :span="11" :offset="1">
                                            <el-form-item label="Supplementary paper" prop="supplPaper">
                                                <el-upload
                                                  class="upload-demo"
                                                  action="supPaperUpload"
                                                  :http-request="beforeUpload">
                                                  <el-button slot="trigger" size="small" type="primary">Select file</el-button>
                                                  <div class="el-upload__tip" slot="tip">.pdf,.doc,.docx files only with a size less than 10MB</div>
                                                </el-upload>
                                            </el-form-item>
                                        </el-col>
                                </fieldset>
                            </el-col>
                        </el-row>
                        <el-row>
                            <el-col :span="20" :offset="3">
                                <fieldset>
                                    <legend>Paper's information</legend>
                                        <el-row>
                                            <el-col :span="10" :offset="1">
                                                <p>IPFS Hash of uploaded paper appears below.</p>
                                                <p class="hashValuesForIPFS">{{IPFSHashOfMainPaper}}</p>
                                            </el-col>
                                            <el-col :span="11" :offset="0">
                                                <p>IPFS Hash of uploaded Supplementary paper appears below.</p>
                                                <p class="hashValuesForIPFS">{{IPFSHashOfSupPaper}}</p>
                                            </el-col>
                                        </el-row>
                                        <el-row>
                                            <el-col :span="10" :offset="1">
                                                <p id="hashCopyNote">Hash of uploaded paper.</p>
                                                <p class="hashValues"><i>{{HashOfMainPaper}}</i></p>
                                            </el-col>
                                            <el-col :span="10" :offset="1">
                                                <el-form-item label="Paper Title" prop="paperTitle">
                                                    <el-input clearable v-model="authorSubForm.paperTitle" placeholder="Please enter the title of the paper."></el-input>
                                                </el-form-item>
                                            </el-col>
                                        </el-row>
                                        <el-row>
                                            <el-col :span="10" :offset="1">
                                                <el-form-item label="ID(s) of author(s)" prop="authorsIDs">
                                                    <el-input clearable v-model="authorSubForm.authorsIDs" placeholder="Multiple authors:Separate with ,"></el-input>
                                                </el-form-item>
                                            </el-col>
                                            <el-col :span="10" :offset="1">
                                                <el-form-item label="Name(s) of author(s)" prop="namesOfAuthors">
                                                    <el-input clearable v-model="authorSubForm.namesOfAuthors" placeholder="Multiple authors:Sparate with ,"></el-input>
                                                </el-form-item>
                                            </el-col>
                                        </el-row>
                                        <el-row>
                                            <el-col :span="10" :offset="1">
                                                <p class="hashValues">{{hashedIDsOfAuthors}}</p>
                                            </el-col>
                                            <el-col :span="10" :offset="1">
                                                <p class="hashValues">{{hashedNamesOfAuthors}}</p>
                                            </el-col>
                                        </el-row>
                                </fieldset>
                            </el-col>
                        </el-row>
                        <el-row>
                            <el-col :span="20" :offset="3">
                                <fieldset>
                                    <legend>Journal's information</legend>
                                        <el-col :span="10" :offset="1">
                                            <el-form-item label="Journal's Eth address" prop="jEthAddress">
                                                <el-input clearable v-model="authorSubForm.jEthAddress" placeholder="Please, enter the journal's address."></el-input>
                                            </el-form-item>
                                        </el-col>
                                        <el-col :span="10" :offset="1">
                                            <el-form-item label="Journal's name" prop="jName">
                                                <el-select
                                                    v-model="authorSubForm.jName"
                                                    style="width:100%"
                                                    placeholder="Please select the name of the journal"
                                                    value-key="id">
                                                    <el-option
                                                        v-for="journal in journals"
                                                        :key="journal.id"
                                                        :label="journal.name"
                                                        :value="journal">
                                                    </el-option>
                                                </el-select>
                                            </el-form-item>
                                        </el-col>
                                </fieldset>
                            </el-col>
                        </el-row>
                        <el-col :span="20" :offset="3">
                        <el-row>
                            <el-col>
                                <el-col :span="8" :offset="1">
                                    <p><i>Choice of publication when accepted.</i></p>
                                    <el-radio-group v-model="radio" @input="onRadioSelect">
                                        <el-radio label="1">Open Access</el-radio>
                                        <el-radio label="0">Non Open Access</el-radio>
                                    </el-radio-group>
                                </el-col>
                                <el-col :span="8" :offset="1">
                                    <p><i>**Author consent**</i></p>
                                    <el-checkbox v-model="authCheckBox">I have checked the authenticity of the above provided details.</el-checkbox>
                                </el-col>
                            </el-col>
                        </el-row>
                        </el-col>
                        <el-form-item>
                            <el-button class="btnSection" type="primary" :loading="authorSubBtnLoadState" @click="submitForm('authorSubForm')">Submit</el-button>
                            <el-button class="btnSection" @click="resetForm('authorSubForm')">Reset</el-button>
                        </el-form-item>
                    </el-form>
                    </div>
                </el-col>
            </el-row>
        <el-dialog title="Submitting author's ethereum account" width="30%" :visible.sync="accountDialog">
            <el-form :model="accountNumForm"
            :rules="rules"
            ref="accountNumForm">
                <el-form-item label="Account Number" prop="accountNum">
                <el-input v-model="accountNumForm.accountNum" autocomplete="off"></el-input>
                </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="pgReload()">Cancel</el-button>
                <el-button :loading="getAccountLoadState" type="primary" @click="getAccountOnPageLoad('accountNumForm')">Confirm</el-button>
            </span>
        </el-dialog>
        <el-dialog
          title="Notification"
          :visible.sync="hashCopyAlertDialog"
          width="30%"
          center>
          <span>Hash of submitted paper. Please, copy and keep it.</span>
          <p class="hashValues">{{HashOfMainPaper}}</p>
          <span slot="footer" class="dialog-footer">
            <el-button @click="hashCopyAlertDialog = false">Cancel</el-button>
            <el-button type="primary" @click="hashCopyAlertDialog = false">Confirm</el-button>
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
import { generateKeyPair, asymmEncrypt } from '@/assets/js/asymmEncrypt'
import { ABI, contractAddress, suppliedGas } from '@/assets/js/contractABI'
import convertIPFSstringToBytes from '@/assets/js/convertIPFShash.js'
const ipfs = new window.Ipfs()
// Or import web3 <script> at index page and set the provider you want from Web3.providers as below.
// const web3 = new window.Web3(new window.Web3.providers.HttpProvider('http://localhost:8545')) // This node address should be same for Ganache.

export default {
  name: 'authorSubmit',
  data () {
    return {
      authorSubForm: {
        mainPaper: '',
        supplPaper: '',
        paperTitle: '',
        authorsIDs: '',
        namesOfAuthors: '',
        jEthAddress: '',
        jName: ''
      },
      radio: '0',
      authCheckBox: '',
      hashedIDsOfAuthors: '',
      hashedNamesOfAuthors: '',
      pubKeyOfJournal: '',
      authorPrvKey: '',
      authorPubKey: '',
      // Dynamic variables.
      journals: [],
      HashOfMainPaper: '',
      IPFSHashOfMainPaper: '',
      IPFSHashOfSupPaper: '',
      authorUploads: null,
      accountNumForm: { accountNum: '' },
      accountIndexEntered: '',
      loadingData: false,
      authorSubBtnLoadState: false,
      accountDialog: false,
      hashCopyAlertDialog: false,
      getAccountLoadState: false,
      buffer: '',
      rules: {
        jName: [
          { required: true, message: 'Please select Journal name from the list.', trigger: 'blur' }
        ],
        paperTitle: [
          { required: true, message: 'Please input title of paper', trigger: 'blur' },
          { min: 3, message: 'Length should be at least 3', trigger: 'blur' }
        ],
        authorsIDs: [
          { required: true, message: 'Please input ID(s)', trigger: 'blur' },
          { min: 4, message: 'Length should be at least 4', trigger: 'blur' }
        ],
        namesOfAuthors: [
          { required: true, message: 'Please input name(s)', trigger: 'blur' },
          { min: 2, message: 'Length should be at least 2', trigger: 'blur' }
        ],
        jEthAddress: [
          { required: true, message: 'Please input address of the journal.', trigger: 'blur' },
          { min: 2, max: 42, message: 'Length should be at least 2', trigger: 'blur' }
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
        this.loadingData = true
        const jObj = []
        var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
        console.log('Contract instance for access type retrieval created.')
        // Smart contract and other logic continues.
        jpBlockContract.methods.getRegisteredJournals().call({ from: web3.eth.defaultAccount }).then(journalList => {
          if (journalList[2].length >= 1) {
            for (let i = 0; i < journalList[2].length; i++) {
              jObj[i] = { id: i, name: (web3.utils.hexToAscii(journalList[2][i])).replace(/[^a-z]/gi, '') }
            // [^a-z] matches every alphabet and 'i' flag makes it case insensitive.
            // `g` flag checks for multiple instances.
            }
            this.journals = jObj
            this.loadingData = false
            // Open the account dialog box.
            this.accountDialog = true
          } else {
            this.$alert('Sorry! No registered journals exist on JPBlock at the moment. Please try again later.', 'Alert!', {
              confirmButtonText: 'OK',
              callback: action => {
                this.$message({
                  type: 'info',
                  message: `action: ${action}`
                })
                this.$router.push('/')
              }
            })
          }
        }).catch((error) => {
          console.log('Error occurred.', error)
          this.getAccBalLoadBtn = false
          this.$message.error('Sorry! Transaction error. Please, try again later.')
        })
      }
    })
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
              hashOfPaper: this.HashOfMainPaper,
              ipfsHash_MainPaper: this.IPFSHashOfMainPaper,
              ipfsHash_SupPaper: this.IPFSHashOfSupPaper,
              paperTitle: this.authorSubForm.paperTitle,
              authorIDsHashed: this.hashedIDsOfAuthors,
              authorNamesHashed: this.hashedNamesOfAuthors,
              jAddress: this.authorSubForm.jEthAddress,
              jName: this.authorSubForm.jName.name,
              pubChoice: this.radio,
              chkBox: this.authCheckBox
            }
            // Set submit loading state to true.
            this.authorSubBtnLoadState = true
            console.log('Data to submit is: ', data)
            if (data.chkBox === true) {
              // User has checked validity of provided information. Proceed.
              if (web3.utils.isAddress(data.jAddress) === true) {
                if (data.jName.length !== 0) {
                  this.$prompt('Please enter hash of the original paper if resubmitting.', 'Information required', {
                    confirmButtonText: 'Continue',
                    cancelButtonText: 'Cancel',
                    inputPlaceholder: 'Click continue if not resubmitting.'
                  }).then(({ value }) => {
                    var origManuHash
                    if (value === '' || value === null) {
                      origManuHash = web3.utils.utf8ToHex('New Submission') // New submission hence not resubmitting.
                      console.log('Proceeding as new submission.')
                    } else if (this.hashInputValidation(value) === 0) {
                      this.authorSubBtnLoadState = false
                      this.$message('Invalid resubmitted manuscript hash.')
                      return
                    } else {
                      origManuHash = value
                    }
                    console.log('All checks passed.')
                    // All validation checks completed. Proceed to required conversions.
                    var convertedJname = web3.utils.utf8ToHex(data.jName)
                    var convertedPaperTitle = web3.utils.utf8ToHex(data.paperTitle)
                    var convertedAuthorPubKey = this.convertBytesArrayToHex(this.authorPubKey)
                    var convIPFSHashOfMainPaper = convertIPFSstringToBytes(data.ipfsHash_MainPaper)
                    var convIPFSHashOfSupPaper = convertIPFSstringToBytes(data.ipfsHash_SupPaper)
                    var jpBlockContract = new web3.eth.Contract(ABI, contractAddress, { defaultGas: suppliedGas })// End of ABi Code from Remix.
                    console.log('Contract instance created.')
                    try {
                      jpBlockContract.methods.submitPaper(origManuHash, data.hashOfPaper, convIPFSHashOfMainPaper,
                        convIPFSHashOfSupPaper, convertedPaperTitle, this.hashedIDsOfAuthors, this.hashedNamesOfAuthors,
                        data.jAddress, convertedJname, convertedAuthorPubKey, data.pubChoice).send({
                        from: web3.eth.defaultAccount,
                        gas: 450000 // Check gas issues.
                      }).on('transactionHash', (hash) => {
                        console.log('Trans. hash is: ', hash)
                      }).on('receipt', (receipt) => {
                        console.log('Trans. Block Number is: ', receipt.blockNumber)
                        // Set submit loading state to false.
                        this.authorSubBtnLoadState = false
                        this.$message({
                          message: 'Paper submission successful.',
                          type: 'success'
                        })
                        this.hashCopyAlertDialog = true
                      }).on('error', (error) => {
                        console.log('Error occured.', error)
                        this.authorSubBtnLoadState = false
                        this.$message.error('Sorry! Transaction error. Please, try again later.')
                        // window.location.reload()
                      })
                    } catch {
                      console.log('Sorry! Error occured.')
                      this.authorSubBtnLoadState = false
                      this.$message.error('Sorry! Non-transactional. Please try again later.')
                    }
                  }) // Then ends here.
                } else {
                  this.authorSubBtnLoadState = false
                  this.$message('Please select the name of the journal from the dropdown box.')
                }
              } else {
                this.authorSubBtnLoadState = false
                this.$message('Invalid Ethereum address entered. Please, reenter.')
              }
            } else {
              this.authorSubBtnLoadState = false
              this.$message('Please check the checkbox.')
            }
          } else {
            console.log('Submission error.')
            this.authorSubBtnLoadState = false
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
          this.keyGen()
        }
      })
    },
    keyGen () {
      if (this.pubKeyOfJournal.length === 0 && this.authorPrvKey.length === 0) {
        this.$prompt('Please input public key of the journal manuscript is being sent.', 'Information required', {
          confirmButtonText: 'OK',
          cancelButtonText: 'Cancel',
          inputPattern: /^0x[0-9A-F]{64}$/i
        }).then(({ value }) => {
        // Valid Public key before proceeding.
          this.pubKeyOfJournal = this.convertHextoBytes(value.substring(2))
          // Create key pair.
          var authorKeyPair = generateKeyPair()
          this.authorPrvKey = authorKeyPair.secretKey
          this.authorPubKey = authorKeyPair.publicKey
        }).catch((err) => {
          console.log('User has cancelled.', err)
          window.location.reload() // Reload page.
        })
      }
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
      if (item.action === 'mainPaperUpload') {
        console.log('Main manuscript file: ', file)
        var reader = new FileReader()
        reader.readAsText(file)
        reader.onload = e => getHash(e.target.result) // e.target.result is the filestring or actual text within the file.
          .then(res => {
            this.HashOfMainPaper = res
            // console.log('Hash of main paper computed.')
            this.manuscriptFileExtractor(file)
          })
      } else {
        this.supFileExtractor(file)
      }
    },
    manuscriptFileExtractor (file) {
      // console.log('Inside manuscript file extractor.')
      var exAndEncrptReader = new FileReader()
      exAndEncrptReader.readAsText(file)
      exAndEncrptReader.onload = this.manuLoaded
    },
    supFileExtractor (file) {
      var exAndEncrptReader = new FileReader()
      exAndEncrptReader.readAsText(file)
      exAndEncrptReader.onload = this.supLoaded
    },
    async manuLoaded (evt) {
      // console.log('Inside manuLoaded aync function.')
      var fileString = evt.target.result
      // console.log('filestring done.', fileString)
      var encryptedData = asymmEncrypt(this.authorPrvKey, fileString, this.pubKeyOfJournal)
      // console.log('Encryption done.')
      // console.log('Encrypted manuscript data is: ', encryptedData)
      this.pushToIPFShub(encryptedData, 'IPFSHashOfMainPaper')
    },
    async supLoaded (evt) {
      // console.log('Inside aync function.')
      var fileString = evt.target.result
      var encryptedData = asymmEncrypt(this.authorPrvKey, fileString, this.pubKeyOfJournal)
      // console.log('Encryption done.')
      // console.log('Encrypted data is: ', encryptedData)
      this.pushToIPFShub(encryptedData, 'IPFSHashOfSupPaper')
    },
    pushToIPFShub (encryptedData, placement) {
      var encryptedDataToSendToJviaIPFS = JSON.stringify({ encryptedData })
      // console.log('Connecting to IPFS.')
      const MyBuffer = window.Ipfs.Buffer
      var dataToBuffer = MyBuffer.from(encryptedDataToSendToJviaIPFS)
      // console.log('Buffer conversion done.')
      ipfs.add(dataToBuffer).then(res => {
        // console.log('Response object from IPFS: ', res)
        // console.log('Returned hash: ', res[0].hash)
        console.log('Data upload to IPFS sucessful')
        if (placement === 'IPFSHashOfMainPaper') {
          this.IPFSHashOfMainPaper = res[0].hash
        } else if (placement === 'IPFSHashOfSupPaper') {
          this.IPFSHashOfSupPaper = res[0].hash
        }
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
    },
    pgReload () {
      window.location.reload() // Reload page.
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

.hashValuesForIPFS{
  font-size: 0.8rem;
  color: rgb(113, 140, 189);
}

.btnSection{
    margin-top: 1rem;
}

h4{ color: rgb(15, 91, 94); font-style: italic;}

</style>
