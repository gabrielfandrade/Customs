--Protector of the Seven Seas
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

function s.mfilter(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,lc,sumtype,tp) and c:IsLevel(5)
end

function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end