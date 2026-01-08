
-- in this code there is some trash code and naming inaccuracies, because i had tons of ideas to implement 
-- and not all of them could be implemented. im to lazy to remove that code or change the names -_-
-- whatever, im the only one working on this code, so who cares :-)
-- in projects with more people i will be much more careful with naming accuracy, code quality, documentation and other stuff, but I want to finish this mod so badly -_-
-- so for those reading this comment who want to see what i did, good luck :)

-- btw, this is my first time using lua, so if you see something strange here, is bcs i used ai to help me get started with lua and isaac api :-|

-- Luxuz

local mod = RegisterMod("[rep,rep+] Celeste Mod", 1)
local game = Game()

local PASSIVE_ID = Isaac.GetItemIdByName("Celeste!")
local ACTIVE_ID = Isaac.GetItemIdByName("Dash!")
local TRINKET_ID = Isaac.GetTrinketIdByName("Twister")
local ACTIVE2_ID = Isaac.GetItemIdByName("Stop!")

local ATTACK_ANM_PATH = "gfx/attack.anm2"
local ATTACK_ANIM_NAME = "Charged"
local ATTACK_ANIM_DUR = 36

local ATTACK_ANIM_BASE_DIAMETER = 1.91

local ATTACK_ANIM_OFFSET_Y = -10

local WAVE_RADIUS = 115
local HALF_HEART_ON_KILL_CHANCE = 0.6

local RANGE_CURVE_C = 30
local RANGE_MAX_EXTRA = 0.6

local DASH_SPEED = 15
local DASH_DURATION = 12
local AUTO_DASH_SPEED = 13
local AUTO_DASH_DURATION = 5.50
local AUTO_DASH_INTERVAL = 240
local CONTACT_RADIUS = 30
local WEAK_MULTIPLIER = 2
local TRINKET_MULTIPLIER = 2.5
local POST_INVULN_AFTER = 40
local WAVE_INTERVAL_FRAMES = 240
local WAVE_ACTIVE_FRAMES = 30
local REGEN_INTERVAL_FRAMES = 360
local REGEN_CAP_HALFHEARTS = 6
local POST_DASH_INERTIA_SPEED = 5
local POST_DASH_INERTIA_FRAMES = 12

local PASSIVE_TEARS_MULT = 0.65
local PASSIVE_DAMAGE_MULT = 2.0

local rotationIndex = 0
-- local spriterotation = 0

-- EID Descriptions
if EID then
    local dashDesc = {
        ["cz_cz"] =
        "Vyskakuje ve směru, kam míříte#Způsobí 2× vášho poškození nepřátelům zasaženým dash#Během dash jste neporazitelní",
        ["de"]    =
        "Stürzt in Schussrichtung vor#Verursacht 2× deinen Schaden an Gegnern, die vom Dash getroffen werden#Während des Dashs unverwundbar",
        ["en_us"] =
        "Dashes in the direction you're shooting#Deals 2× your damage to enemies hit by the dash (2.5× with Twister)#Invulnerable while dashing",
        ["es"]    =
        "Dashea en la dirección en la que apuntas#Inflige 2× tu daño a enemigos alcanzados por el dash (2.5× con Twister)#Invulnerable durante el dash",
        ["fr"]    =
        "Charge dans la direction de tir#Inflige 2× vos dégâts aux ennemis touchés par la charge (2.5× avec Twister)#Invulnérable pendant la charge",
        ["it"]    =
        "Scatta nella direzione di fuoco#Infligge 2× i tuoi danni ai nemici colpiti dallo scatto (2.5× con Twister)#Invulnerabile durante lo scatto",
        ["ja_jp"] = "攻撃方向に突進する#突進でヒットした敵に自身のダメージの2倍を与える（Twisterで2.5倍）#突進中は無敵",
        ["ko_kr"] = "공격 방향으로 돌진#돌진에 맞은 적에게 플레이어 데미지의 2배를 입힘(Twister 시 2.5배)#돌진 중 무적",
        ["ro_ro"] =
        "Se aruncă în direcția de tragere#Aplică 2× daunele tale inamicilor loviți de dash (2.5× cu Twister)#Invulnerabil în timpul dash-ului",
        ["ru"]    =
        "Рывок в направлении стрельбы#Наносит врагам, поражённым рывком, 2× вашего урона (2.5× с Twister)#Неуязвим во время рывка",
        ["uk_ua"] =
        "Ривок у напрямку стрільби#Завдає ворогам, ураженим ривком, у 2× вашого урону (2.5× з Twister)#Невразливий під час ривка",
        ["vi"]    = "Lao về hướng bắn#Gây 2× sát thương của bạn cho kẻ địch trúng dash (2.5× với Twister)#Vô hình khi dash",
        ["zh_cn"] = "朝射击方向冲刺#对被冲刺击中的敌人造成你伤害的2倍（携带 Twister 时为2.5倍）#冲刺时无敌"
    }

    local trinketDesc = {
        ["cz_cz"] = "↑ +0.15 Rychlost#Malý bonus ke statistice#Speciální synergie s Dash!/Celeste: zvyšuje poškození dashu z 2× → 2.5×",
        ["de"]    = "↑ +0.15 Geschwindigkeit#Kleiner Stat-Bonus#Synergie mit Dash!/Celeste: erhöht Dash-Schaden von 2× → 2,5×",
        ["en_us"] = "↑ +0.15 Speed#Minor stat bonus#Synergizes with Dash!/Celeste: increases dash damage 2× → 2.5×",
        ["es"]    = "↑ +0.15 Velocidad#Pequeño bonus de estadísticas#Sinergia con Dash!/Celeste: aumenta el daño del dash de 2× → 2.5×",
        ["fr"]    = "↑ +0.15 Vitesse#Petit bonus de statistiques#Synergie avec Dash!/Celeste : augmente les dégâts du dash de 2× → 2.5×",
        ["it"]    = "↑ +0.15 Velocità#Piccolo bonus alle statistiche#Sinergia con Dash!/Celeste: aumenta il danno dello scatto da 2× → 2.5×",
        ["ja_jp"] = "↑ 移動速度 +0.15#小さなステータスボーナス#Dash!/Celesteとのシナジー: ダッシュダメージ 2× → 2.5×",
        ["ko_kr"] = "↑ 속도 +0.15#작은 스탯 보너스#Dash!/Celeste 시너지: 대시 데미지 2× → 2.5×",
        ["ro_ro"] = "↑ +0.15 Viteză#Mic bonus la statistici#Sinergie cu Dash!/Celeste: mărește daunele dash de la 2× → 2.5×",
        ["ru"]    = "↑ +0.15 Скорость#Небольшой бонус к характеристикам#Синергия с Dash!/Celeste: увеличивает урон рывка 2× → 2.5×",
        ["uk_ua"] = "↑ +0.15 Швидкість#Невеликий бонус до характеристик#Синергія з Dash!/Celeste: збільшує урон ривка 2× → 2.5×",
        ["vi"]    = "↑ +0.15 Tốc độ#Tăng chỉ số nhẹ#Tương tác với Dash!/Celeste: tăng sát thương dash từ 2× → 2.5×",
        ["zh_cn"] = "↑ +0.15 移动速度#小幅属性提升#与 Dash!/Celeste 联动：冲刺伤害 2× → 2.5×"
    }

    local passiveDesc = {
        ["cz_cz"] = "Poškození ×2.5, ↓ -1 Slzy, ↑ +0.25 Rychlost, Slzy mají svatou auru.#Každé 4 s vyvolá rázovou vlnu, která způsobí 2.5× vašeho poškození nepřátelům v okolí.#Občas obnoví půl srdce.#Pokud máte Dash!, použití Dash! okamžitě aktivuje vlnu a resetuje její cooldown.",
        ["de"]    = "Schaden ×2.5, ↓ -1 Tränen, ↑ +0.25 Geschwindigkeit, Tränen haben eine heilige Aura.#Alle 4 s erzeugt es eine Schockwelle, die Gegnern in der Nähe 2.5× deines Schadens zufügt.#Heilt gelegentlich ein halbes Herz.#Wenn du Dash! hast, löst die Benutzung von Dash! die Welle sofort aus und setzt deren Abklingzeit zurück.",
        ["en_us"] = "Damage ×2.5, ↓ -1 Tears, ↑ +0.25 Speed, Tears have a holy aura.#Every 4s emits a shockwave that deals 2.5× your damage to nearby enemies.#Occasionally regenerates half a heart.#If you have Dash!, using Dash! immediately triggers the wave and resets its cooldown.",
        ["es"]    = "Daño ×2.5, ↓ -1 Lágrimas, ↑ +0.25 Velocidad, Las lágrimas tienen un aura sagrada.#Cada 4 s emite una onda expansiva que inflige 2.5× tu daño a enemigos cercanos.#Regenera ocasionalmente medio corazón.#Si tienes Dash!, usar Dash! activa la onda inmediatamente y reinicia su cooldown.",
        ["fr"]    = "Dégâts ×2.5, ↓ -1 Larmes, ↑ +0.25 Vitesse, Les larmes ont une aura sacrée.#Toutes les 4 s émet une onde de choc infligeant 2.5× vos dégâts aux ennemis proches.#Régénère parfois un demi-cœur.#Si vous avez Dash!, l'utilisation de Dash! déclenche immédiatement l'onde et réinitialise son cooldown.",
        ["it"]    = "Danno ×2.5, ↓ -1 Lacrime, ↑ +0.25 Velocità, Le lacrime hanno un'aura sacra.#Ogni 4 s emette un'onda d'urto che infligge 2.5× il tuo danno ai nemici vicini.#Rigenera occasionalmente mezzo cuore.#Se hai Dash!, usare Dash! attiva immediatamente l'onda e resetta il suo cooldown.",
        ["ja_jp"] = "ダメージ ×2.5、↓ -1 涙、↑ +0.25 移動速度、涙は聖なるオーラを帯びる。#4秒ごとに衝撃波を放ち、近くの敵にあなたのダメージの2.5倍を与える。#時折ハーフハートを回復する。#Dash!を所持している場合、Dash!を使用すると衝撃波が即座に発動し、クールダウンがリセットされる。",
        ["ko_kr"] = "데미지 ×2.5, ↓ -1 눈물, ↑ +0.25 이동속도, 눈물에 성스러운 오라가 생김.#4초마다 주변에 충격파를 방출하여 근처 적에게 당신 데미지의 2.5배를 입힘.#가끔 반 하트를 회복함.#Dash!를 가지고 있다면 Dash! 사용 시 즉시 파동이 발동하고 재사용 대기시간이 초기화됨.",
        ["ro_ro"] = "Daune ×2.5, ↓ -1 Lacrimi, ↑ +0.25 Viteză, Lacrimile au o aură sacră.#La fiecare 4 s emite o undă de șoc care aplică 2.5× daunele tale inamicilor apropiați.#Uneori regenerează jumătate de inimă.#Dacă ai Dash!, folosirea Dash! activează imediat unda și resetează cooldown-ul.",
        ["ru"]    = "Урон ×2.5, ↓ -1 Слеза, ↑ +0.25 Скорость, Слезы обладают святой аурой.#Каждые 4 с испускает ударную волну, наносящую 2.5× вашего урона ближайшим врагам.#Иногда восстанавливает половину сердца.#Если у вас есть Dash!, использование Dash! мгновенно активирует волну и сбросит её перезарядку.",
        ["uk_ua"] = "Шкода ×2.5, ↓ -1 Сльоза, ↑ +0.25 Швидкість, Сльози мають святу ауру.#Кожні 4 с випромінює ударну хвилю, що завдає 2.5× вашого ушкодження ближнім ворогам.#Іноді відновлює половину серця.#Якщо у вас є Dash!, використання Dash! миттєво активує хвилю і скине її кулдаун.",
        ["vi"]    = "Sát thương ×2.5, ↓ -1 Lệ, ↑ +0.25 Tốc độ, Đạn có hào quang thánh.#Mỗi 4 s phát ra một làn sóng gây 2.5× sát thương của bạn lên kẻ địch gần đó.#Thỉnh thoảng hồi nửa trái tim.#Nếu bạn có Dash!, dùng Dash! sẽ kích hoạt làn sóng ngay lập tức và đặt lại thời gian hồi.",
        ["zh_cn"] = "伤害 ×2.5，↓ -1 眼泪，↑ +0.25 速度，眼泪带有圣光光环。#每4秒发出一次冲击波，对附近敌人造成你伤害的2.5倍。#有时会回复半颗心。#如果你拥有 Dash!，使用 Dash! 会立即触发冲击波并重置冷却。"
    }

    for lang, desc in pairs(dashDesc) do EID:addCollectible(ACTIVE_ID, desc, "Dash!", lang) end
    for lang, desc in pairs(trinketDesc) do EID:addTrinket(TRINKET_ID, desc, "Twister", lang) end
    for lang, desc in pairs(passiveDesc) do EID:addCollectible(PASSIVE_ID, desc, "Celeste!", lang) end
end

local function GetPlayerRange(player)
    if not player then return nil end
    local ok, val
    ok, val = pcall(function() return player.TearRange end)
    if ok and type(val) == "number" and val > 0 then return val end
    ok, val = pcall(function() return player.Range end)
    if ok and type(val) == "number" and val > 0 then return val end
    ok, val = pcall(function() return player:GetRange() end)
    if ok and type(val) == "number" and val > 0 then return val end
    return nil
end

local function RangeToWaveScale(range)
    if not range or type(range) ~= "number" then return 1.0 end
    local c = RANGE_CURVE_C
    local maxExtra = RANGE_MAX_EXTRA
    local extra = (range / (range + c)) * maxExtra
    return 1 + extra
end

-- wow code :-)
local function SpriteScaleForRadius(player, radius)
    return ATTACK_ANIM_BASE_DIAMETER
end

local function CalculateTears(fd, bonusTears)
    local cur = 30 / (fd + 1)
    return math.max((30 / (cur + bonusTears)) - 1, -0.99)
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    for i = 0, game:GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(i)
        if p:GetName() == "Madeline" then
            if not p:HasCollectible(ACTIVE_ID) then p:SetPocketActiveItem(ACTIVE_ID) end
            if not p:HasTrinket(TRINKET_ID) then p:AddTrinket(TRINKET_ID) end
        elseif p:GetName() == "Tainted Madeline" then
            if not p:HasCollectible(ACTIVE2_ID) then p:SetPocketActiveItem(ACTIVE2_ID) end
            if not p:HasTrinket(TRINKET_ID) then p:AddTrinket(TRINKET_ID) end
        end
    end
end)

function mod:OnEvaluateCache(player, cacheFlag)
    local d = player:GetData()
    d._TearBonus = d._TearBonus or 0
    if cacheFlag == CacheFlag.CACHE_SPEED and player:HasTrinket(TRINKET_ID) then
        player.MoveSpeed = player.MoveSpeed + 0.15
    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
    if d._TearBonus ~= 0 then
        player.MaxFireDelay = CalculateTears(player.MaxFireDelay, d._TearBonus)
    end
    if player:HasCollectible(PASSIVE_ID) then
        player.MaxFireDelay = math.max(1, player.MaxFireDelay / PASSIVE_TEARS_MULT)
    end
end

    if not player:HasCollectible(PASSIVE_ID) then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * PASSIVE_DAMAGE_MULT
    elseif cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.25
    elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
        player.TearFlags = player.TearFlags|TearFlags.TEAR_GLOW
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OnEvaluateCache)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE,
    function(_, p) if p:HasTrinket(TRINKET_ID) then p:EvaluateItems() end end)

local function StartCelesteWave(player, scaledRadius)
    if not player or not player:Exists() then return end
    local d = player:GetData()
    d._HorizonWaveTimer = WAVE_INTERVAL_FRAMES
    d._WaveActiveTimer = WAVE_ACTIVE_FRAMES
    d._CelesteAttackScaledRadius = scaledRadius
    d._CelesteWaveTotalFrames = WAVE_ACTIVE_FRAMES
    d._CelesteWaveLastRadius = 0
    d._CelesteWaveHit = {}

    if not d._CelesteAttackSprite then
        d._CelesteAttackSprite = Sprite()
        d._CelesteAttackSprite:Load(ATTACK_ANM_PATH, true)
    end

    local spriteScale = SpriteScaleForRadius(player, scaledRadius)
    d._CelesteAttackSpriteScale = spriteScale

    pcall(function()
        d._CelesteAttackSprite:Play(ATTACK_ANIM_NAME, true)
        pcall(function() d._CelesteAttackSprite.Scale = Vector(spriteScale, spriteScale) end)
    end)

    d._CelesteAttackPlaying = true
    d._CelesteAttackTimer = ATTACK_ANIM_DUR
    d._CelesteAttackOffset = Vector(0, ATTACK_ANIM_OFFSET_Y)
end

local function ProcessCelesteWave(player)
    if not player or not player:Exists() then return end
    local d = player:GetData()
    if not d._WaveActiveTimer or d._WaveActiveTimer <= 0 then return end
    if not d._CelesteAttackScaledRadius then return end

    local total = d._CelesteWaveTotalFrames or WAVE_ACTIVE_FRAMES
    local current = d._WaveActiveTimer
    local elapsed = math.max(0, (total - current) + 1)
    local progress = math.min(1, elapsed / total)

    local curRadius = d._CelesteAttackScaledRadius * progress
    local lastRadius = d._CelesteWaveLastRadius or 0
    local ringThickness = math.max(1, (d._CelesteAttackScaledRadius / total) * 1.5)

    -- not proud of this code :(
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if ent:IsVulnerableEnemy() and not ent:IsDead() then
            local ok, dist = pcall(function() return ent.Position:Distance(player.Position) end)
            if ok and type(dist) == "number" then
                if dist > (lastRadius - 0.5) and dist <= (curRadius + ringThickness) then
                    local entId = tostring(ent.InitSeed) .. "_" .. tostring(ent.InitSeed or 0)
                    if not d._CelesteWaveHit[entId] then
                        d._CelesteWaveHit[entId] = true
                        pcall(function()
                            ent:TakeDamage(math.max(1, player.Damage * 2), 0, EntityRef(player), 0)
                            ent.Velocity = ent.Velocity + (ent.Position - player.Position):Normalized() * 5
                        end)
                        pcall(function()
                            if ent:IsDead() then
                                -- this doesn't work. randomly adds hearts to the player even if you don't kill an entity.
                                if math.random() < HALF_HEART_ON_KILL_CHANCE then
                                    player:AddHearts(1)
                                end
                            end
                        end)
                    end
                end
            end
        end
    end

    d._CelesteWaveLastRadius = curRadius

    if d._WaveActiveTimer <= 1 then
        d._CelesteWaveLastRadius = nil
        d._CelesteWaveTotalFrames = nil
        d._CelesteWaveHit = nil
    end
end

local function ActivateCeleste(player)
    if not player or not player:Exists() then return end
    local range = GetPlayerRange(player)
    local scale = RangeToWaveScale(range)
    local scaledRadius = math.floor(WAVE_RADIUS * scale + 0.5)
    StartCelesteWave(player, scaledRadius)
end

local function PlayDashSFX()
    local sfx = SFXManager()
    local ok, id = pcall(Isaac.GetSoundIdByName, "dash_sfx")
    if ok and type(id) == "number" and id ~= -1 and id ~= 0 then
        pcall(function() sfx:Play(id) end)
        return
    end
end

function mod:OnUseDash(itemID, _, player)
    if itemID ~= ACTIVE_ID then return end
    local d = player:GetData()
    d._TearBonus = d._TearBonus or 0
    local mv = player:GetMovementVector()
    if mv:Length() > 0 then d._LastMoveDir = mv:Normalized() end
    d._DashDir = d._LastMoveDir or Vector(0, -1)
    d._DashTimer = DASH_DURATION
    player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
    d._PostInvulnTimer = nil
    player.Velocity = d._DashDir * DASH_SPEED

    pcall(function() PlayDashSFX() end)

    if player:HasCollectible(PASSIVE_ID) then
        ActivateCeleste(player)
    end

    return true
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnUseDash, ACTIVE_ID)

function mod:OnUseStop(itemID, _, player)
    if itemID == ACTIVE2_ID and player:GetName() == "Tainted Madeline" then
        local d = player:GetData()
        d._DisableAutoDash = true
        d._HideChargeBar = true
        d._AutoDashTimer = 0
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnUseStop, ACTIVE2_ID)

function mod:OnPlayerUpdate(player)
    local d = player:GetData()
    d._TearBonus = d._TearBonus or 0
    local mv = player:GetMovementVector()
    if mv:Length() > 0 then d._LastMoveDir = mv:Normalized() end

    if (not d._DashTimer) and d._PostInertiaTimer and d._PostInertiaTimer > 0 then
        if mv and mv:Length() > 0 then
            d._PostInertiaTimer = nil
            d._PostInertiaSpeed = nil
            d._PostInertiaDir = nil
        else
            local framesTotal = POST_DASH_INERTIA_FRAMES or 12
            local initialSpeed = d._PostInertiaSpeed or (POST_DASH_INERTIA_SPEED or 5)
            local frac = math.max(0, d._PostInertiaTimer) / framesTotal
            local curSpeed = initialSpeed * frac
            if d._PostInertiaDir then
                player.Velocity = d._PostInertiaDir * curSpeed
            end
            d._PostInertiaTimer = d._PostInertiaTimer - 1
            if d._PostInertiaTimer <= 0 then
                d._PostInertiaTimer = nil
                d._PostInertiaSpeed = nil
                d._PostInertiaDir = nil
            end
        end
    end

    if player:GetName() == "Tainted Madeline" and not d._DisableAutoDash then
        d._AutoDashTimer = (d._AutoDashTimer or AUTO_DASH_INTERVAL) - 1
        if d._AutoDashTimer <= 0 then
            d._AutoDashTimer = AUTO_DASH_INTERVAL
            d._DashDir = d._LastMoveDir or Vector(0, -1)
            d._DashTimer = AUTO_DASH_DURATION
            player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
            player.Velocity = d._DashDir * AUTO_DASH_SPEED

            pcall(function() PlayDashSFX() end)

            if player:HasCollectible(PASSIVE_ID) then
                ActivateCeleste(player)
            end
        end
    end

    if d._DashTimer then
        if d._DashTimer > 0 then
            d._DashTimer = d._DashTimer - 1
            local sp = (player:GetName() == "Tainted Madeline") and AUTO_DASH_SPEED or DASH_SPEED
            player.Velocity = d._DashDir * sp
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if ent:IsVulnerableEnemy() and ent.Position:Distance(player.Position) <= CONTACT_RADIUS then
                    local mult = player:HasTrinket(TRINKET_ID) and TRINKET_MULTIPLIER or WEAK_MULTIPLIER
                    ent:TakeDamage(math.max(1, player.Damage * mult), 0, EntityRef(player), 0)
                end
            end
        else
            player:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            player:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)

            if d._DashDir then
                d._PostInertiaDir = d._DashDir
                d._PostInertiaTimer = POST_DASH_INERTIA_FRAMES or 12
                d._PostInertiaSpeed = POST_DASH_INERTIA_SPEED or 5
            else
                d._PostInertiaDir = nil
                d._PostInertiaTimer = nil
                d._PostInertiaSpeed = nil
            end

            d._DashTimer = nil
            d._DashDir = nil
            d._PostInvulnTimer = POST_INVULN_AFTER
        end
    end
    if d._PostInvulnTimer then
        d._PostInvulnTimer = d._PostInvulnTimer - 1
        if d._PostInvulnTimer <= 0 then d._PostInvulnTimer = nil end
    end

    if player:HasCollectible(PASSIVE_ID) then
        local range = GetPlayerRange(player)
        local scale = RangeToWaveScale(range)
        local scaledRadius = math.floor(WAVE_RADIUS * scale + 0.5)

        d._HorizonWaveTimer = (d._HorizonWaveTimer or WAVE_INTERVAL_FRAMES) - 1
        if d._HorizonWaveTimer <= 0 then
            d._HorizonWaveTimer = WAVE_INTERVAL_FRAMES

            if not d._CelesteAttackSprite then
                d._CelesteAttackSprite = Sprite()
                d._CelesteAttackSprite:Load(ATTACK_ANM_PATH, true)
            end

            d._CelesteAttackScaledRadius = scaledRadius
            local spriteScale = SpriteScaleForRadius(player, scaledRadius)
            d._CelesteAttackSpriteScale = spriteScale

            pcall(function()
                d._CelesteAttackSprite:Play(ATTACK_ANIM_NAME, true)
                pcall(function() d._CelesteAttackSprite.Scale = Vector(spriteScale, spriteScale) end)
            end)

            if not d._CelesteAttackPlaying then
                d._CelesteAttackPlaying = true
                d._CelesteAttackTimer = ATTACK_ANIM_DUR
                d._CelesteAttackOffset = Vector(0, ATTACK_ANIM_OFFSET_Y)
            end

            d._WaveActiveTimer = WAVE_ACTIVE_FRAMES
            d._CelesteWaveTotalFrames = WAVE_ACTIVE_FRAMES
            d._CelesteWaveLastRadius = 0
            d._CelesteWaveHit = {}
        end

        if d._WaveActiveTimer and d._WaveActiveTimer > 0 then
            ProcessCelesteWave(player)
            d._WaveActiveTimer = d._WaveActiveTimer - 1
        end
        
        d._RegenTimer = (d._RegenTimer or REGEN_INTERVAL_FRAMES) - 1
        if d._RegenTimer <= 0 then
            d._RegenTimer = REGEN_INTERVAL_FRAMES
            d._RegenCount = d._RegenCount or 0
            if d._RegenCount < REGEN_CAP_HALFHEARTS then
                player:AddHearts(1)
                d._RegenCount = d._RegenCount + 1
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OnPlayerUpdate)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
    local d = player:GetData()
    if not d._CelesteAttackPlaying or not d._CelesteAttackSprite then return end

    local spr = d._CelesteAttackSprite
    local offset = d._CelesteAttackOffset or Vector(0, ATTACK_ANIM_OFFSET_Y)
    local screenPos = Isaac.WorldToScreen(player.Position + offset)

    if d._CelesteAttackTimer then
        d._CelesteAttackTimer = d._CelesteAttackTimer - 1
        if d._CelesteAttackTimer <= 0 then
            d._CelesteAttackPlaying = nil
            d._CelesteAttackTimer = nil
            return
        end
    else
        local ok, finished = pcall(function() return spr:IsFinished(ATTACK_ANIM_NAME) end)
        if ok and finished then
            d._CelesteAttackPlaying = nil
            return
        end
    end

    if (not d._CelesteAttackSpriteScale) and d._CelesteAttackScaledRadius then
        d._CelesteAttackSpriteScale = SpriteScaleForRadius(player, d._CelesteAttackScaledRadius)
    end

    if d._CelesteAttackSpriteScale then
        pcall(function() spr.Scale = Vector(d._CelesteAttackSpriteScale, d._CelesteAttackSpriteScale) end)
    end

    pcall(function() spr:Render(screenPos, Vector.Zero, Vector.Zero) end)
    pcall(function() spr:Update() end)
end)

function mod:OnPlayerTakeDamage(entity, dmg, flags, source)
    if entity.Type == EntityType.ENTITY_PLAYER then
        local p = entity:ToPlayer()
        local d = p:GetData()
        if d._DashTimer or d._PostInvulnTimer then
            return false
        end
        if d._WaveActiveTimer and d._WaveActiveTimer > 0 and source.Entity then
            local src = source.Entity
            if src.Type == EntityType.ENTITY_TEAR then
                Isaac.Spawn(EntityType.ENTITY_TEAR, src.Variant, 0, p.Position, src.Velocity:Rotated(180), p)
                return false
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.OnPlayerTakeDamage, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for i = 0, game:GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(i)
        if p:GetName() == "Tainted Madeline" then
            local d = p:GetData()
            if d._HideChargeBar then
                d._DisableAutoDash = nil
                d._HideChargeBar = nil
                d._AutoDashTimer = AUTO_DASH_INTERVAL
            end
        end
    end
end)

function ChargeBarRender(Meter, IsCharging, pos, Sprite)
    -- local i = spriterotation
    if not Game():GetHUD():IsVisible() then return end
    local pct = Meter or 0
    if IsCharging then
        if pct < 99 then
            Sprite:SetFrame("Charging", math.floor(pct))
        --     if i == 0 then
        --         Sprite:SetFrame("Charging", math.floor(pct))
        --     elseif i == 1 then
        --         Sprite:SetFrame("Charging1", math.floor(pct))
        --     elseif i == 2 then
        --         Sprite:SetFrame("Charging2", math.floor(pct))
        --     end
        else
            if not Sprite:IsPlaying("Charged") then Sprite:Play("Charged", true) end
        end
    elseif not Sprite:IsPlaying("Disappear") and not Sprite:IsFinished("Disappear") then
        Sprite:Play("Disappear", true)
    end
    Sprite:Render(pos, Vector.Zero, Vector.Zero)
    Sprite:Update()
    -- spriterotation = spriterotation + 1
    -- if spriterotation > 2 then spriterotation = 0 end
end


mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
    if player:HasCollectible(PASSIVE_ID) then
        local d = player:GetData()
        d._CelesteWaveChargebar = d._CelesteWaveChargebar or Sprite()
        if not d._CelesteWaveChargebar:IsLoaded() then
            d._CelesteWaveChargebar:Load("gfx/celestechargebar.anm2", true)
        end
        d._CelesteWaveChargebar.Scale = Vector(0.8, 0.8)
        d._HorizonWaveTimer = d._HorizonWaveTimer or WAVE_INTERVAL_FRAMES
        local pct = ((WAVE_INTERVAL_FRAMES - d._HorizonWaveTimer) / WAVE_INTERVAL_FRAMES) * 100
        pct = math.max(0, math.min(100, pct))
        local offset = Vector(-18, -10)
        ChargeBarRender(pct, true, Isaac.WorldToScreen(player.Position + offset), d._CelesteWaveChargebar)
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
    if player:GetName() ~= "Tainted Madeline" then return end
    local d = player:GetData()
    if d._HideChargeBar then return end
    if not d.TaintedDashChargebar then
        d.TaintedDashChargebar = Sprite()
        d.TaintedDashChargebar:Load("gfx/dashchargebar.anm2", true)
    end
    d._AutoDashTimer = d._AutoDashTimer or AUTO_DASH_INTERVAL
    local pct = ((AUTO_DASH_INTERVAL - d._AutoDashTimer) / AUTO_DASH_INTERVAL) * 100
    pct = math.max(0, math.min(100, pct))
    local offset = Vector(-15, -54)
    ChargeBarRender(pct, true, Isaac.WorldToScreen(player.Position + offset), d.TaintedDashChargebar)
end)

function mod:cache(player, cacheFlag)
    if player:GetName() ~= "Madeline" then return end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage - 1
    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = CalculateTears(player.MaxFireDelay, 0.5)
    elseif cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.15
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cache)
function mod:cache2(player, cacheFlag)
    if player:GetName() ~= "Tainted Madeline" then return end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = CalculateTears(player.MaxFireDelay, 0.3) end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.cache2)

local function ReplaceTearSprite(_, tear)
    if not tear or not tear:Exists() then return end

    local spawnerPlayer = nil
    if tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
        spawnerPlayer = tear.SpawnerEntity:ToPlayer()
    elseif tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER then
        spawnerPlayer = tear.Parent:ToPlayer()
    end

    if not spawnerPlayer then return end
    if not spawnerPlayer:HasCollectible(PASSIVE_ID) then return end

    local spr = tear:GetSprite()
    if not spr then return end

    local i = rotationIndex

    pcall(function()
        spr:Load("gfx/star_tear_anim.anm2", true)
        if i == 0 then
            pcall(function() spr:Play("rotation0", true) end)
        elseif i == 1 then
            pcall(function() spr:Play("rotation1", true) end)
        elseif i == 2 then
            pcall(function() spr:Play("rotation2", true) end)
        elseif i == 3 then
            pcall(function() spr:Play("rotation3", true) end)
        end
        rotationIndex = rotationIndex + 1
        if rotationIndex > 3 then rotationIndex = 0 end
    end)
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, ReplaceTearSprite)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, ReplaceTearSprite)

return mod
