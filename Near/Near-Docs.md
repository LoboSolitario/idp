# Near Blockchain

Near is a decentralized blockchain platform that allows developers to build decentralized applications (dApps). It aims to solve the issues of scalability and usability that many other blockchain platforms face. Near uses a consensus mechanism called *Doomslug* to secure its network and validate transactions and a sharding technique called *Nightshade* to help it scale. An advantage of Near is its ability to support interoperability between different blockchains using Rainbow bridge. This means that developers can build dApps that can easily interact with other blockchain networks, expanding the functionality and potential use cases of Near.

## Aurora and Rainbow Bridge

NEAR offers cross-chain interoperability through Aurora, an Ethereum Virtual Machine (EVM) built on NEAR. It provides a solution for developers to deploy their apps on an Ethereum-compatible platform, with low transaction costs for their users. Developers can deploy applications written in solidity which will use the native Aurora (AUR) token for gas fees.

Rainbow Bridge is a permissionless bridge that allows assets to be transferred between chains, such as NEAR, Aurora, and Ethereum. It uses Relayers, which are intermediaries, listening for events on one chain and submitting the necessary data to the other chain and Connectors, which facilitate various functions like token transfers, cross-chain contract calls, and syncing data between networks.

# Doomslug

Doomslug is a block production mechanism used in the NEAR Protocol that aims to achieve fast block production and finality. It achieves a block production time of ~1 block/second. Validators in the NEAR Protocol are selected based on the number of NEAR tokens they have staked. Below are the steps describing how Doomslug works:

1. Block Proposal: Validators in the NEAR Protocol take turns proposing new blocks in a round-robin fashion. When it's a validator's turn to propose a block, they gather any pending transactions, create a block, and include the hash of the last finalized block as its parent. The proposed block is then broadcasted to the network.
2. Block Endorsement: Once a validator receives a block proposal, they check its validity. If the block is valid and extends the current chain, the validator creates an "endorsement" message for the block. This message contains the hash of the proposed block and is signed by the validator. The endorsement is then broadcasted to the network.
3. Block Confirmation: When a validator receives more than 50% of the total stake-weighted endorsements, they consider the block "confirmed." A confirmed block is deemed irreversible by Doomslug as long as no other conflicting block at the same height has also received more than 50% of stake-weighted endorsements. Validators continue to listen for other endorsements for the same block to strengthen its finality.
4. Block Finalization: To finalize a block, a validator waits until they have seen more than 66% of the total stake-weighted endorsements for the block. Once a block reaches this threshold, it is considered "finalized" under the Doomslug mechanism. Finalized blocks can no longer be reverted or replaced.
5. Height Notification: Validators broadcast height notification messages to indicate they've received a block and advanced their local chain height. These messages help maintain synchronization across the network and can trigger the next block proposal.
6. Handling Conflicts: In case two or more conflicting blocks receive more than 50% of stake-weighted endorsements, Doomslug falls back to the underlying consensus mechanism to resolve the conflict and finalize a single block.

# Nightshade

Nightshade is the name given to the sharding mechanism used by Near protocol to achieve scalability. It combines state and transaction sharding aspects and introduces a novel approach to address some common challenges with sharding, such as cross-shard communication and data consistency. Here are the steps explaining how sharding works in Near:

1. Single State Sharded Chain: Instead of creating multiple independent shard chains, Nightshade uses a single blockchain where each shard maintains its own state. The blocks in the chain include the transactions and state changes for all shards. This design simplifies cross-shard communication, as all shards are already part of the same chain.
2. Splitting State and Transaction Processing: To achieve scalability, Nightshade divides the network state into multiple shards, where each shard is responsible for processing a subset of transactions. Validators in the network are also divided among these shards, and they process and validate transactions for their respective shard.
3. Chunk-Based Transactions: Transactions in Nightshade are grouped into chunks, each corresponding to a particular shard. Validators responsible for a shard process the chunk containing the transactions for that shard and generate a state change. They also produce a chunk header that summarizes the chunk's content and the resulting state changes.
4. Block Production and Validation: A block producer, chosen through a consensus mechanism, collects chunk headers from all shards and assembles them into a new block. The new block is then propagated across the network, and validators for each shard validate the corresponding chunk header and apply the state changes locally.
5. Cross-Shard Communication: Nightshade's design simplifies cross-shard communication by including all shard states within the same chain. A transaction involving multiple shards is divided into atomic sub-transactions called receipts. Receipts are forwarded to the destination shard, and processed, and the results are sent back to the originating shard, all within the same block. This approach reduces latency and complexity in cross-shard transactions.
6. Data Availability and Fraud Proofs: To ensure data availability and prevent malicious behavior, Nightshade uses erasure coding to create redundant data that can be used to reconstruct a chunk's content. Validators can challenge and verify the correctness of a chunk header using fraud proofs, ensuring that invalid state changes are rejected and the network remains secure.

### Sharding in Tesbed

The current Near mainnet has 4 shards and the roadmap is to gradually increase it to 100 shards in 2023 and then implement dynamic sharding in the next step. So, we will be using 4 shards and validators

### Beacon Chain vs Near Sharding

Ethereum recently moved from Proof-of-Work to a Proof-of-Stake consensus algorithm and the Beacon chain is the backbone of this transition, driving this change. It facilitates sharding which will help improve Ethereum’s scalability, which is one of its main drawbacks.

Ethereum shards a single blockchain into several generally independent “shard chains”, whereas NEAR shards within each block and maintains a single blockchain. Since Ethereum’s Beacon chain needs to confirm the cross-shard transactions, it has a more significant block finality time of ~17 seconds compared to Near’s ~1 second.

![Screenshot 2023-03-29 at 7.14.13 AM.png](Near%20d056532a2afa4c52a9917721412c1040/Screenshot_2023-03-29_at_7.14.13_AM.png)

# Observations during Local Deployment

- We have Indexer, Archival, Validator and RPC nodes.
- If there are just 2 validators and we bring down one of them , the blockchain network crashes because the stake decreases to 50% (Read more).
- Blocks are produced 1/second.
- Validators produce blocks and chunks.
- An epoch is a fixed period of time during which a set of validators are assigned to produce and validate blocks. It is currently 12 hours.
- Almost every other block on the mainnet is empty.
- We can check details about the stakers at [near-staking.com](http://near-staking.com/)
- In Near, blocks contains chunks. Every chunk has same property of a block. (Read More)
- Validators will only be rewarded if they produce at least 90% of their expected blocks production. (eg - if they go offline). Higher the stake, higher they are expected to produce blocks.
- 3.2 million Near token needs to be staked for a node to be a validator.
- During an epoch, each validator is assigned to produce a chunk or a block.
- Most of the blocks are empty because there are not enough transactions. But this is done to prove that validators did their job of validating and hence, not rewarded. Validators have to produce blocks in their turn.
- Accounts - Only test.near can register singh.test.near. But the parent account has not control over the child accounts.

## Sharding

- There are 2 common techniques blockchains implement to improve throughput -
    - Delegate all the computation to a small set of powerful nodes. (eg - Algorand, Solana)
    - Each node in the network only do a subset of the total amount of work. This is called Sharding (eg - Ethereum, Near, Ziliqa).
- Most common problem with sharding - let’s say if there are X validators in a chain and chain decides to hard fork into a shared chain of 10 sub-chains, then only 5.1% of the nodes need to be malicious in order to damage the blockchain (51%/10). This can be avoided if the validators are randomly assigned to shards at the beginning. Chance of getting multiple adversaries in the same shard will be negligible.
- **Quadratic Sharding** - This is the concept of multiplicative effect of improvement in computation of the nodes that leads to quadratic improvement in the throughput of the overall network.
    - **More Details**
        
        > Beacon chain has to do some bookkeeping computation, such as assigning validators to shards, or snapshotting shard chain blocks, that is proportional to the number of shards in the system. Since the Beacon chain is itself a single blockchain, with computation bounded by the computational capabilities of nodes operating it, the number of shards is naturally limited. If the nodes operating the network, including the nodes in the Beacon chain, become four times faster, then each shard will be able to process four times more transactions, and the Beacon chain will be able to maintain 4 times more shards. The throughput across the system will increase by the factor of 4 × 4 = 16 — thus the name quadratic sharding.
        > 
- When we talk about sharding, we can think of it in terms of storage or compute power. Storage is not a big issue as storage is easier and cheaper to expand than processing/computing power. Sharding of processing (State Sharding) is an easier problem because each node has the entire state, meaning that contracts can freely invoke other contracts and read any data from the blockchain.
    - **More Details**
        
        > Under State Sharding the nodes in each shard are building their own blockchain that contains transactions that affect only the local part of the global state that is assigned to that shard. Therefore, the validators in the shard only need to store their local part of the global state and only execute, and as such only relay, transactions that affect their part of the state. This partition linearly reduces the requirement on all compute power, storage, and network bandwidth, but introduces new problems, such as data availability and cross-shard transactions. Transactions may be completely ignored or partially applied due to forks.
        > 
        
        ![Screenshot 2023-04-26 at 7.11.21 PM.png](Near%20d056532a2afa4c52a9917721412c1040/Screenshot_2023-04-26_at_7.11.21_PM.png)
        
- Some malicious activities that can be employed by adversaries are
    - Malicious forks (Can be solved by adding a cross-link in the beacon chain of the latest shard chunk)
    - Approving invalid blocks i.e, an adversary can create an invalid block and add more on top of it. (many techniques to counter this - next points)
- Some of the remedial techniques that can be employed (but don’t fully solve the problem) to execute cross-shard transactions without the above-discussed problems.
    - Arrange shards into an undirected graph in which each shard is connected to several other shards, and only allow cross-shard transactions between neighboring shards. In this design a validator in each shard is expected to validate both all the blocks in their shard as well as all the blocks in all the neighboring shards.
        - **Issue** - Problem with this is if two adjoining shards are malicious, it still leads to adversary able to execute invalid transaction.
            
            ![Screenshot 2023-04-27 at 12.51.03 AM.png](Near%20d056532a2afa4c52a9917721412c1040/Screenshot_2023-04-27_at_12.51.03_AM.png)
            
    - **Fisherman:** The idea behind the first approach is the following: whenever a block header is communicated between chains for any purpose (such as cross-linking to the beacon chain, or a cross-shard transaction), there’s a period of time during which any honest validator can provide a proof that the block is invalid.
        - **Issue:** Introducing such a period would significantly slow down the cross-shard transactions and make them vulnerable to spamming of challenges.
- For data availability, Near uses the same approach as Polkadot uses - **erasure code.** In this approach, a portion of the data block is distributed to the validators from which the whole block/chunk can be reconstructed.
- **Receipts**: Cross-shard transactions need to be consecutively executed in each shard separately. The full transaction is sent to the first shard affected, and once the transaction is included in the chunk for such shard, and is applied after the chunk is included in a block, it generates a so called receipt transaction, that is routed to the next shard in which the transaction need to be executed.

## Accounts

- Fields - yoctonear (10^-18 Near token), locked amount (for staking), contract, storage(of contract), access keys (full-permission/function-call permissions)
- Every account belongs to one shard. If A (shard 1)→B (shard 2) 10 tokens, shard 2 is not aware of account A in shard 1, hence the receipt transactions are transferred cross shard are used. When transaction is signed by A in shard 1 and executed, it generates a receipt, which contains the amount A transferred, B gets the 10 tokens.
