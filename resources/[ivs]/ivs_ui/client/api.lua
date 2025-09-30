local function send(msg) SendNUIMessage(msg) end

exports('IVSUI_Open', function(app, data)
  SetNuiFocus(true, true); send({ op='open', app=app, data=data })
end)

exports('IVSUI_Close', function()
  send({ op='close' }); SetNuiFocus(false, false)
end)

exports('IVSUI_Toast', function(text, kind)
  send({ op='toast', text=text, kind=kind or 'info' })
end)

exports('IVSUI_OpenConfirm', function(text, cbEvent)
  send({ op='confirm', text=text, cb=cbEvent })
end)
