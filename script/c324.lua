--Attack of Beasts at Night's Edge
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if tp==ep or not Duel.IsChainNegatable(ev) then return false end
	if not (re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local ph=Duel.GetCurrentPhase()
	return ((ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0) or (tg and tg:IsExists(s.cfilter,1,nil) and Duel.IsChainNegatable(ev))) and ph>PHASE_MAIN1 and ph<PHASE_MAIN2
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
		if #g>0 then
			local fid=e:GetHandler():GetFieldID()
			local tc=g:GetFirst()
			for tc in aux.Next(g) do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
			end
			Duel.SpecialSummonComplete()
			g:KeepAlive()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(g)
			e1:SetCondition(s.descon)
			e1:SetOperation(s.desop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	Duel.Destroy(tg,REASON_EFFECT)
end