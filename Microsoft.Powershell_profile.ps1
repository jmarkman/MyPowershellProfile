function HelloWorld
{
    Write-Output "Hello World!"
}

function twitch.tv([string]$Stream, [string]$Quality = "best")
{
    streamlink "https://www.twitch.tv/$($Stream)" $Quality
}

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
The resolution of the resulting gif. Default is 272p (480x272).

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
            [int] $StartTime,
            [int] $Duration,
            [int] $Framerate = 15,
            [int] $Resolution = 272,
            [string] $PaletteGenStatsMode = "full",
            [string] $OutputFilename = "output.gif"
        )

    $resolutionDict = @{
        240 = "320:-1";
        272 = "480:-1";
        360 = "640:-1";
        480 = "848:-1";
        540 = "960:-1";
    }

    $ffpmegPaletteFolder = "C:\Users\jon\AppData\Local\Temp"
    $paletteFolderName = "ffmpeg-palette"
    $paletteFilename = "palette.png"
    $paletteLocation = Join-Path -Path $ffpmegPaletteFolder -ChildPath $paletteFolderName
    $paletteOutput = Join-Path -Path $paletteLocation -ChildPath $paletteFilename

    $outputDirectory = "C:\Users\jon\Pictures"
    $output = Join-Path -Path $outputDirectory -ChildPath $OutputFilename

    $gifResolution = $resolutionDict[$Resolution];
    $filters = "fps=$($Framerate),scale=$($gifResolution):flags=lanczos"
    $paletteStatsMode = "palettegen=stats_mode=$($PaletteGenStatsMode)"
    $ffmpeg = 'C:\Program Files\ffmpeg\ffmpeg.exe'

    # Check to see that we've got a folder to drop the palette in; if we don't, make one
    # TodayILearned: https://stackoverflow.com/a/50366338
    if (-not (Test-Path $paletteLocation))
    {
        New-Item -Path $ffpmegPaletteFolder -Name $paletteFolderName -ItemType "directory"
    }
    
    Write-Output "Creating animated gif using '$VideoFile'"

    & $ffmpeg -v warning -ss $StartTime -t $Duration -i $VideoFile -vf "$filters,$paletteStatsMode" -y $paletteOutput
    & $ffmpeg -v warning -ss $StartTime -t $Duration -i $VideoFile -i $paletteOutput -lavfi "$filters [x]; [x][1:v] paletteuse=dither=none" -y $output

    Write-Output "Resulting gif: '$output'"
}