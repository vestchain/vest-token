The following steps must be taken for the example script to work.

0. Create wallet
0. Create account for vestio.token
0. Create account for scott
0. Create account for exchange
0. Set token contract on vestio.token
0. Create VEST token
0. Issue initial tokens to scott

**Note**:
Deleting the `transactions.txt` file will prevent replay from working.


### Create wallet
`clvest wallet create`

### Create account steps
`clvest create key`

`clvest create key`

`clvest wallet import  --private-key <private key from step 1>`

`clvest wallet import  --private-key <private key from step 2>`

`clvest create account vestio <account_name> <public key from step 1> <public key from step 2>`

### Set contract steps
`clvest set contract vestio.token /contracts/vestio.token -p vestio.token@active`

### Create VEST token steps
`clvest push action vestio.token create '{"issuer": "vestio.token", "maximum_supply": "100000.0000 VEST", "can_freeze": 1, "can_recall": 1, "can_whitelist": 1}' -p vestio.token@active`

### Issue token steps
`clvest push action vestio.token issue '{"to": "scott", "quantity": "900.0000 VEST", "memo": "testing"}' -p vestio.token@active`
