local tableutils = {}
--

function tableutils.deepcopy(tbl)
	
end

function tableutils.copy(tbl, meta, lvl)
	local t, lvl = {}, lvl or 0
	if meta then setmetatable(t, getmetatable(tbl)) end
	for k,v in pairs(tbl) do
		t[k] = (lvl>0 and type(v)=="table") and tableutils.copy(v, meta, lvl-1) or v
	end
	return t
end

--
return tableutils