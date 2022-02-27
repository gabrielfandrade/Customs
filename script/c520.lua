--Flamvel Dragoon of the Ardent Flames
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),3,2)
	c:EnableReviveLimit()
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.damcost)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--cannot direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local td=Duel.GetAttacker()
	if td==tc then td=tc:GetAttackTarget() end
	return tc:IsAttribute(ATTRIBUTE_FIRE) and not td:IsAttribute(ATTRIBUTE_FIRE) and tc:IsRelateToBattle() and tc:IsStatus(STATUS_OPPO_BATTLE)
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.damfilter(c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local gc=Duel.GetMatchingGroupCount(s.damfilter,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return gc>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,gc*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local gc=Duel.GetMatchingGroupCount(s.damfilter,tp,0,LOCATION_GRAVE,nil)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,gc*300,REASON_EFFECT)
end