--Supreme King of the Seven Seas
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x6a4),2)
	c:EnableReviveLimit()
	--Gain Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

function s.filter(c)
	return c:IsType(TYPE_XYZ)
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.filter,1,nil) then
		--Your opponent cannot target with card effects.
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.imtg)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e:GetHandler():RegisterEffect(e1)
	end
end
function s.imtg(e,c)
	return c:IsSetCard(0x6a4) and c~=e:GetHandler()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.setfilter(c)
	return c:IsSetCard(0x6a4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local tg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE,0,nil)
	if ct<=0 or ft<=0 or #tg==0 then return end
	if ct>ft then ct=ft end
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local setg=tg:Select(tp,1,ct,nil)
		Duel.SSet(tp,setg)
	end
end
