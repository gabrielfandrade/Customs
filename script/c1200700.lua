--Herald of Parahax Cater
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c,s.pfilter)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.indtg)
	e2:SetOperation(s.indop)
	c:RegisterEffect(e2)
	--ritual summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.rfilter,location=LOCATION_HAND+LOCATION_EXTRA,extrafil=s.extrafil,extraop=s.extraop})
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	c:RegisterEffect(e1)
end
function s.rfilter(c)
	return not c:IsRace(RACE_SPELLCASTER)
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
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x4f6)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end