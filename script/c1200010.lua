--Alternative Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.ffilter,nil,s.fextra)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_names={89631139}
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
end
function s.filterchk(c)
	return c:IsFaceup() and c:IsCode(89631139) and c:IsOnField()
end
function s.fcheck(tp,sg,fc)
	if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		return sg:IsExists(s.filterchk,1,nil) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filterchk,1,nil) then
		local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end