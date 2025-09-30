# Dependencies
 - ox_inventory
 - ox_lib
 - ox_target

## Extra Information
Item to add to `ox_inventory/data/items.lua`
```
    ['wallet_basic'] = {
        label = 'Basic Wallet',
        weight = 100,
        stack = false,
        consume = 0,
        client = {
            export = 'vanguard_wallet.openWalletBasic'
        }
    },
    
    ['wallet_premium'] = {
        label = 'Premium Wallet',
        weight = 150,
        stack = false,
        consume = 0,
        client = {
            export = 'vanguard_wallet.openWalletPremium'
        }
    },
```
