RegisterNetEvent('ivs:ping', function(senderId)
  local src = source
  if type(senderId) ~= 'number' or senderId ~= src then return end
  local ts = os.time()

  -- example DB write
  MySQL.insert('INSERT INTO ivs_pings (identifier, ts) VALUES (?, ?)', { GetPlayerIdentifier(src, 0) or 'unknown', ts })

  TriggerClientEvent('ivs:pong', src, ts)
end)
