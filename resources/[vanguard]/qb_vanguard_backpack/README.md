# Dependencies
 - ox_inventory
 - ox_lib
 - ox_target

## Extra Information
Item to add to `ox_inventory/data/items.lua`
```
	['backpack_level_1'] = {
		label = 'Backpack [Nv.I]',
		weight = 220,
		stack = false,
		consume = 0,
		client = {
			export = 'qb_vanguard_backpack.openBackpack1'
		}
	},

	['backpack_level_2'] = {
		label = 'Backpack [Nv.II]',
		weight = 250,
		stack = false,
		consume = 0,
		client = {
			export = 'qb_vanguard_backpack.openBackpack2'
		}
	},
	
	['backpack_level_3'] = {
		label = 'Backpack [Nv.III]',
		weight = 300,
		stack = false,
		consume = 0,
		client = {
			export = 'qb_vanguard_backpack.openBackpack3'
		}
	},
```

## Insert into your database
```
CREATE TABLE `user_backpacks` (
  `id` int(11) NOT NULL,
  `backpackID` varchar(50) NOT NULL,
  `pin` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;


ALTER TABLE `user_backpacks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `backpackID` (`backpackID`);


ALTER TABLE `user_backpacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;
```

