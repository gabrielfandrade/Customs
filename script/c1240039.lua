--Nabooru
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,99,s.matfilter)
	c:EnableReviveLimit()
	--Negate the effect of opponent's activated monster effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	-- Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.chcon)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
end
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x4d8,scard,sumtype,tp)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4d8)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x4d8)
end
function s.chcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_FZONE,0,1,nil)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.filter(c)
	return c:IsType(TYPE_FIELD)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP then
		c:CancelToGrave(false)
	end
	local g=Duel.GetMatchingGroup(aux.TRUE,0,LOCATION_FZONE,LOCATION_FZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end