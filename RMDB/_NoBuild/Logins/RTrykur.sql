--IF	NOT EXISTS	(
--					select	1
--					from	master.sys.server_principals
--					where	name = N'BANKGROUP\RTrykur'
--				)
	CREATE LOGIN [BANKGROUP\RTrykur] FROM WINDOWS