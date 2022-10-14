--Night End Ruler Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--synchro summon
	Synchro.AddProcedure(c,matfilter,1,99,Synchro.NonTunerEx(s.matfilter),1,99)
	--must first be synchro summoned
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Special summon itself from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

function s.matfilter(c,val,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,scard,sumtype,tp) 
		and c:IsType(TYPE_SYNCHRO,scard,sumtype,tp)
end

function s.rmfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(1000)
		and c:IsAbleToRemove() and aux.SpElimFilter(c,true,true)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	if g:GetFirst():IsType(TYPE_SYNCHRO) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,1,1,0,0)
	else 
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,1,1,0,0)
	end
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and tp==ep
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local mtgc=tc:GetTextAttack()//1000
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		if tc:IsType(TYPE_SYNCHRO) then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectTarget(tp,nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,mtgc,nil)
			if #g>0 then
				local oc=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
				if oc>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(oc*1000)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
					c:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_UPDATE_DEFENSE)
					e2:SetValue(oc*1000)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
					c:RegisterEffect(e2)
				end
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectTarget(tp,nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,mtgc,nil)
			if #g>0 then
				local oc=Duel.Destroy(g,REASON_EFFECT)
				if oc>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(oc*1000)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
					c:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_UPDATE_DEFENSE)
					e2:SetValue(oc*1000)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
					c:RegisterEffect(e2)
				end
			end
		end
	end
end

function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) and sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,1,nil,chk) end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,1,nil,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	--Location count handled in cost rescon due to "Spirit Elimination"
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
