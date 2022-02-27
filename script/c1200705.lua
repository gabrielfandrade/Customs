--Herald of Parahax Trey
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c,s.pfilter)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
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
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x4f6)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsFaceup() and tc:IsType(TYPE_RITUAL) and Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL then
		e:SetLabelObject(tc)
		return true 
	end
	if bc:IsFaceup() and bc:IsType(TYPE_RITUAL) and Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL then
		e:SetLabelObject(bc)
		return true 
	else return false end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end