@echo off
cls

rem Set these variables to the desired values

set SqlServer=DestinyServerHostname
set InstanceName=MSSQLSERVER
set Username=circcatadmin
set Password=DestinyCirCatAdminPwd
set Database=DESTINY
set LocalFolder=C:\SCRIPTS
set NetworkFolder="\\SERVER_IP_ADDR\database_backups\destiny\"

echo.
echo Backing up database to %LocalFolder%
echo.
SqlCmd -S %SqlServer% -U %Username% -P %Password% -i "C:\SCRIPTS\Filewave\qry_Destiny_All.sql" -o "destiny_device_info.csv" -s"," -W

echo.
echo.
rem echo Copying backup to %NetworkFolder%
rem echo.
rem move /Y %LocalFolder%\%Database%-*.dbb %NetworkFolder%