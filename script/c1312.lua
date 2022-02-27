--Souls' Swordmaster
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter1,s.fusfilter2,s.fusfilter3,s.fusfilter4)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--spsummon success
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	--Destroy 1 Equip Spell to destroy all cards in the column of that card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--atkup
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
end
function s.fusfilter1(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:IsType(TYPE_FUSION,fc,sumtype,tp)
end
function s.fusfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:IsType(TYPE_SYNCHRO,fc,sumtype,tp)
end
function s.fusfilter3(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:IsType(TYPE_XYZ,fc,sumtype,tp)
end
function s.fusfilter4(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:IsType(TYPE_LINK,fc,sumtype,tp)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() end,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.eqfilter(c,g)
	return c:IsType(TYPE_EQUIP) and g:IsExists(s.eqcheck,1,nil,c)
end
function s.eqcheck(c,ec)
	return ec:CheckEquipTarget(c)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local eq=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_GRAVE,0,nil,c)
	if ft>#eq then ft=#eq end
	if ft==0 then return end
	for i=1,ft do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local ec=eq:Select(tp,1,1,nil):GetFirst()
		eq:RemoveCard(ec)
		local tc=c:FilterSelect(tp,s.eqcheck,1,1,nil,ec):GetFirst()
		Duel.Equip(tp,ec,tc,true,true)
	end
	Duel.EquipComplete()
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP) 
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_SZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_SZONE,1,1,nil)
	local dg=g:GetColumnGroup():Filter(Card.IsFaceup,g,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		if #dg>0 then
			Duel.BreakEffect()
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.Destroy(dg,REASON_EFFECT)~=0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				if #sg>0 then
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_SZONE,0,nil,TYPE_EQUIP)*700
end