--IF	NOT EXISTS	(
--					select	1
--					from	master.sys.server_principals
--					where	name = N'BANKGROUP\YaHembarovska'
--				)
	CREATE LOGIN [BANKGROUP\YaHembarovska] FROM WINDOWS