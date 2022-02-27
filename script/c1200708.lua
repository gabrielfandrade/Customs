--Herald of Parahax Cinque - LB
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c,s.pfilter)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--toextra
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCondition(s.tecon)
	e4:SetTarget(s.tetg)
	e4:SetOperation(s.teop)
	c:RegisterEffect(e4)
--ritual summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.rfilter,location=LOCATION_HAND+LOCATION_EXTRA,extrafil=s.extrafil,extraop=s.extraop})
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	c:RegisterEffect(e1)
end
function s.rfilter(c)
	return not c:IsRace(RACE_WARRIOR)
end
function s.exmatfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.exmatfilter,tp,LOCATION_EXTRA,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(s.exmatfilter,nil,LOCATION_EXTRA)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.pfilter(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0x4f6)
end
function s.filter(c)
	return c:IsFacedown()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function s.tecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RITUAL)
end
function s.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.SendtoExtraP(g,tp,REASON_EFFECT)
	end
end