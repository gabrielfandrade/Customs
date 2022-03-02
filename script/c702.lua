--カオス・ソルジャー －宵闇の使者－
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	e3:SetLabel(TYPE_SPELL)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetLabel(TYPE_TRAP)
	c:RegisterEffect(e4)
end
function s.spfilter(c,att)
	return c:IsType(att) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ct=Duel.GetMatchingGroupCount(Card.isType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ct>0 and ct==Duel.GetMatchingGroupCount(Card.isType,tp,LOCATION_GRAVE,0,nil,TYPE_TRAP)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,ct,nil,e:GetLabel())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e:GetLabel())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetLabelObject():SetLabel(e:GetLabel())
end