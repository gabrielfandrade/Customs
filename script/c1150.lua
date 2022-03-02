--インヴェルズ・グレズ
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,s.unique)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--tribute limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(s.tlimit)
	c:RegisterEffect(e2)
	--summon with 3 tribute
	local e3=aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local e4=aux.AddNormalSetProcedure(c)
	--summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e5)
	--attack all
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_ATTACK_ALL)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--atk/def down
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_SET_ATTACK_FINAL)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,LOCATION_MZONE)
	e7:SetCondition(s.adcon)
	e7:SetTarget(s.adtg)
	e7:SetValue(s.atkval)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e8:SetValue(s.defval)
	c:RegisterEffect(e8)
end
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsRace(RACE_FIEND)
end
function s.tlimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
function s.unique(c)
	return c:IsSetCard(0x460)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(1100)
end
function s.adcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and e:GetHandler():GetBattleTarget()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.adtg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
function s.atkval(e,c)
	return c:GetAttack()/2
end
function s.defval(e,c)
	return c:GetDefense()/2
end