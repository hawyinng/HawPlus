--------------------------------------------------------------------------------------
--							WoW <System.Locale> Class								--
--------------------------------------------------------------------------------------
--	Provide a class to set and get different info according to different locale 	--
--	versions of WoW Client															--
--------------------------------------------------------------------------------------
if (System.Locale) then
	return;
end

--UpValues
local type = type;
local setmetatable = setmetatable;
local rawset = rawset;
local GetLocale = GetLocale;

--Locales cache
local Locales = {};

--Locale Class
local LocaleClassDef = {
	Name = "System.Locale",
	Functions = {
		GetLocaleTable = {
			Desc = [[Get the locale query table]],
			Func = function(self, name, locale)
				if (type(name) ~= "string") then
					return nil;
				end
				Locales[name] = Locales[name] or {};
				local localeTables = Locales[name];
				if (type(localeTables) ~= "table") then
					return nil;
				end
				if (type(locale) ~= "string") then
					locale = GetLocale();
				end
				localeTables[locale] = localeTables[locale] or {};
				local localeTable = localeTables[locale];
				if (type(localeTable) ~= "table") then
					return nil;
				end
				setmetatable(localeTable, {
					__index = function(t, k)
						return k;
					end,
					__newindex = function(t, k, v)
						rawset(t, k, v);
					end,
				});
				return localeTable;
			end,
			Static = true,
		},
	},
	Properties = {
		Current = {
			Desc = [[Get the current locale]],
			Type = String,
			Get = function()
				return GetLocale();
			end,
			Static = true,
		},
	},
};
System.Locale = newclass(LocaleClassDef);