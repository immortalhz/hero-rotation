--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL         = HeroLib
local Cache      = HeroCache
local Unit       = HL.Unit
local Player     = Unit.Player
local Target     = Unit.Target
local Pet        = Unit.Pet
local Spell      = HL.Spell
local MultiSpell = HL.MultiSpell
local Item       = HL.Item
-- HeroRotation
local HR         = HeroRotation

-- Azerite Essence Setup
local AE         = HL.Enum.AzeriteEssences
local AESpellIDs = HL.Enum.AzeriteEssenceSpellIDs

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.DeathKnight then Spell.DeathKnight = {} end
Spell.DeathKnight.Frost = {
  RemorselessWinter                     = Spell(196770),
  GatheringStorm                        = Spell(194912),
  GlacialAdvance                        = Spell(194913),
  Frostscythe                           = Spell(207230),
  FrostStrike                           = Spell(49143),
  HowlingBlast                          = Spell(49184),
  RimeBuff                              = Spell(59052),
  KillingMachineBuff                    = Spell(51124),
  RunicAttenuation                      = Spell(207104),
  Obliterate                            = Spell(49020),
  HornofWinter                          = Spell(57330),
  ArcaneTorrent                         = Spell(50613),
  PillarofFrost                         = Spell(51271),
  ChainsofIce                           = Spell(45524),
  ColdHeartBuff                         = Spell(281209),
  PillarofFrostBuff                     = Spell(51271),
  FrostwyrmsFury                        = Spell(279302),
  EmpowerRuneWeaponBuff                 = Spell(47568),
  BloodFury                             = Spell(20572),
  Berserking                            = Spell(26297),
  ArcanePulse                           = Spell(260364),
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AncestralCall                         = Spell(274738),
  BagofTricks                           = Spell(312411),
  EmpowerRuneWeapon                     = Spell(47568),
  BreathofSindragosa                    = Spell(152279),
  ColdHeart                             = Spell(281208),
  RazoriceDebuff                        = Spell(51714),
  FrozenPulseBuff                       = Spell(194909),
  FrozenPulse                           = Spell(194909),
  FrostFeverDebuff                      = Spell(55095),
  IcyTalonsBuff                         = Spell(194879),
  Icecap                                = Spell(207126),
  Obliteration                          = Spell(281238),
  DeathStrike                           = Spell(49998),
  DeathStrikeBuff                       = Spell(101568),
  FrozenTempest                         = Spell(278487),
  UnholyStrengthBuff                    = Spell(53365),
  IcyCitadel                            = Spell(272718),
  IcyCitadelBuff                        = Spell(272723),
  MindFreeze                            = Spell(47528),
  RazorCoralDebuff                      = Spell(303568),
  BloodoftheEnemy                       = Spell(297108),
  MemoryofLucidDreams                   = Spell(298357),
  PurifyingBlast                        = Spell(295337),
  RippleInSpace                         = Spell(302731),
  ConcentratedFlame                     = Spell(295373),
  TheUnboundForce                       = Spell(298452),
  WorldveinResonance                    = Spell(295186),
  FocusedAzeriteBeam                    = Spell(295258),
  GuardianofAzeroth                     = Spell(295840),
  ReapingFlames                         = Spell(310690),
  RecklessForceCounter                  = MultiSpell(298409, 302917),
  RecklessForceBuff                     = Spell(302932),
  SeethingRageBuff                      = Spell(297126),
  ConcentratedFlameBurn                 = Spell(295368),
  ChillStreak                           = Spell(305392),
  PoolRange                             = Spell(9999000010)
};
local S = Spell.DeathKnight.Frost;

-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Frost = {
  PotionofUnbridledFury            = Item(169299),
  RazdunksBigRedButton             = Item(159611, {13, 14}),
  MerekthasFang                    = Item(158367, {13, 14}),
  KnotofAncientFuryAlliance        = Item(161413, {13, 14}),
  KnotofAncientFuryHorde           = Item(166795, {13, 14}),
  FirstMatesSpyglass               = Item(158163, {13, 14}),
  GrongsPrimalRage                 = Item(165574, {13, 14}),
  AzsharasFontofPower              = Item(169314, {13, 14}),
  LurkersInsidiousGift             = Item(167866, {13, 14}),
  PocketsizedComputationDevice     = Item(167555, {13, 14}),
  AshvanesRazorCoral               = Item(169311, {13, 14}),
  -- "Other On Use"
  NotoriousGladiatorsBadge         = Item(167380, {13, 14}),
  NotoriousGladiatorsMedallion     = Item(167377, {13, 14}),
  CorruptedGladiatorsBadge         = Item(172669, {13, 14}),
  CorruptedGladiatorsMedallion     = Item(172666, {13, 14}),
  VialofAnimatedBlood              = Item(159625, {13, 14}),
  JesHowler                        = Item(159627, {13, 14})
};
local I = Item.DeathKnight.Frost;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DeathKnight.Commons,
  Frost = HR.GUISettings.APL.DeathKnight.Frost
};

-- Functions
local EnemyRanges = {10, 8}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i, true);
  end
end

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function DeathStrikeHeal()
  return (Settings.General.SoloMode and (Player:HealthPercentage() < Settings.Commons.UseDeathStrikeHP or Player:HealthPercentage() < Settings.Commons.UseDarkSuccorHP and Player:BuffP(S.DeathStrikeBuff))) and true or false;
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, VarOoUE, Aoe, BosPooling, BosTicking, ColdHeart, Cooldowns, Essences, Obliteration, Standard
  local no_heal = not DeathStrikeHeal()
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.PotionofUnbridledFury:IsReady() and Settings.Commons.UsePotions then
      if HR.Cast(I.PotionofUnbridledFury, Settings.Commons.OffGCDasOffGCD.Potions) then return "potion precombat"; end
    end
    -- use_item,name=azsharas_font_of_power
    if I.AzsharasFontofPower:IsEquipReady() then
      if HR.Cast(I.AzsharasFontofPower, nil, Settings.Commons.TrinketDisplayStyle) then return "azsharas_font_of_power precombat"; end
    end
    -- variable,name=other_on_use_equipped,value=(equipped.notorious_gladiators_badge|equipped.corrupted_gladiators_badge|equipped.corrupted_gladiators_medallion|equipped.vial_of_animated_blood|equipped.first_mates_spyglass|equipped.jes_howler|equipped.notorious_gladiators_medallion|equipped.ashvanes_razor_coral)
    if (true) then
      VarOoUE = (I.NotoriousGladiatorsBadge:IsEquipped() or I.CorruptedGladiatorsBadge:IsEquipped() or I.CorruptedGladiatorsMedallion:IsEquipped() or I.VialofAnimatedBlood:IsEquipped() or I.FirstMatesSpyglass:IsEquipped() or I.JesHowler:IsEquipped() or I.NotoriousGladiatorsMedallion:IsEquipped() or I.AshvanesRazorCoral:IsEquipped())
    end
    -- opener
    if Everyone.TargetIsValid() then
      if S.Obliterate:IsCastableP("Melee") and (S.BreathofSindragosa:IsAvailable()) then
        if HR.Cast(S.Obliterate) then return "obliterate precombat"; end
      end
      if S.HowlingBlast:IsCastableP(30, true) and (Target:DebuffDownP(S.FrostFeverDebuff)) then
        if HR.Cast(S.HowlingBlast) then return "howling_blast precombat"; end
      end
    end
  end
  Aoe = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled|(azerite.frozen_tempest.rank&spell_targets.remorseless_winter>=3&!buff.rime.up)
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable() or (bool(S.FrozenTempest:AzeriteRank()) and Cache.EnemiesCount[8] >= 3 and Player:BuffDownP(S.RimeBuff))) then
      if HR.Cast(S.RemorselessWinter, nil, nil, 8) then return "remorseless_winter 11"; end
    end
    -- glacial_advance,if=talent.frostscythe.enabled
    if no_heal and S.GlacialAdvance:IsReadyP() and (S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.GlacialAdvance, nil, nil, 100) then return "glacial_advance 13"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable() and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 15"; end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 17"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 19"; end
    end
    -- frostscythe,if=buff.killing_machine.up
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff)) then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 21"; end
    end
    -- glacial_advance,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if no_heal and S.GlacialAdvance:IsReadyP() and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.GlacialAdvance, nil, nil, 100) then return "glacial_advance 23"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 25"; end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 27"; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter, nil, nil, 8) then return "remorseless_winter 29"; end
    end
    -- frostscythe
    if S.Frostscythe:IsCastableP() then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 31"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>(25+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 33"; end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 35"; end
    end
    -- glacial_advance
    if no_heal and S.GlacialAdvance:IsReadyP() then
      if HR.Cast(S.GlacialAdvance, nil, nil, 100) then return "glacial_advance 37"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 39"; end
    end
    -- frost_strike
    if no_heal and S.FrostStrike:IsReadyP("Melee") then
      if HR.Cast(S.FrostStrike) then return "frost_strike 41"; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      if HR.Cast(S.HornofWinter, Settings.Frost.GCDasOffGCD.HornofWinter) then return "horn_of_winter 43"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials, nil, 8) then return "arcane_torrent 45"; end
    end
  end
  BosPooling = function()
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 101"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>=25&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() >= 25 and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 103"; end
    end
    -- obliterate,if=runic_power.deficit>=25
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() >= 25) then
      if HR.Cast(S.Obliterate) then return "obliterate 105"; end
    end
    -- glacial_advance,if=runic_power.deficit<20&spell_targets.glacial_advance>=2&cooldown.pillar_of_frost.remains>5
    if no_heal and S.GlacialAdvance:IsReadyP() and (Player:RunicPowerDeficit() < 20 and Cache.EnemiesCount[10] >= 2 and S.PillarofFrost:CooldownRemainsP() > 5) then
      if HR.Cast(S.GlacialAdvance, nil, nil, 100) then return "glacial_advance 107"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit<20&!talent.frostscythe.enabled&cooldown.pillar_of_frost.remains>5
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() < 20 and not S.Frostscythe:IsAvailable() and S.PillarofFrost:CooldownRemainsP() > 5) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 109"; end
    end
    -- frost_strike,if=runic_power.deficit<20&cooldown.pillar_of_frost.remains>5
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < 20 and S.PillarofFrost:CooldownRemainsP() > 5) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 111"; end
    end
    -- frostscythe,if=buff.killing_machine.up&runic_power.deficit>(15+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RunicPowerDeficit() > (15 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 113"; end
    end
    -- frostscythe,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 115"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3) and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 117"; end
    end
    -- obliterate,if=runic_power.deficit>=(35+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() >= (35 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 119"; end
    end
    -- glacial_advance,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&spell_targets.glacial_advance>=2
    if no_heal and S.GlacialAdvance:IsReadyP() and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and Cache.EnemiesCount[10] >= 2) then
      if HR.Cast(S.GlacialAdvance, nil, nil, 100) then return "glacial_advance 121"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40 and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 123"; end
    end
    -- frost_strike,if=cooldown.pillar_of_frost.remains>rune.time_to_4&runic_power.deficit<40
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (S.PillarofFrost:CooldownRemainsP() > Player:RuneTimeToX(4) and Player:RunicPowerDeficit() < 40) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 125"; end
    end
    -- wait for resources
    if HR.CastAnnotated(S.PoolRange, false, "WAIT") then return "Wait Resources BoS Pooling"; end
  end
  BosTicking = function()
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power<=32&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPower() <= 32 and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 201"; end
    end
    -- obliterate,if=runic_power<=32
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPower() <= 32) then
      if HR.Cast(S.Obliterate) then return "obliterate 203"; end
    end
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter, nil, nil, 8) then return "remorseless_winter 205"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 207"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&rune.time_to_5<gcd|runic_power<=45&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45 and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 209"; end
    end
    -- obliterate,if=rune.time_to_5<gcd|runic_power<=45
    if S.Obliterate:IsCastableP("Melee") and (Player:RuneTimeToX(5) < Player:GCD() or Player:RunicPower() <= 45) then
      if HR.Cast(S.Obliterate) then return "obliterate 211"; end
    end
    -- frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 213"; end
    end
    -- horn_of_winter,if=runic_power.deficit>=32&rune.time_to_3>gcd
    if S.HornofWinter:IsCastableP() and (Player:RunicPowerDeficit() >= 30 and Player:RuneTimeToX(3) > Player:GCD()) then
      if HR.Cast(S.HornofWinter, Settings.Frost.GCDasOffGCD.HornofWinter) then return "horn_of_winter 215"; end
    end
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter, nil, nil, 8) then return "remorseless_winter 217"; end
    end
    -- frostscythe,if=spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and (Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 219"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&runic_power.deficit>25|rune>3&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:RunicPowerDeficit() > 25 or Player:Rune() > 3 and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 221"; end
    end
    -- obliterate,if=runic_power.deficit>25|rune>3
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() > 25 or Player:Rune() > 3) then
      if HR.Cast(S.Obliterate) then return "obliterate 223"; end
    end
    -- arcane_torrent,if=runic_power.deficit>50
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() and (Player:RunicPowerDeficit() > 50) then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials, nil, 8) then return "arcane_torrent 225"; end
    end
    -- wait for resources
    if HR.CastAnnotated(S.PoolRange, false, "WAIT") then return "Wait Resources BoS Ticking"; end
  end
  ColdHeart = function()
    -- chains_of_ice,if=buff.cold_heart.stack>5&target.time_to_die<gcd
    if S.ChainsofIce:IsCastableP() and (Player:BuffStackP(S.ColdHeartBuff) > 5 and Target:TimeToDie() < Player:GCD()) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 301"; end
    end
    -- chains_of_ice,if=(buff.seething_rage.remains<gcd)&buff.seething_rage.up
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.SeethingRageBuff) < Player:GCD()) and Player:BuffP(S.SeethingRageBuff)) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 303"; end
    end
    -- chains_of_ice,if=(buff.pillar_of_frost.remains<=gcd*(1+cooldown.frostwyrms_fury.ready)|buff.pillar_of_frost.remains<rune.time_to_3)&buff.pillar_of_frost.up&(azerite.icy_citadel.rank<=1|buff.breath_of_sindragosa.up)&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) or Player:BuffRemainsP(S.PillarofFrostBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.PillarofFrostBuff) and (S.IcyCitadel:AzeriteRank() <= 1 or Player:BuffP(S.BreathofSindragosa)) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 305"; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.remains<8&buff.unholy_strength.remains<gcd*(1+cooldown.frostwyrms_fury.ready)&buff.unholy_strength.remains&buff.pillar_of_frost.up&(azerite.icy_citadel.rank<=1|buff.breath_of_sindragosa.up)&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 8 and Player:BuffRemainsP(S.UnholyStrengthBuff) < Player:GCD() * (1 + num(S.FrostwyrmsFury:CooldownUpP())) and Player:BuffP(S.UnholyStrengthBuff) and Player:BuffP(S.PillarofFrostBuff) and (S.IcyCitadel:AzeriteRank() <= 1 or Player:BuffP(S.BreathofSindragosa)) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 307"; end
    end
    -- chains_of_ice,if=(buff.icy_citadel.remains<4|buff.icy_citadel.remains<rune.time_to_3)&buff.icy_citadel.up&azerite.icy_citadel.rank>=2&!buff.breath_of_sindragosa.up&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and ((Player:BuffRemainsP(S.IcyCitadelBuff) < 4 or Player:BuffRemainsP(S.IcyCitadelBuff) < Player:RuneTimeToX(3)) and Player:BuffP(S.IcyCitadelBuff) and S.IcyCitadel:AzeriteRank() >= 2 and Player:BuffDownP(S.BreathofSindragosa) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 309"; end
    end
    -- chains_of_ice,if=buff.icy_citadel.up&buff.unholy_strength.up&azerite.icy_citadel.rank>=2&!buff.breath_of_sindragosa.up&!talent.icecap.enabled
    if S.ChainsofIce:IsCastableP() and (Player:BuffP(S.IcyCitadelBuff) and Player:BuffP(S.UnholyStrengthBuff) and S.IcyCitadel:AzeriteRank() >= 2 and Player:BuffDownP(S.BreathofSindragosa) and not S.Icecap:IsAvailable()) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 311"; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.remains<4&buff.pillar_of_frost.up&talent.icecap.enabled&buff.cold_heart.stack>=18&azerite.icy_citadel.rank<=1
    if S.ChainsofIce:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 4 and Player:BuffP(S.PillarofFrostBuff) and S.Icecap:IsAvailable() and Player:BuffStackP(S.ColdHeartBuff) >= 18 and S.IcyCitadel:AzeriteRank() <= 1) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 313"; end
    end
    -- chains_of_ice,if=buff.pillar_of_frost.up&talent.icecap.enabled&azerite.icy_citadel.rank>=2&(buff.cold_heart.stack>=19&buff.icy_citadel.remains<gcd&buff.icy_citadel.up|buff.unholy_strength.up&buff.cold_heart.stack>=18)
    if S.ChainsofIce:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and S.Icecap:IsAvailable() and S.IcyCitadel:AzeriteRank() >= 2 and (Player:BuffStackP(S.ColdHeartBuff) >= 19 and Player:BuffRemainsP(S.IcyCitadelBuff) < Player:GCD() and Player:BuffP(S.IcyCitadelBuff) or Player:BuffP(S.UnholyStrengthBuff) and Player:BuffStackP(S.ColdHeartBuff) >= 18)) then
      if HR.Cast(S.ChainsofIce, nil, nil, 30) then return "chains_of_ice 315"; end
    end
  end
  Cooldowns = function()
    if (Settings.Commons.UseTrinkets) then
      -- use_item,name=azsharas_font_of_power,if=(cooldown.empowered_rune_weapon.ready&!variable.other_on_use_equipped)|(cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)
      if I.AzsharasFontofPower:IsEquipReady() and ((S.EmpowerRuneWeapon:CooldownUpP() and not bool(VarOoUE)) or (S.PillarofFrost:CooldownRemainsP() <= 10 and bool(VarOoUE))) then
        if HR.Cast(I.AzsharasFontofPower, nil, Settings.Commons.TrinketDisplayStyle) then return "azsharas_font_of_power 401"; end
      end
      -- use_item,name=lurkers_insidious_gift,if=talent.breath_of_sindragosa.enabled&((cooldown.pillar_of_frost.remains<=10&variable.other_on_use_equipped)|(buff.pillar_of_frost.up&!variable.other_on_use_equipped))|(buff.pillar_of_frost.up&!talent.breath_of_sindragosa.enabled)
      if I.LurkersInsidiousGift:IsEquipReady() and (S.BreathofSindragosa:IsAvailable() and ((S.PillarofFrost:CooldownRemainsP() <= 10 and bool(VarOoUE)) or (Player:BuffP(S.PillarofFrostBuff) and not bool(VarOoUE))) or (Player:BuffP(S.PillarofFrostBuff) and not S.BreathofSindragosa:IsAvailable())) then
        if HR.Cast(I.LurkersInsidiousGift, nil, Settings.Commons.TrinketDisplayStyle) then return "lurkers_insidious_gift 403"; end
      end
      -- use_item,name=cyclotronic_blast,if=!buff.pillar_of_frost.up
      if Everyone.CyclotronicBlastReady() and (Player:BuffDownP(S.PillarofFrostBuff)) then
        if HR.Cast(I.PocketsizedComputationDevice, nil, Settings.Commons.TrinketDisplayStyle, 40) then return "cyclotronic_blast 405"; end
      end
      -- use_items,if=(cooldown.pillar_of_frost.ready|cooldown.pillar_of_frost.remains>20)&(!talent.breath_of_sindragosa.enabled|cooldown.empower_rune_weapon.remains>95)
      -- use_item,name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.down
      if I.AshvanesRazorCoral:IsEquipReady() and (Target:DebuffDownP(S.RazorCoralDebuff)) then
        if HR.Cast(I.AshvanesRazorCoral, nil, Settings.Commons.TrinketDisplayStyle, 40) then return "ashvanes_razor_coral 407"; end
      end
      -- use_item,name=ashvanes_razor_coral,if=cooldown.empower_rune_weapon.remains>90&debuff.razor_coral_debuff.up&variable.other_on_use_equipped|buff.breath_of_sindragosa.up&debuff.razor_coral_debuff.up&!variable.other_on_use_equipped|buff.empower_rune_weapon.up&debuff.razor_coral_debuff.up&!talent.breath_of_sindragosa.enabled|target.1.time_to_die<21
      if I.AshvanesRazorCoral:IsEquipReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 90 and Target:DebuffP(S.RazorCoralDebuff) and bool(VarOoUE) or Player:BuffP(S.BreathofSindragosa) and Target:DebuffP(S.RazorCoralDebuff) and not bool(VarOoUE) or Player:BuffP(S.EmpowerRuneWeaponBuff) and Target:DebuffP(S.RazorCoralDebuff) and not S.BreathofSindragosa:IsAvailable() or Target:TimeToDie() < 21) then
        if HR.Cast(I.AshvanesRazorCoral, nil, Settings.Commons.TrinketDisplayStyle, 40) then return "ashvanes_razor_coral 409"; end
      end
      -- use_item,name=jes_howler,if=(equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains)|(!equipped.lurkers_insidious_gift&buff.pillar_of_frost.remains<12&buff.pillar_of_frost.up)
      if I.JesHowler:IsEquipReady() and ((I.LurkersInsidiousGift:IsEquipped() and Player:BuffP(S.PillarofFrostBuff)) or (not I.LurkersInsidiousGift:IsEquipped() and Player:BuffRemainsP(S.PillarofFrostBuff) < 12 and Player:BuffP(S.PillarofFrostBuff))) then
        if HR.Cast(I.JesHowler, nil, Settings.Commons.TrinketDisplayStyle) then return "jes_howler 411"; end
      end
      -- use_item,name=knot_of_ancient_fury,if=cooldown.empower_rune_weapon.remains>40
      -- Two lines, since Horde and Alliance versions of the trinket have different IDs
      if I.KnotofAncientFuryAlliance:IsEquipReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 40) then
        if HR.Cast(I.KnotofAncientFuryAlliance, nil, Settings.Commons.TrinketDisplayStyle) then return "knot_of_ancient_fury 413"; end
      end
      if I.KnotofAncientFuryHorde:IsEquipReady() and (S.EmpowerRuneWeapon:CooldownRemainsP() > 40) then
        if HR.Cast(I.KnotofAncientFuryHorde, nil, Settings.Commons.TrinketDisplayStyle) then return "knot_of_ancient_fury 415"; end
      end
      -- use_item,name=grongs_primal_rage,if=rune<=3&!buff.pillar_of_frost.up&(!buff.breath_of_sindragosa.up|!talent.breath_of_sindragosa.enabled)
      if I.GrongsPrimalRage:IsEquipReady() and (Player:Rune() <= 3 and Player:BuffDownP(S.PillarofFrostBuff) and (Player:BuffDownP(S.BreathofSindragosa) or not S.BreathofSindragosa:IsAvailable())) then
        if HR.Cast(I.GrongsPrimalRage, nil, Settings.Commons.TrinketDisplayStyle) then return "grongs_primal_rage 417"; end
      end
      -- use_item,name=razdunks_big_red_button
      if I.RazdunksBigRedButton:IsEquipReady() then
        if HR.Cast(I.RazdunksBigRedButton, nil, Settings.Commons.TrinketDisplayStyle, 40) then return "razdunks_big_red_button 419"; end
      end
      -- use_item,name=merekthas_fang,if=!dot.breath_of_sindragosa.ticking&!buff.pillar_of_frost.up
      if I.MerekthasFang:IsEquipReady() and (Player:BuffDownP(S.BreathofSindragosa) and Player:BuffDownP(S.PillarofFrostBuff)) then
        if HR.Cast(I.MerekthasFang, nil, Settings.Commons.TrinketDisplayStyle, 20) then return "merekthas_fang 419"; end
      end
    end
    -- potion,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if I.PotionofUnbridledFury:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(I.PotionofUnbridledFury, Settings.Commons.OffGCDasOffGCD.Potions) then return "potion 423"; end
    end
    -- blood_fury,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if S.BloodFury:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 425"; end
    end
    -- berserking,if=buff.pillar_of_frost.up
    if S.Berserking:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 427"; end
    end
    -- arcane_pulse,if=(!buff.pillar_of_frost.up&active_enemies>=2)|!buff.pillar_of_frost.up&(rune.deficit>=5&runic_power.deficit>=60)
    if S.ArcanePulse:IsCastableP() and ((Player:BuffDownP(S.PillarofFrostBuff) and Cache.EnemiesCount[8] >= 2) or Player:BuffDownP(S.PillarofFrostBuff) and (6 - Player:Rune() >= 5 and Player:RunicPowerDeficit() >= 60)) then
      if HR.Cast(S.ArcanePulse, Settings.Commons.OffGCDasOffGCD.Racials, nil, 8) then return "arcane_pulse 428"; end
    end
    -- lights_judgment,if=buff.pillar_of_frost.up
    if S.LightsJudgment:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.LightsJudgment, Settings.Commons.OffGCDasOffGCD.Racials, nil, 40) then return "lights_judgment 429"; end
    end
    -- ancestral_call,if=buff.pillar_of_frost.up&buff.empower_rune_weapon.up
    if S.AncestralCall:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 430"; end
    end
    -- fireblood,if=buff.pillar_of_frost.remains<=8&buff.empower_rune_weapon.up
    if S.Fireblood:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) <= 8 and Player:BuffP(S.EmpowerRuneWeaponBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 431"; end
    end
    -- bag_of_tricks,if=buff.pillar_of_frost.up&(buff.pillar_of_frost.remains<5&talent.cold_heart.enabled|!talent.cold_heart.enabled&buff.pillar_of_frost.remains<3)&active_enemies=1|buff.seething_rage.up&active_enemies=1
    if S.BagofTricks:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and (Player:BuffRemainsP(S.PillarofFrostBuff) < 5 and S.ColdHeart:IsAvailable() or not S.ColdHeart:IsAvailable() and Player:BuffRemainsP(S.PillarofFrostBuff) < 3) and Cache.EnemiesCount[8] == 1 or Player:BuffP(S.SeethingRageBuff) and Cache.EnemiesCount[8] == 1) then
      if HR.Cast(S.BagofTricks, Settings.Commons.OffGCDasOffGCD.Racials, nil, 40) then return "bag_of_tricks 432"; end
    end
    -- pillar_of_frost,if=cooldown.empower_rune_weapon.remains|talent.icecap.enabled
    if S.PillarofFrost:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) or S.Icecap:IsAvailable()) then
      if HR.Cast(S.PillarofFrost, Settings.Frost.GCDasOffGCD.PillarofFrost) then return "pillar_of_frost 433"; end
    end
    -- breath_of_sindragosa,use_off_gcd=1,if=cooldown.empower_rune_weapon.remains&cooldown.pillar_of_frost.remains
    if S.BreathofSindragosa:IsCastableP() and (bool(S.EmpowerRuneWeapon:CooldownRemainsP()) and bool(S.PillarofFrost:CooldownRemainsP())) then
      if HR.Cast(S.BreathofSindragosa, nil, Settings.Frost.BoSDisplayStyle, 12) then return "breath_of_sindragosa 434"; end
    end
    -- empower_rune_weapon,if=cooldown.pillar_of_frost.ready&talent.obliteration.enabled&rune.time_to_5>gcd&runic_power.deficit>=10|target.1.time_to_die<20
    if S.EmpowerRuneWeapon:IsCastableP() and (S.PillarofFrost:CooldownUpP() and S.Obliteration:IsAvailable() and Player:RuneTimeToX(5) > Player:GCD() and Player:RunicPowerDeficit() >= 10 or Target:TimeToDie() < 20) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 435"; end
    end
    -- empower_rune_weapon,if=(cooldown.pillar_of_frost.ready|target.1.time_to_die<20)&talent.breath_of_sindragosa.enabled&runic_power>60
    if S.EmpowerRuneWeapon:IsCastableP() and ((S.PillarofFrost:CooldownUpP() or Target:TimeToDie() < 20) and S.BreathofSindragosa:IsAvailable() and Player:RunicPower() > 60) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 436"; end
    end
    -- empower_rune_weapon,if=talent.icecap.enabled&rune<3
    if S.EmpowerRuneWeapon:IsCastableP() and (S.Icecap:IsAvailable() and Player:Rune() < 3) then
      if HR.Cast(S.EmpowerRuneWeapon, Settings.Frost.GCDasOffGCD.EmpowerRuneWeapon) then return "empower_rune_weapon 437"; end
    end
    -- call_action_list,name=cold_heart,if=talent.cold_heart.enabled&((buff.cold_heart.stack>=10&debuff.razorice.stack=5)|target.1.time_to_die<=gcd)
    if (S.ColdHeart:IsAvailable() and ((Player:BuffStackP(S.ColdHeartBuff) >= 10 and Target:DebuffStackP(S.RazoriceDebuff) == 5) or Target:TimeToDie() <= Player:GCD())) then
      local ShouldReturn = ColdHeart(); if ShouldReturn then return ShouldReturn; end
    end
    -- frostwyrms_fury,if=(buff.pillar_of_frost.up&azerite.icy_citadel.rank<=1&(buff.pillar_of_frost.remains<=gcd|buff.unholy_strength.remains<=gcd&buff.unholy_strength.up))
    if S.FrostwyrmsFury:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() <= 1 and (Player:BuffRemainsP(S.PillarofFrostBuff) <= Player:GCD() or Player:BuffRemainsP(S.UnholyStrengthBuff) <= Player:GCD() and Player:BuffP(S.UnholyStrengthBuff))) then
      if HR.Cast(S.FrostwyrmsFury, Settings.Frost.GCDasOffGCD.FrostwyrmsFury, nil, 40) then return "frostwyrms_fury 437"; end
    end
    -- frostwyrms_fury,if=(buff.icy_citadel.up&!talent.icecap.enabled&(buff.unholy_strength.up|buff.icy_citadel.remains<=gcd))|buff.icy_citadel.up&buff.icy_citadel.remains<=gcd&talent.icecap.enabled&buff.pillar_of_frost.up
    if S.FrostwyrmsFury:IsCastableP() and ((Player:BuffP(S.IcyCitadelBuff) and not S.Icecap:IsAvailable() and (Player:BuffP(S.UnholyStrengthBuff) or Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD())) or Player:BuffP(S.IcyCitadelBuff) and Player:BuffRemainsP(S.IcyCitadelBuff) <= Player:GCD() and S.Icecap:IsAvailable() and Player:BuffP(S.PillarofFrostBuff)) then
      if HR.Cast(S.FrostwyrmsFury, Settings.Frost.GCDasOffGCD.FrostwyrmsFury, nil, 40) then return "frostwyrms_fury 439"; end
    end
    -- frostwyrms_fury,if=target.1.time_to_die<gcd|(target.1.time_to_die<cooldown.pillar_of_frost.remains&buff.unholy_strength.up)
    if S.FrostwyrmsFury:IsCastableP() and (Target:TimeToDie() < Player:GCD() or (Target:TimeToDie() < S.PillarofFrost:CooldownRemainsP() and Player:BuffP(S.UnholyStrengthBuff))) then
      if HR.Cast(S.FrostwyrmsFury, Settings.Frost.GCDasOffGCD.FrostwyrmsFury, nil, 40) then return "frostwyrms_fury 441"; end
    end
  end
  Essences = function()
    -- blood_of_the_enemy,if=buff.pillar_of_frost.up&(buff.pillar_of_frost.remains<10&(buff.breath_of_sindragosa.up|talent.obliteration.enabled|talent.icecap.enabled&!azerite.icy_citadel.enabled)|buff.icy_citadel.up&talent.icecap.enabled)
    if S.BloodoftheEnemy:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) and (Player:BuffRemainsP(S.PillarofFrostBuff) < 10 and (Player:BuffP(S.BreathofSindragosa) or S.Obliteration:IsAvailable() or S.Icecap:IsAvailable() and not S.IcyCitadel:AzeriteEnabled()) or Player:BuffP(S.IcyCitadelBuff) and S.Icecap:IsAvailable())) then
      if HR.Cast(S.BloodoftheEnemy, nil, Settings.Commons.EssenceDisplayStyle, 12) then return "blood_of_the_enemy 501"; end
    end
    -- guardian_of_azeroth,if=!talent.icecap.enabled|talent.icecap.enabled&azerite.icy_citadel.enabled&buff.pillar_of_frost.remains<6&buff.pillar_of_frost.up|talent.icecap.enabled&!azerite.icy_citadel.enabled
    if S.GuardianofAzeroth:IsCastableP() and (not S.Icecap:IsAvailable() or S.Icecap:IsAvailable() and S.IcyCitadel:AzeriteEnabled() and Player:BuffRemainsP(S.PillarofFrostBuff) < 6 and Player:BuffP(S.PillarofFrostBuff) or S.Icecap:IsAvailable() and not S.IcyCitadel:AzeriteEnabled()) then
      if HR.Cast(S.GuardianofAzeroth, nil, Settings.Commons.EssenceDisplayStyle) then return "guardian_of_azeroth 503"; end
    end
    -- chill_streak,if=buff.pillar_of_frost.remains<5&buff.pillar_of_frost.up|target.1.time_to_die<5
    if S.ChillStreak:IsCastableP() and (Player:BuffRemainsP(S.PillarofFrostBuff) < 5 and Player:BuffP(S.PillarofFrostBuff) or Target:TimeToDie() < 5) then
      if HR.Cast(S.ChillStreak, nil, Settings.Commons.EssenceDisplayStyle, 40) then return "chill_streak 505"; end
    end
    -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<11
    if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounter) < 11) then
      if HR.Cast(S.TheUnboundForce, nil, Settings.Commons.EssenceDisplayStyle, 40) then return "the_unbound_force 507"; end
    end
    -- focused_azerite_beam,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.FocusedAzeriteBeam:IsCastableP() and (Player:BuffDownP(S.PillarofFrostBuff) and Player:BuffDownP(S.BreathofSindragosa)) then
      if HR.Cast(S.FocusedAzeriteBeam, nil, Settings.Commons.EssenceDisplayStyle) then return "focused_azerite_beam 509"; end
    end
    -- concentrated_flame,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up&dot.concentrated_flame_burn.remains=0
    if S.ConcentratedFlame:IsCastableP() and (Player:BuffDownP(S.PillarofFrostBuff) and Player:BuffDownP(S.BreathofSindragosa) and Target:DebuffDownP(S.ConcentratedFlameBurn)) then
      if HR.Cast(S.ConcentratedFlame, nil, Settings.Commons.EssenceDisplayStyle, 40) then return "concentrated_flame 511"; end
    end
    -- purifying_blast,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.PurifyingBlast:IsCastableP() and (Player:BuffDownP(S.PillarofFrostBuff) and Player:BuffDownP(S.BreathofSindragosa)) then
      if HR.Cast(S.PurifyingBlast, nil, Settings.Commons.EssenceDisplayStyle, 40) then return "purifying_blast 513"; end
    end
    -- worldvein_resonance,if=buff.pillar_of_frost.up|buff.empower_rune_weapon.up|cooldown.breath_of_sindragosa.remains>60+15
    if S.WorldveinResonance:IsCastableP() and (Player:BuffP(S.PillarofFrostBuff) or Player:BuffP(S.EmpowerRuneWeaponBuff) or S.BreathofSindragosa:CooldownRemainsP() > 75) then
      if HR.Cast(S.WorldveinResonance, nil, Settings.Commons.EssenceDisplayStyle) then return "worldvein_resonance 515"; end
    end
    -- ripple_in_space,if=!buff.pillar_of_frost.up&!buff.breath_of_sindragosa.up
    if S.RippleInSpace:IsCastableP() and (Player:BuffDownP(S.PillarofFrostBuff) and Player:BuffDownP(S.BreathofSindragosa)) then
      if HR.Cast(S.RippleInSpace, nil, Settings.Commons.EssenceDisplayStyle) then return "ripple_in_space 517"; end
    end
    -- memory_of_lucid_dreams,if=buff.empower_rune_weapon.remains<5&buff.breath_of_sindragosa.up|(rune.time_to_2>gcd&runic_power<50)
    if S.MemoryofLucidDreams:IsCastableP() and (Player:BuffRemainsP(S.EmpowerRuneWeaponBuff) < 5 and Player:BuffP(S.BreathofSindragosa) or (Player:RuneTimeToX(2) > Player:GCD() and Player:RunicPower() < 50)) then
      if HR.Cast(S.MemoryofLucidDreams, nil, Settings.Commons.EssenceDisplayStyle) then return "memory_of_lucid_dreams 519"; end
    end
    -- reaping_flames
    if S.ReapingFlames:IsCastableP() then
      if HR.Cast(S.ReapingFlames, nil, Settings.Commons.EssenceDisplayStyle, 40) then return "reaping_flames 521"; end
    end
  end
  Obliteration = function()
    -- remorseless_winter,if=talent.gathering_storm.enabled
    if S.RemorselessWinter:IsCastableP() and (S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.RemorselessWinter, nil, nil, 8) then return "remorseless_winter 601"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable() and Player:BuffDownP(S.RimeBuff) and Cache.EnemiesCount[10] >= 3) then
      if HR.Cast(S.Obliterate) then return "obliterate 603"; end
    end
    -- obliterate,if=!talent.frostscythe.enabled&!buff.rime.up&spell_targets.howling_blast>=3
    if S.Obliterate:IsCastableP("Melee") and (not S.Frostscythe:IsAvailable() and Player:BuffDownP(S.RimeBuff) and Cache.EnemiesCount[10] >= 3) then
      if HR.Cast(S.Obliterate) then return "obliterate 605"; end
    end
    -- frostscythe,if=(buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance)))&spell_targets.frostscythe>=2
    if S.Frostscythe:IsCastableP() and ((bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) and Cache.EnemiesCount[8] >= 2) then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 607"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
      if HR.Cast(S.Obliterate) then return "obliterate 609"; end
    end
    -- obliterate,if=buff.killing_machine.react|(buff.killing_machine.up&(prev_gcd.1.frost_strike|prev_gcd.1.howling_blast|prev_gcd.1.glacial_advance))
    if S.Obliterate:IsCastableP("Melee") and (bool(Player:BuffStackP(S.KillingMachineBuff)) or (Player:BuffP(S.KillingMachineBuff) and (Player:PrevGCDP(1, S.FrostStrike) or Player:PrevGCDP(1, S.HowlingBlast) or Player:PrevGCDP(1, S.GlacialAdvance)))) then
      if HR.Cast(S.Obliterate) then return "obliterate 611"; end
    end
    -- glacial_advance,if=(!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd)&spell_targets.glacial_advance>=2
    if no_heal and S.GlacialAdvance:IsReadyP() and ((Player:BuffDownP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) and Cache.EnemiesCount[10] >= 2) then
      if HR.Cast(S.GlacialAdvance, nil, nil, 100) then return "glacial_advance 613"; end
    end
    -- howling_blast,if=buff.rime.up&spell_targets.howling_blast>=2
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff) and Cache.EnemiesCount[10] >= 2) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 615"; end
    end
    -- frost_strike,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd&!talent.frostscythe.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and Player:BuffDownP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD() and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 617"; end
    end
    -- frost_strike,if=!buff.rime.up|runic_power.deficit<10|rune.time_to_2>gcd
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:BuffDownP(S.RimeBuff) or Player:RunicPowerDeficit() < 10 or Player:RuneTimeToX(2) > Player:GCD()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 619"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 621"; end
    end
    -- obliterate,target_if=(debuff.razorice.stack<5|debuff.razorice.remains<10)&!talent.frostscythe.enabled
    if S.Obliterate:IsCastableP("Melee") and ((Target:DebuffStackP(S.RazoriceDebuff) < 5 or Target:DebuffRemainsP(S.RazoriceDebuff) < 10) and not S.Frostscythe:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 623"; end
    end
    -- obliterate
    if S.Obliterate:IsCastableP("Melee") then
      if HR.Cast(S.Obliterate) then return "obliterate 625"; end
    end
  end
  Standard = function()
    -- remorseless_winter
    if S.RemorselessWinter:IsCastableP() then
      if HR.Cast(S.RemorselessWinter, nil, nil, 8) then return "remorseless_winter 701"; end
    end
    -- frost_strike,if=cooldown.remorseless_winter.remains<=2*gcd&talent.gathering_storm.enabled
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (S.RemorselessWinter:CooldownRemainsP() <= 2 * Player:GCD() and S.GatheringStorm:IsAvailable()) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 703"; end
    end
    -- howling_blast,if=buff.rime.up
    if S.HowlingBlast:IsCastableP(30, true) and (Player:BuffP(S.RimeBuff)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 705"; end
    end
    -- obliterate,if=talent.icecap.enabled&buff.pillar_of_frost.up&azerite.icy_citadel.rank>=2
    if S.Obliterate:IsCastableP("Melee") and (S.Icecap:IsAvailable() and Player:BuffP(S.PillarofFrostBuff) and S.IcyCitadel:AzeriteRank() >= 2) then
      if HR.Cast(S.Obliterate) then return "obliterate 706"; end
    end
    -- obliterate,if=!buff.frozen_pulse.up&talent.frozen_pulse.enabled
    if S.Obliterate:IsCastableP("Melee") and (Player:BuffDownP(S.FrozenPulseBuff) and S.FrozenPulse:IsAvailable()) then
      if HR.Cast(S.Obliterate) then return "obliterate 707"; end
    end
    -- frost_strike,if=runic_power.deficit<(15+talent.runic_attenuation.enabled*3)
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:RunicPowerDeficit() < (15 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 709"; end
    end
    -- frostscythe,if=buff.killing_machine.up&rune.time_to_4>=gcd
    if S.Frostscythe:IsCastableP() and (Player:BuffP(S.KillingMachineBuff) and Player:RuneTimeToX(4) >= Player:GCD()) then
      if HR.Cast(S.Frostscythe, nil, nil, 8) then return "frostscythe 711"; end
    end
    -- obliterate,if=runic_power.deficit>(25+talent.runic_attenuation.enabled*3)
    if S.Obliterate:IsCastableP("Melee") and (Player:RunicPowerDeficit() > (25 + num(S.RunicAttenuation:IsAvailable()) * 3)) then
      if HR.Cast(S.Obliterate) then return "obliterate 713"; end
    end
    -- frost_strike
    if no_heal and S.FrostStrike:IsReadyP("Melee") then
      if HR.Cast(S.FrostStrike) then return "frost_strike 715"; end
    end
    -- horn_of_winter
    if S.HornofWinter:IsCastableP() then
      if HR.Cast(S.HornofWinter, Settings.Frost.GCDasOffGCD.HornofWinter) then return "horn_of_winter 717"; end
    end
    -- arcane_torrent
    if S.ArcaneTorrent:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.ArcaneTorrent, Settings.Commons.OffGCDasOffGCD.Racials) then return "arcane_torrent 719"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- use DeathStrike on low HP or with proc in Solo Mode
    if S.DeathStrike:IsReadyP("Melee") and not no_heal then
      if HR.Cast(S.DeathStrike) then return "death_strike low hp or proc"; end
    end
    -- Interrupts
    Everyone.Interrupt(15, S.MindFreeze, Settings.Commons.OffGCDasOffGCD.MindFreeze, false);
    -- auto_attack
    -- howling_blast,if=!dot.frost_fever.ticking&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if S.HowlingBlast:IsCastableP(30, true) and (Target:DebuffDownP(S.FrostFeverDebuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.HowlingBlast) then return "howling_blast 1"; end
    end
    -- glacial_advance,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&spell_targets.glacial_advance>=2&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if no_heal and S.GlacialAdvance:IsReadyP() and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and Cache.EnemiesCount[10] >= 2 and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.GlacialAdvance, nil, nil, 100) then return "glacial_advance 3"; end
    end
    -- frost_strike,if=buff.icy_talons.remains<=gcd&buff.icy_talons.up&(!talent.breath_of_sindragosa.enabled|cooldown.breath_of_sindragosa.remains>15)
    if no_heal and S.FrostStrike:IsReadyP("Melee") and (Player:BuffRemainsP(S.IcyTalonsBuff) <= Player:GCD() and Player:BuffP(S.IcyTalonsBuff) and (not S.BreathofSindragosa:IsAvailable() or S.BreathofSindragosa:CooldownRemainsP() > 15)) then
      if HR.Cast(S.FrostStrike) then return "frost_strike 5"; end
    end
    -- call_action_list,name=essences
    if (true) then
      local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=cooldowns
    if (HR.CDsON()) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&((cooldown.breath_of_sindragosa.remains=0&cooldown.pillar_of_frost.remains<10)|(cooldown.breath_of_sindragosa.remains<20&target.1.time_to_die<35))
    if (not Settings.Frost.DisableBoSPooling and S.BreathofSindragosa:IsAvailable() and ((S.BreathofSindragosa:CooldownRemainsP() == 0 and S.PillarofFrost:CooldownRemainsP() < 10) or (S.BreathofSindragosa:CooldownRemainsP() < 20 and Target:TimeToDie() < 35))) then
      return BosPooling();
    end
    -- run_action_list,name=bos_ticking,if=buff.breath_of_sindragosa.up
    if (Player:BuffP(S.BreathofSindragosa)) then
      return BosTicking();
    end
    -- run_action_list,name=obliteration,if=buff.pillar_of_frost.up&talent.obliteration.enabled
    if (Player:BuffP(S.PillarofFrostBuff) and S.Obliteration:IsAvailable()) then
      return Obliteration();
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if HR.AoEON() and Cache.EnemiesCount[10] >= 2 then
      return Aoe();
    end
    -- call_action_list,name=standard
    if (true) then
      local ShouldReturn = Standard(); if ShouldReturn then return ShouldReturn; end
    end
    -- nothing to cast, wait for resouces
    if HR.CastAnnotated(S.PoolRange, false, "WAIT") then return "Wait/Pool Resources"; end
  end
end

local function Init ()
  HL.RegisterNucleusAbility(196770, 8, 6)               -- Remorseless Winter
  HL.RegisterNucleusAbility(207230, 8, 6)               -- Frostscythe
  HL.RegisterNucleusAbility(49184, 10, 6)               -- Howling Blast
end

HR.SetAPL(251, APL, Init)
