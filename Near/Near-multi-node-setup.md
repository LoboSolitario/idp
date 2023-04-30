# Commands to setup the NEAR localnet on a machine.

```
curl https://nextcloud.in.tum.de/index.php/s/6rngkkJapdBNkkA/download/near.tar.gz --output near.tar.gz
tar -xvf near.tar.gz
USER_BASE_BIN=$(python3 -m site --user-base)/bin
export PATH="$USER_BASE_BIN:$PATH"
sudo apt-get install -y nodejs npm nginx jq
npm install -g -y near-cli
export NEAR_ENV=localnet
```

# Running NEAR on multiple machines

## Setup
1. On machine1 run the command below, which will generate the configurations:

```
./target/debug/neard --home ~/.near/localnet_multi localnet --shards 3 --v 2
```

This command has generated configuration for 3 shards and 2 validators (in directories ~/.near/localnet_multi/node0 and ~/.near/localnet_multi/node1).

2. Copy the contents of node1 directory to the machine2 in the path : /.near/localnet_multi/node1
Also write down the node0's node_key (it is probably: "ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX")

## Running
1. On machine1:
```
./target/debug/neard --home ~/.near/localnet_multi/node0 run --network-addr 0.0.0.0:24567 --rpc-addr 0.0.0.0:3030
```

2. On machine2:
```
./target/debug/neard --home ~/.near/localnet_multi/node1 run --boot-nodes ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX@172.16.111.12:24567 --network-addr 0.0.0.0:24567 --rpc-addr 0.0.0.0:3030
```
The boot node address should be the IP of the machine1 + port of the network.

And if everything goes well, the nodes should communicate and start producing blocks.

## Troubleshooting
1. The debug mode is enabled by default, so you should be able to see what's going on by going to http://machine1:RPC_ADDR_PORT/debug

2. If node keeps saying "waiting for peers"
See if you can see the machine1's debug page from machine2. (if not - there might be a firewall blocking the connection).

3. Resetting the state
Simply stop both nodes, and remove the data subdirectory (~/.near/localnet_multi/node0/data and ~/.near/localnet_multi/node1/data).

Then after restart, the nodes will start the blockchain from scratch.
