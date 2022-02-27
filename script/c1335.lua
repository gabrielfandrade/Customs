--The Great Samurai - Moruka
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Link summon procedure
	Link.AddProcedure(c,s.mfilter,2,nil,s.matcheck)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.mfilter(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_WARRIOR)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:GetClassCount(Card.GetLevel)==1
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ac=Duel.GetMatchingGroupCount(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<ac then ac=ft end
	if ac==0 then return end
	if ac>2 then ac=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,ac,nil)
	local ac2=Duel.Destroy(dg,REASON_EFFECT)
	if ac2>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ac2,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end