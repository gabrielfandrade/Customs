--Changes and Charges
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)

	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	--Register can only attack with 1 monster
	--Prevents other attacks
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local off=1
	local ops={}
	local opval={}
	if s.pdtg(e,tp,eg,ep,ev,re,r,rp,0) then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if s.dbtg(e,tp,eg,ep,ev,re,r,rp,0) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if s.xyztg(e,tp,eg,ep,ev,re,r,rp,0) then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	if chk==0 then return off>1 end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.pdop)
		s.pdtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif opval[op]==2 then
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.dbop)
		s.dbtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif opval[op]==3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.xyzop)
		s.xyztg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.pdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
function s.pdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.pdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.pdfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.pdfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.pdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		--Inflict piercing damage
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetValue(DOUBLE_DAMAGE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.dbfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:GetFlagEffect(id)==0
end
function s.dbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.dbfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dbfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.dbop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense()*2)
		tc:RegisterEffect(e2)
	end
end
	--Check for a Machine Xyz monster
function s.xyzfilter(c,e,tp)
	local rk=c:GetRank()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and c:IsFaceup() and c:IsRace(RACE_MACHINE) and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetOriginalCode(),rk,pg)
end
	--Check for other Machine Xyz monster
function s.xyzfilter2(c,e,tp,mc,code,rank,pg)
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ) and c:IsRace(RACE_MACHINE) and not c:IsOriginalCode(code) and c:GetRank()==rank and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and mc:IsCanBeXyzMaterial(c,tp) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode(),tc:GetRank(),pg)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

function s.atkcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=Duel.GetFlagEffectLabel(e:GetHandlerPlayer(),id)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	local p=eg:GetFirst():GetControler()
	if Duel.GetFlagEffect(p,id)~=0 and Duel.GetFlagEffectLabel(p,id)~=fid then
		Duel.SetFlagEffectLabel(p,id,0)
	else
		Duel.RegisterFlagEffect(p,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
end
