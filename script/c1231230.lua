--Argorok, Twilit Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Special Summoned.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	--Tribute requires
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(s.tlimit)
	c:RegisterEffect(e2)
	--Summon with 3 Tribute
	local e3=aux.AddNormalSummonProcedure(c,true,false,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local e4=aux.AddNormalSetProcedure(c)
	--Summon cannot be negated
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e5)
	--Once per turn, destroy all other cards on the field
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
	--Set LP to 4000 if is destroyed on the field
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetCondition(s.lpcon)
	e7:SetOperation(s.lpop)
	c:RegisterEffect(e7)
end
function s.tlimit(e,c)
	return not c:IsRace(RACE_DRAGON+RACE_WINGEDBEAST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and Duel.GetLP(tp)<4000
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,4000)
end