CreateThread(function()
  local ok = MySQL.scalar.await('SELECT 1')
  print(ok and '[ivs_dbtest] DB connection OK' or '[ivs_dbtest] DB connection FAILED')

  MySQL.insert.await('INSERT INTO ivs_smoke (note, ts) VALUES (?, ?)', { 'hello from oxmysql', os.time() })
  local row = MySQL.single.await('SELECT id, note, ts FROM ivs_smoke ORDER BY id DESC LIMIT 1')
  if row then print(('[ivs_dbtest] latest: #%s %s %s'):format(row.id, row.note, row.ts)) end
end)
