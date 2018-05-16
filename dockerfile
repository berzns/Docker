FROM microsoft/dotnet-framework:4.7.2-runtime-20180508-windowsservercore-ltsc2016

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
RUN choco install -y git --params='/NoShellIntegration'
RUN choco install -y nuget.commandline

ENV JAVA_HOME c:\\jre1.8.0_91
ENV JENKINS_HOME c:\\jenkins

RUN (new-object System.Net.WebClient).Downloadfile('http://javadl.oracle.com/webapps/download/AutoDL?BundleId=210185', 'C:\jre-8u91-windows-x64.exe')
RUN start-process -filepath C:\\jre-8u91-windows-x64.exe -passthru -wait -argumentlist "/s,INSTALLDIR=$env:JAVA_HOME,/L,install64.log"
RUN del C:\jre-8u91-windows-x64.exe

RUN $env:PATH = $env:JAVA_HOME + '\\bin;' + $env:PATH; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine);

RUN mkdir $env:JENKINS_HOME
WORKDIR $JENKINS_HOME

#ENTRYPOINT ["cmd.exe"]

ENV TEST_CONTAINER=1 \
    VS_CHANNEL_URI=https://aka.ms/vs/15/release/799c44140/channel \
    VS_BUILDTOOLS_URI=https://aka.ms/vs/15/release/vs_buildtools.exe 
    #VS_BUILDTOOLS_SHA256=FA29EB83297AECADB0C4CD41E54512C953164E64EEDD9FB9D3BF9BD70C9A2D29

# Download SSD installer
#RUN $ErrorActionPreference = 'Stop'; \
#    $ProgressPreference = 'SilentlyContinue'; \
#    $VerbosePreference = 'Continue'; \
#    Invoke-WebRequest -Uri https://download.microsoft.com/download/A/3/B/A3BB5BE5-E8EA-4F63-B1CD-2346B104575E/SSDT-Setup-ENU.exe -OutFile C:\SSDT-Setup-ENU.exe

# Download log collection utility
RUN $ErrorActionPreference = 'Stop'; \
    $ProgressPreference = 'SilentlyContinue'; \
    $VerbosePreference = 'Continue'; \
    Invoke-WebRequest -Uri https://aka.ms/vscollect.exe -OutFile C:\collect.exe

# Download vs_buildtools.exe
RUN $ErrorActionPreference = 'Stop'; \
    $ProgressPreference = 'SilentlyContinue'; \
    $VerbosePreference = 'Continue'; \
    Invoke-WebRequest -Uri $env:VS_BUILDTOOLS_URI -OutFile C:\vs_buildtools.exe
    #if ((Get-FileHash -Path C:\vs_buildtools.exe -Algorithm SHA256).Hash -ne $env:VS_BUILDTOOLS_SHA256) { throw 'Download hash does not match' }

# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools
# Install Visual Studio Build Tools
RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList '--quiet --nocache --wait --installPath C:\BuildTools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.VisualStudio.Workload.MSBuildTools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.VisualStudio.Component.Static.Analysis.Tools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }
    
RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.Net.ComponentGroup.4.6.2.DeveloperTools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.VisualStudio.Workload.WebBuildTools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.VisualStudio.Workload.NodeBuildTools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.Net.Component.3.5.DeveloperTools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.VisualStudio.Component.TestTools.BuildTools'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process -Wait -PassThru -FilePath C:\vs_buildtools.exe -ArgumentList 'modify --quiet --nocache --wait --installPath C:\BuildTools --add Microsoft.VisualStudio.Component.TypeScript.2.8'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

#RUN $ErrorActionPreference = 'Stop'; \
#    $VerbosePreference = 'Continue'; \
#    Copy-Item -Recurse -LiteralPath 'C:\Program Files (x86)\Microsoft Visual Studio\2017\SQL\MSBuild\Microsoft\VisualStudio\v15.0\SSDT' -Destination 'C:\BuildTools\MSBuild\Microsoft\VisualStudio\v15.0\SSDT'



RUN choco install -y netfx-4.5.2-devpack
RUN choco install -y netfx-4.6.1-devpack
RUN choco install -y netfx-4.6.2-devpack
RUN choco install -y dotnet4.6.2
RUN nuget install Microsoft.Data.Tools.Msbuild -ExcludeVersion -OutputDirectory C:\\BuildTools

RUN $env:PATH = 'C:/BuildTools/Microsoft.Data.Tools.Msbuild/lib/net46;' + $env:PATH; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine);

ENV SQLDBExtensionsRefPath C:\\BuildTools\\Microsoft.Data.Tools.Msbuild\\lib\\net46
ENV SSDTPath C:\\BuildTools\\Microsoft.Data.Tools.Msbuild\\lib\\net46



RUN powershell -command "Invoke-WebRequest -UseBasicParsing -Uri https://nodejs.org/dist/v8.11.1/node-v8.11.1-x64.msi -OutFile node.msi"
RUN powershell 
RUN $ErrorActionPreference = 'Stop'; \
    $VerbosePreference = 'Continue'; \
    $p = Start-Process msiexec.exe -Wait -PassThru -ArgumentList '/i node.msi /quiet'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }

RUN npm install -g npm-windows-upgrade
RUN  npm-windows-upgrade -v 6.0.1

#COPY ./Set-EnvironmentPath.ps1 C:/Scripts/

#setx SQLDBExtensionsRefPath C:\BuildTools\Microsoft.Data.Tools.Msbuild\lib\net46 /M

#setx SSDTPath C:\BuildTools\Microsoft.Data.Tools.Msbuild\lib\net46 /M

#ENV PATH_1 "C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/MSBuild/Microsoft/VisualStudio/v15.0"
#ENV PATH_2 "C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/Common7/IDE/Extensions/Microsoft"

#RUN ["powershell",  "mkdir",  "$env:PATH_1"]
#RUN New-Item -ItemType Directory -Path ${PATH_2}

#COPY SSDT $env:PATH_1
#COPY "SQLDB" "$env:PATH_2"

# Use shell form to start developer command prompt and any other commands specified
SHELL ["cmd.exe", "/s", "/c"]
ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat && 

# Default to PowerShell console running within developer command prompt environment
CMD ["powershell.exe", "-nologo"] 

