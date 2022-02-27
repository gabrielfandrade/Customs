--Fortune Lady Miss Element
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x31),2)
	--atk,def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	--level up
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(s.lvcon)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.value(e,c)
	return c:GetLevel()*400
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsLevelAbove(1) and e:GetHandler():IsLevelBelow(11)
end

function s.thfilter(c)
	return c:IsSetCard(0x31) and c:IsAbleToHand()
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lvl=c:GetLevel()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	e:SetLabel(e:GetHandler():GetLevel())
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsLevelAbove(1) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(lv)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)==lv and aux.dpcheck(Card.GetAttribute)
	end 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,nil,e,tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) end
		return #g>0 and ft>0 and aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(e:GetHandler():GetLevel()),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) end
	if #g==0 or ft==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(e:GetLabel()),1,tp,HINTMSG_SPSUMMON)
	if #sg==0 then return end
	local fid=e:GetHandler():GetFieldID()
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end