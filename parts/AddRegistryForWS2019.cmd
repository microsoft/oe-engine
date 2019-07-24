reg query HKLM\SYSTEM\CurrentControlSet\Services\sgx_lc_msr\Parameters /v SGX_Launch_Config_Optin
if %ERRORLEVEL% EQU 0 goto SETUP
goto:eof
:SETUP
reg add HKLM\SYSTEM\CurrentControlSet\Services\sgx_lc_msr\Parameters /v SGX_Launch_Config_Optin /t REG_DWORD /d 0x01 /s
SHUTDOWN -r -t 10
