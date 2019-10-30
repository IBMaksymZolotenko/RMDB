--CREATE LOGIN [MZolotenko] FROM WINDOWS
--IF	NOT EXISTS	(
--					select	1
--					from	master.sys.server_principals
--					where	name = N'BANKGROUP\MZolotenko'
--				)
	CREATE LOGIN [BANKGROUP\MZolotenko] FROM WINDOWS