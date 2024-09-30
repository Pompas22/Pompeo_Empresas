local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

vCLIENT = Tunnel.getInterface(GetCurrentResourceName())

vSERVER = {}
Tunnel.bindInterface(GetCurrentResourceName(),vSERVER)

function vSERVER.generateOptions(companyId)
    local source = source
    local user_id = vRP.getUserId(source)
    local options = {}
    if user_id then
        local companiesData = vRP.getSrvdata("companies")
        if companiesData[tostring(companyId)] and companiesData[tostring(companyId)].ownerId == user_id then
            options = {
				{
					event = "companies:upgrade",
					label = "Aprimorar empresa",
					tunnel = "client"
				},
				{
					event = "companies:receiveAcumulatedPayments",
					label = "Receber pagamento",
					tunnel = "client"
				},
				{
					event = "companies:sell",
					label = "Vender empresa",
					tunnel = "client"
				},
                {
                    event = "companies:renew",
					label = "Renovar empresa",
					tunnel = "client"
                }
            }
        else
            options = {
                {
					event = "companies:buy",
					label = "Comprar empresa",
					tunnel = "client"
				},
            }
        end
        return options
    end
end


function vSERVER.buyCompany(companyId)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local companiesData = vRP.getSrvdata("companies")
        if companiesData[tostring(companyId)] and companiesData[tostring(companyId)].ownerId then
            TriggerClientEvent("Notify",source,'vermelho',"Empresa ja tem dono!",5000)
            return
        end
        local companyType = config.locations[companyId].companyType
        local companyData = config.companies[companyType]
        if not vRP.request(source,"Tem certeza de que deseja comprar essa empresa por $"..parseFormat(companyData.buyValue).." ?") then return end
        if vRP.paymentFull(user_id,companyData.buyValue) then
            companiesData[tostring(companyId)] = {
                expire = (os.time() + (86400 * companyData.duration)),
                companyType = companyType,
                level = 0,
                ownerId = user_id,
                amountSaved = 0
            }
            vRP.setSrvdata("companies",companiesData)
            TriggerClientEvent("companies:updateZones",-1)
            TriggerClientEvent("Notify",source,'verde',"Empresa comprada com sucesso!",5000)
        else
            TriggerClientEvent("Notify",source,'vermelho',"Saldo indisponivel!",5000)
        end
    end
end

function vSERVER.upgradeCompany(companyId)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local companiesData = vRP.getSrvdata("companies")
        if companiesData[tostring(companyId)] and companiesData[tostring(companyId)].ownerId == user_id then
            local companyData = config.companies[companiesData[tostring(companyId)].companyType]
            if (companiesData[tostring(companyId)].level + 1) > #companyData.levels then
                TriggerClientEvent("Notify",source,'vermelho',"level maximo atingido!",5000)
                return false
            end
            if not vRP.request(source,"Tem certeza de que deseja aprimorar essa empresa por $"..parseFormat(companyData.levels[companiesData[tostring(companyId)].level].upgradeValue).." ?") then return end
            if vRP.paymentFull(user_id,companyData.levels[companiesData[tostring(companyId)].level].upgradeValue) then
                companiesData[tostring(companyId)].level = companiesData[tostring(companyId)].level + 1
                vRP.setSrvdata("companies",companiesData)
                TriggerClientEvent("Notify",source,'verde',"Sua empresa subiu para o nivel "..companiesData[tostring(companyId)].level.." !",5000)
            end
        end
    end
end

function vSERVER.receiveAcumulatedPayments(companyId)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local companiesData = vRP.getSrvdata("companies")
        if companiesData[tostring(companyId)] and companiesData[tostring(companyId)].ownerId == user_id then
            if companiesData[tostring(companyId)].amountSaved > 0 then
                vRP.addBank(user_id,companiesData[tostring(companyId)].amountSaved,"Private")
                TriggerClientEvent("Notify",source,'verde',"Você sacou $"..companiesData[tostring(companyId)].amountSaved.." !",5000)
                companiesData[tostring(companyId)].amountSaved = 0
                vRP.setSrvdata("companies",companiesData)
            else
                TriggerClientEvent("Notify",source,'vermelho',"Sem dinheiro disponivel para saque!",5000)
            end
        end
    end
end

function vSERVER.sellCompany(companyId)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local companiesData = vRP.getSrvdata("companies")
        if companiesData[tostring(companyId)] and companiesData[tostring(companyId)].ownerId == user_id then
            local companyData = config.companies[companiesData[tostring(companyId)].companyType]
            if vRP.request(source,"Tem certeza de que deseja vender sua empresa por $"..parseFormat(companyData.levels[companiesData[tostring(companyId)].level].sellValue).." ?") then
                vRP.addBank(user_id,companyData.levels[companiesData[tostring(companyId)].level].sellValue,"Private")
                companiesData[tostring(companyId)] = nil
                vRP.setSrvdata("companies",companiesData)
                TriggerClientEvent("companies:updateZones",-1)
                TriggerClientEvent("Notify",source,'verde',"Empresa vendida com sucesso!",5000)
            end
        end
    end
end

function vSERVER.renewCompany(companyId)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local companiesData = vRP.getSrvdata("companies")
        if companiesData[tostring(companyId)] and companiesData[tostring(companyId)].ownerId == user_id then
            local companyData = config.companies[companiesData[tostring(companyId)].companyType]
            if vRP.request(source,"Tem certeza de que deseja renovar sua empresa por $"..parseFormat(companyData.levels[companiesData[tostring(companyId)].level].taxToRenew).." ?") and vRP.paymentFull(user_id,companyData.levels[companiesData[tostring(companyId)].level].taxToRenew) then
                companiesData[tostring(companyId)].expire = (os.time() + (86400 * companyData.duration)),
                vRP.setSrvdata("companies",companiesData)
                TriggerClientEvent("Notify",source,'verde',"Empresa renovada por mais "..companyData.duration.." dias!",5000)
            end
        end
    end
end

CreateThread(function()
    while true do
        Wait(60*60*1000)
        local companiesData = vRP.getSrvdata("companies")
        if json.encode(companiesData) ~= '[]' then
            for companyId,companyData in pairs(companiesData) do
                local configCompanyData = config.companies[companyData.companyType]
                local hourPayment = math.random(configCompanyData.levels[companyData.level].paymentPerHour.min,configCompanyData.levels[companyData.level].paymentPerHour.max)
                companiesData[companyId].amountSaved = companiesData[companyId].amountSaved + hourPayment
                local userSource = vRP.getUserSource(companyData.ownerId)
                if userSource then
                    TriggerClientEvent("Notify",userSource,'verde',"Você recebeu $"..hourPayment..' pela sua empresa!',5000)
                end
            end
            vRP.setSrvdata("companies",companiesData)
        end
    end
end)

AddEventHandler("playerConnect",function(user_id,source)
    local companiesData = vRP.getSrvdata("companies")
    if json.encode(companiesData) ~= '[]' then
        for companyId,companyData in pairs(companiesData) do
            if os.time() >= companyData.expire then
                TriggerClientEvent("Notify",source,'amarelo',"Sua empresa "..companyData.companyType..' expirou!',20000)
                companiesData[companyId] = nil
                vRP.setSrvdata("companies",companiesData)
            end
        end
    end
end)