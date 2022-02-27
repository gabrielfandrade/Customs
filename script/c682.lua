--The Seven Stars of Darkness
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--Prevent negation
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.econ)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--You cannot activate monster effects during the battle phase
	--Cannot activate effects
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.accon)
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)
end
function s.costfilter1(c)
	return (c:IsSetCard(0x4602) or c:IsCode(44330098)) 
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.costfilter2(c)
	return (c:IsSetCard(0x4602) or c:IsCode(44330098)) 
		and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.DiscardHand(tp,s.costfilter2,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	Duel.RegisterEffect(e1,p)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return te:IsActiveType(TYPE_MONSTER) and (tc:IsSetCard(0x4602) or tc:IsCode(44330098))
end
function s.econ(e)
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_MZONE,0)<=1
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.accon(e)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_MZONE,0)>=2
		and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end