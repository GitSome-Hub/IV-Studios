# Dependencies
- Vanguard_Bridge 
- ox_lib 
- ox_target
- ox_inventory

# Items to add to your inventory system.

```lua

	['inspection_done'] = {
		label = 'Inspection Document',
	},

	['inspection_failed'] = {
		label = 'Inspection Document',
	},
	
```

# Add to your SQL database 

```lua

-- Create the vehicle_inspections table
CREATE TABLE IF NOT EXISTS vehicle_inspections (
    id INT AUTO_INCREMENT PRIMARY KEY,    -- Unique identifier for each inspection
    plate VARCHAR(20) NOT NULL,           -- Vehicle plate number
    model VARCHAR(100) NOT NULL,          -- Vehicle model
    inspection_type ENUM('done', 'failed', 'pending') NOT NULL, -- Inspection type (done, failed, or pending)
    days INT NOT NULL DEFAULT 0,          -- Number of days remaining for the inspection
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of when the inspection record was created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Timestamp of the last update
);

```
