import 'crypto-js'
import aes from 'crypto-js/aes'

function symEncrypt (data, key) {
  var ciphertext = aes.encrypt(JSON.stringify(data), key).toString()
  return ciphertext
}

function symDecrypt (encData, key) {
  var bytes = aes.decrypt(encData, key)
  // var decryptedData = JSON.parse(bytes.toString(CryptoJS.enc.Utf8));
  return bytes
}

export default { symEncrypt, symDecrypt }
