local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

vSERVER = Tunnel.getInterface(GetCurrentResourceName())
vCLIENT = {}
Tunnel.bindInterface(GetCurrentResourceName(),vCLIENT)

function addTargetZones()
    CreateThread(function ()
        for id,data in pairs(config.locations) do
            exports["target"]:AddCircleZone("company:"..data.companyType..":"..id,data.coords,1.5,{
                name = "company:"..data.companyType..":"..id
            },{
                shop = id,
                distance = 1.5,
                options = vSERVER.generateOptions(id)
            })
        end
    end)
end

addTargetZones()


function removeTargetZones()
    CreateThread(function ()
        for id,data in pairs(config.locations) do
            exports["target"]:RemCircleZone("company:"..data.companyType..":"..id)
        end
    end)
end

RegisterNetEvent("companies:buy")
AddEventHandler("companies:buy",function(companyId)
    vSERVER.buyCompany(companyId[1])
end)

RegisterNetEvent("companies:upgrade")
AddEventHandler("companies:upgrade",function(companyId)
    vSERVER.upgradeCompany(companyId[1])
end)

RegisterNetEvent("companies:receiveAcumulatedPayments")
AddEventHandler("companies:receiveAcumulatedPayments",function(companyId)
    vSERVER.receiveAcumulatedPayments(companyId[1])
end)

RegisterNetEvent("companies:sell")
AddEventHandler("companies:sell",function(companyId)
    vSERVER.sellCompany(companyId[1])
end)

RegisterNetEvent("companies:renew")
AddEventHandler("companies:renew",function(companyId)
    vSERVER.renewCompany(companyId[1])
end)

RegisterNetEvent("companies:balance")
AddEventHandler("companies:balance",function(companyId)
    vSERVER.balanceCompany(companyId[1])
end)

RegisterNetEvent("companies:updateZones")
AddEventHandler("companies:updateZones",function()
    removeTargetZones()
    addTargetZones()
end)