<# :
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { [ScriptBlock]::Create((Get-Content '%~f0' | Out-String)).Invoke(@args) }" %*
goto :eof
#>
param(
    [string]$Configuration = 'Debug',
    [switch]$RunTests = $false,
    [switch]$Publish = $false
)

Write-Host "Started Local Build Process..." -ForegroundColor Cyan

# 0. Check NuGet Sources
Write-Host "0. Checking NuGet sources..." -ForegroundColor Yellow
$nugetSources = dotnet nuget list source | Out-String
if ($nugetSources -notmatch "CommunityToolkit-Labs") {
    Write-Warning "CommunityToolkit-Labs source missing. Adding it..."
    dotnet nuget add source "https://pkgs.dev.azure.com/dotnet/CommunityToolkit/_packaging/CommunityToolkit-Labs/nuget/v3/index.json" -n CommunityToolkit-Labs
}

# 1. Restore Dependencies
Write-Host "1. Restoring dependencies..." -ForegroundColor Yellow
dotnet restore FluentFin.sln
if ($LASTEXITCODE -ne 0) { Write-Error "Restore failed!"; exit 1 }

# 2. Build Solution
Write-Host "2. Building solution ($Configuration)..." -ForegroundColor Yellow
dotnet build FluentFin.sln -c $Configuration --no-restore
if ($LASTEXITCODE -ne 0) { Write-Error "Build failed!"; exit 1 }

# 3. Running Tests (Optional)
if ($RunTests) {
    Write-Host "3. Running tests..." -ForegroundColor Yellow
    dotnet test FluentFin.sln --no-build -c $Configuration
    if ($LASTEXITCODE -ne 0) { Write-Error "Tests failed!"; exit 1 }
}

# 4. Publish (Optional - mimics CI)
if ($Publish) {
    Write-Host "4. Publishing (Release)..." -ForegroundColor Yellow
    # CI uses Release for publish
    $PublishConfig = "Release"
    $Version = "1.0.0-local" 
    
    # Using the same command structure as CI/publish.ps1
    # Note: We hardcode Release for publish as is standard, but you could genericize if needed.
    dotnet publish FluentFin\FluentFin.csproj --self-contained -c $PublishConfig -r win-x64 -o FluentFin\bin\publish\ /property:BuildVersion=$Version
    if ($LASTEXITCODE -ne 0) { Write-Error "Publish failed!"; exit 1 }
    
    Write-Host "Publish output available at: FluentFin\bin\publish\" -ForegroundColor Gray
    
    # Automatically open the folder for the user
    Write-Host "Opening publish directory..." -ForegroundColor Cyan
    Invoke-Item "FluentFin\bin\publish\"
}

Write-Host "Build Completed Successfully!" -ForegroundColor Green
