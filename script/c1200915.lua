--Gabriel, The Creation
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	if not c:IsStatus(STATUS_COPYING_EFFECT) then
		Fusion.AddContactProc(c,s.contactfil,s.contactop,aux.FALSE)
		if c.material_count==nil then
			s.material_count=2
			s.material={1200911,680}
			s.min_material_count=2
			s.max_material_count=2
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_FUSION_MATERIAL)
		e1:SetCondition(Fusion.ConditionMix(true,true,s.ffilter(1200911),s.ffilter(680)))
		e1:SetOperation(Fusion.OperationMix(true,true,s.ffilter(1200911),s.ffilter(680)))
		c:RegisterEffect(e1)
	end
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--actlimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	--atk
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_CONFIRM)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.ffilter(code)
	return function(c,fc,sub,sub2,mg,sg,tp,contact)
		if contact then
			return c:IsOriginalCode(code)
		else
			return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) or (sub and c:CheckFusionSubstitute(fc)) or (sub2 and c:IsHasEffect(511002961))
		end
	end
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetAttack()+4000~=c:GetAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetAttack()+4000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end