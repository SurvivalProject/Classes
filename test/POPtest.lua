local mem_hook = Create("_se_mem_hook", internkeyword or "se_nocrypt_def_pass")

mem_hook:DEFEVENT("MOVEDIR"):connect(function(_orig_dirman, _end_dirman)
	do
		SE_CHANGE_ENVIRONMENT_ROOT(self.locale))
		local my, adr = acc "se dirmove";
		tmpstack:push(my);
		tmpstack:pop(); -- exe security up
		tmpstack:pop(); -- exe wall up
		tmpstack:pop(); -- exe se dirmove [se disk notify]
		cpy(my);
		local a = mov(my, acc(my.se_size));
		local b = del(adr, my.se_size);
		_flush_reg(tempreg.R);
		_flush_reg(tempreg.W);
		_reg_mode('rw');
		asm_streamwrite("mode=dumpqr", a,b)
		return a and b;
	end
end)
-- goto default environment
SE_CHANGE_ENVIRONMENT_ROOT(DEFAULT_1)
System:regmode(getfenv(), apikey, privkey, encrman(pubkey), nil)
local disk = System.Utilities._ABSTRACT_HIDDEN.DirTools:MakeVirtualDrive("ROOT")
disk[0] = "*se try FF -f -b -after \"call mem_hook MOVEDIR default default2\""
disk[ 0xFF ] = System.Utilties._ABSTRACT_HIDDEN.DirTools:MakeEXFUNC(function(...) -- redirect 
	getfenv()[select(1)][select(2)](getfenv()[select[1]], select(3), select(4))
end)
disk:get("default2")
disk:prsatus("default2")
