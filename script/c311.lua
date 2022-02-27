--Metal Killer Witch Wolf
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerCanAdditionalSummon(tp)
end
function s.desfilter(c,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
		and Duel.IsPlayerCanSummon(tp) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x12c))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end