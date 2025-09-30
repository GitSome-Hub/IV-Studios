in child resources fxmanifest.lua:

dependency 'ivs\_core'

shared\_scripts { '@ivs\_core/shared/api.lua' } -- for typings/signatures only



in child scripts (server): lua

exports\['ivs\_core']:IVS\_RegisterScript('ivs\_example', { version = '0.1.0' })

local fw = exports\['ivs\_core']:IVS\_GetFramework()

local ply = exports\['ivs\_core']:IVS\_GetPlayer(source)



In child scripts (client): lua

exports\['ivs\_core']:IVS\_Notify('Hello from child!', 'success')

local keys = exports\['ivs\_core']:IVS\_GetKeybinds()



Escrow Asset Protection — best-practice checklist



1\. Keep configs editable



Use escrow\_ignore for:



* config.lua, locales/\*, optional README.md or docs/\*
* Everything else stays encrypted when you upload to Keymaster.



2\. No hardcoded secrets in editable files



* If you implement license checks, keep the logic server-side (encrypted).
* Only expose a License.Key string and Endpoint in config.lua.



3\. Stable, documented exports



* Treat the functions in shared/api.lua as your public contract.
* Avoid breaking changes; if you must, bump major version.



4\. Guard optional dependencies



* Detect ox\_lib/qb-core/es\_extended at runtime (already implemented).



5\. Start order

* Have children declare dependency 'ivs\_core'.
* If you rely on ox\_lib UI, either require it or toggle via Config.



6\. Ship a minimal, working demo

* A tiny child resource that calls IVS\_Notify and logs a player join proves setup works for customers.



