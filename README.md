# Panacloud API Smart Contracts
Panacloud.org will offer 10 million Panacloud Tokens (ERC 20) through a crowd sale at a specified price i.e. 1 DAI. The maximum API tokens that can be minted will be 1 Billion Panacloud Tokens. This Panacloud Token will give the right to the owner to participate in Panacloud Governance including which APIs project proposals to accept for funding. The Panacloud Token holder will also use these Panacloud Tokens to participate in Panacloud DAO and select the API Projects for funding. He/she will also use it to fund API projects.

The life cycle of the API will start when someone proposes an idea to build an API. The person who will create this API Project Proposal will receive an API Project Idea Proposal NFT in his wallet when the Panacloud DAO proves the proposal. This API Project Idea Proposal NFT will give him ownership of the idea and also 1% of Revenue sharing rights when and if the project is built and subscribed.

The API developers will review the API Project Idea Proposal and if interested will submit a bid for development to the Panacloud DAO. The Panacloud DAO members will review the development bids and select an appropriate development bid. Each development bid will include the estimated time and the funding required to build the API project. The profile of the developer will also be submitted. Panacloud DAO will select the appropriate bid.

The ownership of each API project will be represented by an API Ownership NFT. The developer of the API will be the owner of the API Ownership NFT. As soon as the API developer creates an API project on the Panacloud Portal an API Ownership NFT will be created and transferred to the API Developer Wallet. Once the APIs funding of the project is started the API Developer will hand this API Ownership NFT to the API DOA in exchange for the API DAO Tokens. Therefore, API DAO will keep locked the API Project Idea Proposal NFT and the API Ownership NFT till API DAO exists.

As soon as the Development Bid is selected and approved for development by the Panacloud, an API DAO will be created. The first member of the API DAO will be the API Project Idea Proposal NFT holder, he/she will transfer the NFT to the API DAO in exchange for API DAO Tokens. If the project requires funding a crowd sales for 5% to 10% of the API DOA tokens will be held to raise the required funding. The investors will make an investment by giving the Panacloud token and will receive API DAO Token. Panacloud will also receive 5% API DAO Tokens for maintaining and developing the platform. The rest of the API DAO tokens will be held by the API developer in the initial phase. To sum up, API DAO Tokens will be held by API Idea Proposer (1%), API Project Investors (10%), Panacloud (5%), and API Developers (74%) in the initial phase. Every API DAO Token holder will receive revenue share when subscription payments are made through a payment splitter smart contract. The API Subscribers will make payment in DAI to the Payment Splitter contract and will receive API DOA Tokens at some predetermined rate. For example, for every 1,000 DAI paid as a subscription fee the API will receive one API DAO Token. The API subscribers/users receive API DAO tokens in exchange for the usage-based subscription fees. The more they use the API the more they become the owners of the API and participate in management and revenue sharing. Thus becoming the ultimate example of the ownership economy, API users become owners by consuming an API. This will act as a perfect incentive for users to join the platform and subscribe and use the APIs. The user will also be incentivized to recommend the API to other users because he/she is now also the owner. However, this will dilute the ownership rights of the previous API DAO Token holders percentage-wise, but they will not mind it too much because it is increasing the size of the pie and accelerating the adoption of the APIs. In the long run API, users will have a major say in the management and governance of the APIs.


The smart contracts in the system:

1. Panacloud Token

[OpenZeppelin ERC 20](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20)

2. Panacloud DAO

[OpenZeppelin Contracts on-chain governance](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/governance)

3. API Project Idea Proposal NFT 

[OpenZeppelin ERC 721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721)

[OpenZeppelin ERC 1155](https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155)

4. API Ownership NFT

[OpenZeppelin ERC 721](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721)

[OpenZeppelin ERC 1155](https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155)

5. API DAO
6. 
[OpenZeppelin Contracts on-chain governance](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/governance)

7. API Token

[OpenZeppelin ERC 20](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20)

8. Payment Splitter for Subscription Revenue Sharing

[OpenZeppelin PaymentSplitter](https://docs.openzeppelin.com/contracts/4.x/api/finance)






### DAO Resources:

[Example for a full Dao smart contracts](https://forum.openzeppelin.com/t/example-for-a-full-dao-smart-contracts/10462)

[TributeDAO is a new modular, low cost DAO framework](https://github.com/openlawteam/tribute-contracts)

[The Standard DAO Framework, including Whitepaper](https://github.com/blockchainsllc/DAO)
