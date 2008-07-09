
prefix = "mklualib";
lua_state_name = "L";
--lua_state_name = prefix .. "_lua_state";

mklualib_functions = [[
#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

typedef struct mklualib_regnum
{
    const char* name;
    lua_Number num;
} mklualib_regnum;

void mklualib_regstring(lua_State* L, const char* name, const char* s)
{
    lua_pushstring(L, name);
    lua_pushstring(L, s);
    lua_settable(L, -3);
}

void mklualib_regchar(lua_State* L, const char* name, char c)
{
    lua_pushstring(L, name);
    lua_pushlstring(L, &c, 1);
    lua_settable(L, -3);
}

void mklualib_regnumbers(lua_State* L, const mklualib_regnum* l)
{
    for (; l->name; l++)
    {
	lua_pushstring(L, l->name);
	lua_pushnumber(L, l->num);
	lua_settable(L, -3);
    }
}
]];

base_types = {};
typedefs = {};
meta_c_names = {};
meta_funs = {};
meta_flags = {};

infile = arg[1];
outfile = arg[2];
dfile = arg[3];
hfile = arg[4];

if (outfile) then
    f = io.open(outfile, "w");
else
    f = io.stdout;
end

if (hfile) then
    hf = io.open(hfile, "w");
else
    hf = nil;
end

module_name = "";
modules = {};
meta_name = nil;

f:write(mklualib_functions);
f:write("\n\n");

if (hf) then
    f:write("#include \"" .. hfile .. "\"\n\n");
end

function my_assert(a, s)
    if (not a) then
	error(infile .. ":" .. (sn or "") .. ": " .. s, 2);
    end
end

function get_to_fun(t)
    return meta_funs[std_type(t, true)].To;
end

function get_new_fun(t)
    return meta_funs[std_type(t, true)].New;
end

function get_reg_fun(t)
    return meta_funs[std_type(t, true)].Reg;
end

function get_meta_flags(t)
    return meta_flags[std_type(t, true)];
end

function get_module_name(mo)
    mo = mo or module_name;
    return string.upper(prefix .. "_MODULE_" .. mo);
end

function get_meta_name(mo, me)
    mo = mo or module_name;
    me = meta_c_names[std_type(me, true) or meta_name];
    return string.upper(prefix .. "_META_" .. mo .. "_" .. me);
end

function std_type(s, full)
    if (not s) then return nil; end
    local b, e, base, indir = string.find(s, "^%s*([%w%s_]*[%w_])([%s%*]*)");
    base = string.gsub(base, "%s+", " ");
    indir = string.gsub(indir, "%s+", "");
    if (full) then base = typedefs[base] or base; end
    return base .. indir;
end

function known_type(s)
    s = std_type(s, true);
    my_assert(not typedefs[s], "something is wrong: std_type() doesn't work as it should");
    if (base_types[s]) then return "userdata";
    elseif (s == "char") then return "char";
    elseif (s == "char*") then return "string";
    elseif (s == "void") then return "void";
    elseif (s == "bool") then return "boolean";
    else
	for sw in string.gfind(s, "%a+") do
	    if (sw ~= "int") and (sw ~= "short") and (sw ~= "long")
		and (sw ~= "unsigned") and (sw ~= "double") and
		(sw ~= "float") then return nil;
	    end
	end
    end
    return "number";
end

function trim(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1");
end

sn = 1;
comment_level = 0;
for l in io.lines(infile) do
    --print("line " .. sn);
    if (l ~= "" and string.sub(l, 1, 1) ~= "#") then
	local parsed = false;
	if (not parsed) then
	    if (l == "!comment;") then
		comment_level = comment_level + 1;
		parsed = true;
	    elseif (l == "!endcomment;") then
		comment_level = comment_level - 1;
		parsed = true;
	    end
	end
	if (comment_level > 0) then parsed = true; end
	if (not parsed) then
	    local b, e, inc = string.find(l, "^@(.*)$");
	    if (inc) then
		f:write(inc .. "\n");
		parsed = true;
	    end
	end
	if (not parsed) then
	    local b, e, c, m, rest = string.find(l, "^!(%w+)%s+([^;]*);(.*)$");
	    if (c == "module") then
		m = trim(m);
		my_assert(string.find(m, "[%a_][%w_]*"), "invalid module name '" .. m .. "'");
		module_name = m;
		modules[module_name] = modules[module_name] or {Funs = {}, Metas = {}, Fields = {}, Nums = {}};
		f:write("#define " .. get_module_name() .. " \"" .. module_name .. "\"\n");
		parsed = true;
	    elseif (c == "meta") then
		m = std_type(m);
		my_assert(not typedefs[m] and not base_types[m], "type '" .. m .. "' is already defined");
		base_types[m] = true;
		local b, e, known, pointer, c_name, fun_to, fun_new, fun_reg = string.find(rest,
				    "^%s*(!?)(%*?)%s*@([%a_][%w_]*)%s*@([%a_][%w_]*)%s*@([%a_][%w_]*)%s*@([%a_][%w_]*)%s*$");
		meta_c_names[m] = c_name;
		meta_funs[m] = {To = fun_to, New = fun_new, Reg = fun_reg};
		meta_flags[m] = {};
		if (pointer ~= "") then meta_flags[m].Pointer = true; end
		if (known == "") then
		    meta_name = m;
		    modules[module_name].Metas[meta_name] = {};
		    if (hf) then
			hf:write("#define " .. get_meta_name() .. "\n\n");
			hf:write(m .. " " .. fun_to .. "(lua_State* L, int index);\n");
			hf:write(m .. "* " .. fun_new .. "(lua_State* L);\n");
			hf:write("void " .. fun_reg .. "(lua_State* L, const char* name, " .. m .. " userdata);\n\n");
		    end
		end
		--f:write("#define " .. get_meta_name() .. " \"" .. module_name .. "_" .. meta_name .. "\"\n");
		parsed = true;
	    elseif (c == "endmeta") then
		m = std_type(m);
		my_assert(m == meta_name, "expected '!endmeta " .. meta_name .. "'");
		meta_name = nil;
		parsed = true;
	    elseif (c == "typedef") then
		local b, e, init, new = string.find(m, "^%s*(.*[%s%*])([%a_][%w_]*)%s*$");
		my_assert(known_type(init), "unknown type '" .. init .. "'");
		typedefs[new] = std_type(init, true);
		parsed = true;
	    end
	end
	if (not parsed) then
	    local b, e, val_type, c_name, rest = string.find(l, "^(.*[%s%*])([%a_][%w_]*)%s*;(.*)$");
	    if (c_name) then
		val_type = string.gsub(val_type, "const", "");
		my_assert(known_type(val_type), "unknown type '" .. val_type .. "'");
		local b, e, lua_name = string.find(rest, "^%s*@([%a_][%w_]*)%s*$");
		if (known_type(val_type) == "number") then
		    table.insert(modules[module_name].Nums, {CName = c_name, LName = lua_name or c_name});
		else
		    table.insert(modules[module_name].Fields, {Type = std_type(val_type),
			     CName = c_name, LName = lua_name or c_name});
		end
		parsed = true;
	    end
	end
	if (not parsed) then
	    local b, e, ret_type, c_name, arg_list, not_fun, ret_free, rest = string.find(l,
						    "^(.*[%s%*])([%a_][%w_]*)%s*%((.*)%)%s*;%s*(%%?)%s*(%$?)(.*)$");
	    my_assert(rest, "cannot parse line");
	    local b, e, plain, rest = string.find(rest, "^%s*(=?)(.*)$");
	    local b, e, first, trans, last = string.find(rest, "^([^%^]*)(%^?)(.*)$");
	    local b, e, lua_name = string.find(first, "^%s*@([%a_][%w_]*)%s*$");
	    local t_lua_name = nil;
	    if (trans == "^") then
		local b, e, n = string.find(last, "^%s*@([%a_][%w_]*)%s*$");
		t_lua_name = n or c_name;
	    end
	    lua_name = lua_name or c_name;
	    local fun_name;
	    if (meta_name and not t_lua_name) then
		fun_name = prefix .. "_" .. module_name .. "_" .. meta_c_names[meta_name] .. "_" .. lua_name;
		table.insert(modules[module_name].Metas[meta_name], {CName = fun_name, LName = lua_name});
		f:write("/* " .. meta_name .. ":" .. lua_name .. " */\n");
	    elseif (t_lua_name) then
		fun_name = prefix .. "_" .. module_name .. "_" .. t_lua_name;
		table.insert(modules[module_name].Funs, {CName = fun_name, LName = t_lua_name});
		table.insert(modules[module_name].Metas[meta_name], {CName = fun_name, LName = lua_name});
		f:write("/* " .. module_name .. "." .. t_lua_name .. " */\n");
		f:write("/* " .. meta_name .. ":" .. lua_name .. " */\n");
	    else
		fun_name = prefix .. "_" .. module_name .. "_" .. lua_name;
		table.insert(modules[module_name].Funs, {CName = fun_name, LName = lua_name});
		f:write("/* " .. module_name .. "." .. lua_name .. "*/\n");
	    end
	    f:write("int " .. fun_name .. "(lua_State* " .. lua_state_name .. ")\n{\n");
	    
	    if (string.len(plain) > 0) then
		f:write("\treturn " .. c_name .. "(" .. lua_state_name .. ");\n}\n\n");
	    else
		ret_type = string.gsub(ret_type, "const", "");
		ret_type = std_type(ret_type);
		local ret_name = fun_name .. "_ret";

		local arg_table = {};
		local ret_table = {};
		if (known_type(ret_type) ~= "void") then
		    table.insert(ret_table, {Type = ret_type, Name = ret_name});
		end
		for _arg in string.gfind(arg_list, "([^,]+),?") do
		    local b, e, arg_val = string.find(_arg, "^%s*%%(.*)$");
		    if (arg_val) then
			table.insert(arg_table, {Value = arg_val;});
		    else
			_arg = string.gsub(_arg, "const", "");
			local b, e, arg_type, arg_mod, arg_name = string.find(_arg, "%s*([%w_]+[%s%*]*)(&?!?%^?)%s*([%a_]?[%w_]*)%s*,?");
			if (string.len(arg_name) == 0) then
			    arg_name = "_arg" .. table.getn(arg_table);
			end
			if (known_type(arg_type) == "void") then break; end
			arg_type = std_type(arg_type);
			if (string.find(arg_mod, "&")) then
			    table.insert(ret_table, {Type = arg_type, Name = arg_name});
			end
			local ld_mod = true;
			local arg_pointer = false;
			if (string.find(arg_mod, "!")) then ld_mod = false; end
			if (string.find(arg_mod, "%^")) then arg_pointer = true; end
			table.insert(arg_table, {Type = arg_type, Mode = ld_mod, Pointer = arg_pointer, Name = arg_name});
		    end
		end

		if (meta_name) then
		    my_assert(std_type(arg_table[1].Type, true) == meta_name, "expected arg #1 of type '" .. meta_name .. "', found '" ..
		    arg_table[1].Type .. "'");
		end


		--local self_name = fun_name .. "_self";
		table.foreachi(arg_table, function(_i, _v)
		    if (not _v.Name) then return; end
		    local _type = known_type(_v.Type);
		    my_assert(_type, "unknown type '" .. _v.Type .. "'");
		    if (_type == "void") then
			my_assert(false, "function arg cannot be 'void'");
		    elseif (_type == "number") or (_type == "string") or (_type == "boolean") then
			f:write("\t" .. _v.Type .. " " .. _v.Name);
			if (_v.Mode) then
			    f:write(" = (" .. _v.Type .. ") lua_to" .. _type .. "(" .. lua_state_name .. ", " .. _i .. ");\n");
			else
			    f:write(";\n");
			end
		    elseif (_type == "char") then
			f:write("\t" .. _v.Type .. " " .. _v.Name .. " = (" .. _v.Type .. ") lua_tostring(" ..
			lua_state_name .. ", " .. _i .. ")[0];\n");
		    elseif (_type == "userdata") then
			f:write("\t" .. _v.Type .. " " .. _v.Name .. " = " .. get_to_fun(_v.Type) .. "(" ..
			lua_state_name .. ", " .. _i .. ");\n");
		    end
		end);
		f:write("\t");


		if (ret_type ~= "void") then
		    f:write(ret_type .. " " .. ret_name .. " = (" .. ret_type .. ") ");
		end
		if (string.len(not_fun) > 0) then
		    f:write(c_name .. ";\n");
		else
		    f:write(c_name .. "(");
		    table.foreachi(arg_table, function(_i, _v)
			if (_v.Value) then
			    f:write(_v.Value);
			else
			    if (_v.Pointer) then f:write("&"); end
			    f:write(_v.Name);
			end
			if (_i < table.getn(arg_table)) then
			    f:write(", ");
			end
		    end);
		    f:write(");\n");
		end
		table.foreachi(ret_table, function(_i, _v)
		    local _type = known_type(_v.Type);
		    my_assert(_type, "unknown type '" .. _v.Type .. "'");
		    if (_type == "number") or (_type == "string") or (_type == "boolean") then
			f:write("\tlua_push" .. _type .. "(" .. lua_state_name .. ", " .. _v.Name .. ");\n");
		    elseif (_type == "char") then
			f:write("\tlua_pushlstring(" .. lua_state_name .. ", &" .. _v.Name .. ", 1);\n");
		    elseif (_type == "userdata") then
			local _shift = "";
			if (get_meta_flags(_v.Type).Pointer) then
			    f:write("\tif (" .. _v.Name .. " == NULL) lua_pushnil(" .. lua_state_name .. ");\n");
			    f:write("\telse\n\t{\n");
			    _shift = "\t";
			end
			f:write(_shift .. "\t" .. _v.Type .. "* " .. _v.Name .. "_retptr = " .. get_new_fun(_v.Type) .. "(" ..
				lua_state_name .. ");\n");
			f:write(_shift .. "\t*" .. _v.Name .. "_retptr = " .. _v.Name .. ";\n");
			if (get_meta_flags(_v.Type).Pointer) then
			    f:write("\t}\n");
			end
		    end
		end);
		if (string.len(ret_free) ~= 0) then
		    f:write("\tfree(" .. ret_name .. ");\n");
		end
		f:write("\treturn " .. table.getn(ret_table) .. ";\n");
		f:write("}\n\n");
	    end
	end
    end
    sn = sn + 1;
end
sn = nil;

function write_functions(name, funs)
    f:write("const luaL_reg " .. name .. "[] = {\n");
    table.foreachi(funs, function(_i, _v)
	f:write("\t{\"" .. _v.LName .. "\", " .. _v.CName .. "},\n");
    end);
    f:write("\t{0, 0}\n");
    f:write("};\n\n");
end

function write_numbers(name, nums)
    if (table.getn(nums) == 0) then return; end
    f:write("const mklualib_regnum " .. name .. "_nums[] = {\n");
    table.foreachi(nums, function(_i, _v)
	f:write("\t{\"" .. _v.LName .. "\", " .. _v.CName .. "},\n");
    end);
    f:write("\t{0, 0}\n");
    f:write("};\n\n");
end

table.foreach(modules, function(_name, _module)
    local lib_name = prefix .. "_" .. _name .. "_lib";
    write_functions(lib_name, _module.Funs);
    write_numbers(lib_name, _module.Nums);
    table.foreach(_module.Metas, function(_m_name, _meta)
	local meta_lib_name = prefix .. "_" .. _name .. "_" .. meta_c_names[_m_name] .. "_lib";
	write_functions(meta_lib_name, _meta);
	f:write("void " .. prefix .. "_create_" .. _name .. "_" .. meta_c_names[_m_name] ..
		"(lua_State* " .. lua_state_name .. ")\n{\n");
	f:write("\tluaL_newmetatable(" .. lua_state_name .. ", " .. get_meta_name(_name, _m_name) .. ");\n");
	f:write("\tlua_pushliteral(" .. lua_state_name .. ", \"__index\");\n");
	f:write("\tlua_pushvalue(" .. lua_state_name .. ", -2);\n");
	f:write("\tlua_rawset(" .. lua_state_name .. ", -3);\n");
	f:write("\tluaL_openlib(" .. lua_state_name .. ", 0, " .. meta_lib_name .. ", 0);\n");
	f:write("}\n\n");
    end);

    local lua_tname;
    if (string.len(_name) > 0) then
	lua_tname = get_module_name(_name);
    else lua_tname = "0";
    end
    f:write("int luaopen_" .. _name .. "(lua_State* " .. lua_state_name .. ")\n{\n");
    table.foreach(_module.Metas, function(_m_name, _meta)
	f:write("\t" .. prefix .. "_create_" .. _name .. "_" .. meta_c_names[_m_name] .. "(" .. lua_state_name .. ");\n");
    end);
    f:write("\tluaL_openlib(" .. lua_state_name .. ", " .. lua_tname .. ", " .. lib_name .. ", 0);\n");
    if (table.getn(_module.Nums) > 0) then
	f:write("\tmklualib_regnumbers(" .. lua_state_name .. ", " .. lib_name .. "_nums);\n");
    end
    table.foreachi(_module.Fields, function(_f_name, _field)
	local _type = known_type(_field.Type);
	my_assert(_type, "unknown type '" .. _field.Type .. "'");
	if (_type == "void") then
	    my_assert(false, "field cannot be 'void'");
	elseif (_type == "number") or (_type == "string") or (_type == "char") then
	    f:write("\tmklualib_reg" .. _type .. "(" .. lua_state_name .. ", \"" .. _field.LName .. "\", " ..
		    _field.CName .. ");\n");
	elseif (_type == "userdata") then
	    f:write("\t" .. get_reg_fun(_field.Type) .. "(" .. lua_state_name .. ", \"" .. _field.LName .. "\", " ..
		    _field.CName .. ");\n");
	end
    end);
    f:write("\treturn 1;\n");
    f:write("}\n\n");
end);

f:close();

-- generate something for documentation.

if not dfile then os.exit(0); end

df = io.open(dfile, "w");

function write_doc_elems(p, funs)
    local cols = 3;
    df:write("\\halign to \\hsize{\n#\\hfil\\tabskip=1cm plus 1cm minus 1cm&#\\hfil&#\\hfil\\cr\n");
    table.sort(funs, function(_a, _b)
	return _a.LName < _b.LName;
    end);
    local i = 0;
    table.foreachi(funs, function(_i, _v)
	if (not string.find(_v.LName, "^__")) then
	    i = i + 1;
	    df:write((string.gsub(p .. _v.LName, "_", "\\_")));
	    if (math.mod(i, cols) == 0) then
		df:write("\\cr\n");
	    else
		df:write("&");
	    end
	end
    end);
    if (math.mod(i, cols) > 0) then
	local n = cols - math.mod(i, cols);
	for i = 1, n do
	    df:write("\\omit");
	    if (i == n) then df:write("\\cr\n");
	    else df:write("&");
	    end
	end
    end
    df:write("}\n");
    df:write("\\vskip 1cm plus 1cm minus 1cm\n");
end

df:write("\\input head\n");
table.foreach(modules, function(_name, _module)
    df:write("\\modulename{" .. (string.gsub(_name, "_", "\\_")) .. "}\n");
    if (table.getn(_module.Funs) > 0) then
	df:write("\\section{functions}\n");
	write_doc_elems(_name .. ".", _module.Funs);
    end
    if (table.getn(_module.Fields) > 0) then
	df:write("\\section{fields}\n");
	write_doc_elems(_name .. ".", _module.Fields);
    end
    if (table.getn(_module.Nums) > 0) then
	df:write("\\section{numbers}\n");
	write_doc_elems(_name .. ".", _module.Nums);
    end
    table.foreach(_module.Metas, function(_m_name, _meta)
	--df:write("\\vfill\\eject\n");
	df:write("\\metaname{" .. (string.gsub(meta_c_names[_m_name], "_", "\\_")) .. "}\n");
	df:write("\\section{functions}\n");
	write_doc_elems(meta_c_names[_m_name] .. ":", _meta);
    end);
end);

df:write("\\bye\n");
df:close();
