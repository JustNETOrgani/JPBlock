# JPBlockDApp
A blockchain-based platform to augment journal and academic paper publication
The Smart contract governing the platform is available in src/assets/JPBlockSmartContract directory.

Instructions to run locally:
1. Run a local instance of Ethereum blockchain using for example Ganache-cli.
2. Compile and deploy JPBlock smart contract via Remix IDE.
3. Install Metamask browser extension for wallet functionality.
4. Update "contractAddress" within the contractABI.js file (inside src/assets/js directory) file used by the DApp.
5. Run "npm install" in the main directory of the project to install all dependencies.
6. Run "npm run serve" to run the DApp on localhost.
7. Access the DApp's UI in the browser via localhost to interact with it.
 
## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
