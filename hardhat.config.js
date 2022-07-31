
const { ROPSTEN_RPC_URL, PRIVATE_KEY } = process.env;
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const accounts = {
  mnemonic: `${process.env.MNEMONIC}`,
};

module.exports = {
  solidity:{
    compilers:[{version:"0.8.9"}]
  } ,
    networks: {
      hardhat:{},
        ropsten: {
            url: `https://ropsten.infura.io/v3/${process.env.INFURA_ROPSTEN_API_KEY}`,
            accounts
        },
}
}