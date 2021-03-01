# Introduction 
Shell Service is a Windows Service that can be easily configured to run any powershell script as a service.

# Getting Started
1. Copy your powershell script to the `/Deploy/Shell Service/SupportedFiles` directory
1. Make sure `/Deploy/Shell Service/appsettings.json` has the desired ServiceName, and WorkerSettings. The WorkerSettings should just be the script name and any of it's arguments.
1. Run the command line as administrator

    a. To install your service, run `install.cmd`

    b. To uninstall your service, run `uninstall.cmd`

# Build and Deploy
I deploy it locally using the LocalRelease publish profile. That means you can copy and paste the directory `Deploy\Shell Service` on any machine to have an entirely portable, easily installable windows powershell service.
