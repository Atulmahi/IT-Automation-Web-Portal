import subprocess

subprocess.Popen([
    "powershell.exe",
    "-Command",
    "Start-Process powershell.exe -Verb RunAs -ArgumentList  "-ExecutionPolicy Bypass -File D:\IT Automation Web Portal\scripts\Fast_system1.bat"
])
