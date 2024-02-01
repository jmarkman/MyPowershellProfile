Import-Module ShaolinAttendeeParser

function HelloWorld
{
    Write-Output "Hello World!"
}

function twitch.tv([string]$Stream, [string]$Quality = "best")
{
    streamlink "https://www.twitch.tv/$($Stream)" $Quality
}

<#
.SYNOPSIS
Update-NeoCities generates my Hugo blogs and synchronizes the content to NeoCities.

.PARAMETER For
Specifies which blog to update. "games" will update my game blog, "work" will
update my programming blog.
#>
function Update-NeoCities([string] $For) 
{
    $gameBlogPath = "C:\Users\jon\Documents\Blogs\GameBlog\FightsAndFragChecks"
    $programmingBlogPath = "C:\Users\jon\Documents\Blogs\ProgrammingBlog\programmingbutrelatable"

    if ($For -eq "games")
    {
        Write-Output "Updating game blog 'Fights And Frag Checks'"
        NeocitiesNET.exe account --use "gsm"
        Set-Location $gameBlogPath
    }
    elseif ($For -eq "work")
    {
        Write-Output "Updating game blog 'Programming, But Relatable'"  
        NeocitiesNET.exe account --use "jmarkman"
        Set-Location $programmingBlogPath
    }

    Push-Location

    Write-Output "Calling 'hugo' to build website"
    hugo.exe

    Set-Location .\public

    Write-Output "Getting items in 'public' directory to push to Neocities"
    $currentLocation = Get-Location | Select-Object -ExpandProperty Path

    NeocitiesNET.exe modify --upload $currentLocation

    Pop-Location
}

<#
.Synopsis
New-Gif creates an animated gif from a specified video file

.Description
Using ffpmeg, creates an animated gif from a specified video file. Find information about this at the following urls:
- http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
- https://superuser.com/a/556031

.Parameter VideoFile
The path to the video file. Must be an absolute path

.Parameter StartTime
The timestamp from the video to start from

.Parameter Duration
The length of the gif relative to the starting time

.Parameter Framerate
The framerate the resulting gif should play back at. Default is 15 fps.

.Parameter Resolution
The resolution of the resulting gif. Default is 480 (480x272). Available resolutions are [320, 480, 640, 848, 960].

.Parameter PaletteGenStatsMode
The mode palettegen should be in when processing the video file. "full" is the default value, but providing "diff"
will force the palettegen to only focus on moving parts, and providing "single" will generate a palette for each
individual frame in the gif

.Parameter OutputFilename
The filename to use for the gif. "output" is the default filename.
#>
function New-Gif  
{
    param (
            [string] $VideoFile, 
            [string] $StartTime,
            [string] $Duration,
            [int] $Framerate = 15,
            [int] $Resolution = 480,
            [string] $PaletteGenStatsMode = "diff",
            [string] $OutputFilename = "output.gif"
        )

    $resolutionDict = @{
        320 = "320:-1";
        480 = "480:-1";
        640 = "640:-1";
        848 = "848:-1";
        960 = "960:-1";
    }

    if (-not (Test-Path $VideoFile))
    {
        Write-Output "The supplied filepath was invalid"
        return
    }

    $ffpmegPaletteFolder = "C:\Users\jon\AppData\Local\Temp"
    $paletteFolderName = "ffmpeg-palette"
    $paletteFilename = "palette.png"
    $paletteLocation = Join-Path -Path $ffpmegPaletteFolder -ChildPath $paletteFolderName
    $paletteOutput = Join-Path -Path $paletteLocation -ChildPath $paletteFilename

    $outputDirectory = "C:\Users\jon\Pictures"
    $output = Join-Path -Path $outputDirectory -ChildPath $OutputFilename

    $gifResolution = $resolutionDict[$Resolution]
    $filters = "fps=$($Framerate),scale=$($gifResolution):flags=lanczos"
    $paletteStatsMode = "palettegen=stats_mode=$($PaletteGenStatsMode)"
    $ffmpeg = "C:\Program Files\ffmpeg\ffmpeg.exe"

    # Check to see that we've got a folder to drop the palette in; if we don't, make one
    # TodayILearned: https://stackoverflow.com/a/50366338
    if (-not (Test-Path $paletteLocation))
    {
        New-Item -Path $ffpmegPaletteFolder -Name $paletteFolderName -ItemType "directory"
    }
    
    Write-Output "Creating animated gif using '$VideoFile'"

    & $ffmpeg -v warning -ss $StartTime -t $Duration -i $VideoFile -vf "$filters,$paletteStatsMode" -y $paletteOutput 
    
    & $ffmpeg -v warning -ss $StartTime -t $Duration -i $VideoFile -i $paletteOutput -lavfi "$filters [x]; [x][1:v] paletteuse=dither=sierra2" -y $output

    Write-Output "Resulting gif: '$output'"
}

function New-APng
{
    param (
        [string] $InputPath,
        [string] $OutputFilename
    )

    $ffmpeg = "C:\Program Files\ffmpeg\ffmpeg.exe"
    $outputDirectory = "C:\Users\jon\Pictures"
    $output = Join-Path -Path $outputDirectory -ChildPath $OutputFilename

    & $ffmpeg -i $InputPath -plays 0 -t 1 -vf "setpts=PTS-STARTPTS, hqdn3d=1.5:1.5:6:6" $output
}

function Join-Zoom([string] $Room = "")
{
    $rooms = Get-Content -Path "C:\Users\jon\Documents\WindowsPowerShell\zoom-rooms.txt"
    $roomDict = @{}

    foreach ($r in $rooms) 
    {
        $kvp = $r -split ","
        $roomDict.Add($kvp[0], $kvp[1])
    }

    if ($roomDict.ContainsKey($Room))
    {
        $roomId = $roomDict[$Room]
        [System.Diagnostics.Process]::Start("chrome","https://us02web.zoom.us/j/${$roomId}")
    }
}


function Create-TodoMockData()
{
    $dbConn = New-Object System.Data.Odbc.OdbcConnection
    $dbConn.ConnectionString = "Driver={PostgreSQL Unicode(x64)};Server=localhost;Port=5432;Database=projects;Uid=solbadguy;Pwd=dustloop;"

    # Bad practice to have unsanitized queries of any type, let alone insertions, but this is mock data I'm in complete control of
    $sql = @"
    insert into `"TodoList`" ("Id", "Task", "IsCompleted", "DateCreated", "DateCompleted")
    values
    (1, 'Test Task 1', false, '@date', null),
    (2, 'Test Task 2', false, '@date', null),
    (3, 'Test Task 3', false, '@date', null);
"@

    # Write-Output $sql

    # $dbConn.Open()

    # $dbCmd = $dbConn.CreateCommand()
    # $dbCmd.CommandText = "select * from `"TodoList`";"

    # $reader = $dbCmd.ExecuteReader()

    # while ($reader.Read()) {
    #     Write-Output "$($reader["Id"]) | $($reader["Task"]) | $($reader["IsCompleted"]) | $($reader["DateCreated"]) | $($reader["DateCompleted"])"
    # }

    # $dbConn.Close()

    $cmd = $dbConn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.Parameters.AddWithValue("@date", $(Get-Date))

    Write-Output $cmd.CommandText

    # $dbConn.Open()
    # try 
    # {
    #     $cmd.ExecuteNonQuery()
    # }
    # catch 
    # {
    #     $_
    # }

    # $dbConn.Close()
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
