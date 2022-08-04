--Celestial Azure Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,3,s.lcheck)
	--pendulum
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM,lc,sumtype,tp)
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.checkop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	s.checkop(e,tp)
end

function s.checkop(e,tp)
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz~=nil and lpz:GetFlagEffect(id)<=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_PZONE)
		e1:SetCondition(s.pencon1)
		e1:SetOperation(s.penop1)
		e1:SetValue(SUMMON_TYPE_PENDULUM)
		e1:SetReset(RESET_PHASE+PHASE_END)
		lpz:RegisterEffect(e1)
		lpz:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
	local olpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
	local orpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if olpz~=nil and orpz~=nil and olpz:GetFlagEffect(id)<=0
		and olpz:GetFlagEffectLabel(31531170)==orpz:GetFieldID()
		and orpz:GetFlagEffectLabel(31531170)==olpz:GetFieldID() then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SPSUMMON_PROC_G)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_BOTH_SIDE)
		e2:SetRange(LOCATION_PZONE)
		e2:SetCondition(s.pencon2)
		e2:SetOperation(s.penop2)
		e2:SetValue(SUMMON_TYPE_PENDULUM)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		olpz:RegisterEffect(e2)
		olpz:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.pencon1(e,c,og)
	if c==nil then return Duel.GetCurrentPhase()==PHASE_MAIN2 end
	local tp=c:GetControler()
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,29432356)>0 then return false end
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local ft=Duel.GetLocationCountFromEx(tp)
	if ft<=0 then return false end
	if og then
		return og:Filter(Card.IsLocation,nil,LOCATION_EXTRA):IsExists(Pendulum.Filter,1,nil,e,tp,lscale,rscale)
	else
		return Duel.IsExistingMatchingCard(Pendulum.Filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lscale,rscale)
	end
end
function s.penop1(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local ft=Duel.GetLocationCountFromEx(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
	if og then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=og:Filter(Card.IsLocation,nil,LOCATION_EXTRA):FilterSelect(tp,Pendulum.Filter,0,ft,nil,e,tp,lscale,rscale)
		if g then
			sg:Merge(g)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,Pendulum.Filter,tp,LOCATION_EXTRA,0,0,ft,nil,e,tp,lscale,rscale)
		if g then
			sg:Merge(g)
		end
	end
	if #sg>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,29432356,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
		Duel.HintSelection(c,true)
		Duel.HintSelection(rpz,true)
	end
end
function s.pencon2(e,c,og)
	if c==nil then return true end
	local tp=e:GetOwnerPlayer()
	local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if rpz==nil or rpz:GetFieldID()~=c:GetFlagEffectLabel(31531170) or Duel.GetFlagEffect(tp,29432356)>0 then return false end
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local ft=Duel.GetLocationCountFromEx(tp)
	if ft<=0 then return false end
	if og then
		return og:Filter(Card.IsLocation,nil,LOCATION_EXTRA):IsExists(Pendulum.Filter,1,nil,e,tp,lscale,rscale)
	else
		return Duel.IsExistingMatchingCard(Pendulum.Filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lscale,rscale)
	end
end
function s.penop2(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local tp=e:GetOwnerPlayer()
	local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local ft=Duel.GetLocationCountFromEx(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
	if og then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=og:FilterSelect(tp,Pendulum.Filter,0,ft,nil,e,tp,lscale,rscale)
		if g then
			sg:Merge(g)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,Pendulum.Filter,tp,LOCATION_EXTRA,0,0,ft,nil,e,tp,lscale,rscale)
		if g then
			sg:Merge(g)
		end
	end
	if #sg>0 then
		Duel.Hint(HINT_CARD,0,31531170)
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,29432356,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
		Duel.HintSelection(c,true)
		Duel.HintSelection(rpz,true)
	end
end

function s.tdfilter(c,ft)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToDeck() and (ft>0 or c:GetSequence()<5)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tdfilter(chkc,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		and ft>-1 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
