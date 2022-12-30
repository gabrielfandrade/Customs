--Existence of the Elements
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),nil,s.fextra)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
	--Fusion
	local e2=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x3e7),Fusion.OnFieldMat,s.fextra2,Fusion.BanishMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
function s.filterchk(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7) and c:IsOnField()
end
function s.fcheck(tp,sg,fc)
	if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		return sg:IsExists(s.filterchk,1,nil) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filterchk,1,nil) then
		local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.fextra2(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
end