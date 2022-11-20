--Herald of Parahax Ace
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	Pendulum.AddProcedure(c,s.pfilter)
	--ritual summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.rfilter,location=LOCATION_HAND+LOCATION_EXTRA,extrafil=s.extrafil,extraop=s.extraop})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	c:RegisterEffect(e1)
	--cannot be responsed
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--tohand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.tetg)
	e3:SetOperation(s.teop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e4)
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

function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:GetFlagEffect(id)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:GetFlagEffect(id)==0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(0,1)
			e1:SetCondition(s.actcon)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end

function s.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoExtraP(g,tp,REASON_EFFECT)
	end
end