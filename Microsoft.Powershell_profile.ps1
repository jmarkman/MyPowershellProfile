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
    if ($For -eq "games")
    {
        Write-Output "Updating game blog 'Fights And Frag Checks'"
        Set-Location C:\Users\jon\Documents\StalinBlog\FightsAndFragChecks
        Push-Location
    }
    else 
    {
        Write-Output "Haven't created a work blog yet"  
        return  
    }

    Write-Output "Calling 'hugo' to build website"
    hugo.exe

    Set-Location .\public

    Write-Output "Getting items in 'public' directory to push to Neocities"
    $siteItems = Get-ChildItem

    foreach ($item in $siteItems)
    {
        Write-Output "Uploading $item"
        neocities.exe upload $item.Name
    }

    Pop-Location
}

function New-Gif ([string] $VideoFile, [int] $StartTime, [int] $Duration, [string] $OutputFilename = "output.gif") 
{
    $ffpmegPaletteFolder = C:\Users\jon\AppData\Local\Temp
    $paletteFolderName = "ffmpeg-palette"
    $paletteFilename = "palette.png"
    $paletteLocation = Join-Path -Path $ffpmegPaletteFolder -ChildPath $paletteFolderName
    $paletteOutput = Join-Path -Path $paletteLocation -ChildPath $paletteFilename
    $outputDirectory = C:\Users\jon\Pictures
    $output = Join-Path -Path $outputDirectory -ChildPath $OutputFilename
    $filters = "fps=15,scale=320:-1:flags=lanczos"
    $ffmpeg = 'C:\Program Files\ffmpeg\ffmpeg.exe'

    # Check to see that we've got a folder to drop the palette in; if we don't, make one
    # TodayILearned: https://stackoverflow.com/a/50366338
    if (-not (Test-Path $paletteLocation))
    {
        New-Item -Path $ffpmegPaletteFolder -Name $paletteFolderName -ItemType "directory"
    }
    
    & $ffmpeg -v warning -ss $StartTime -t $Duration -i $VideoFile -vf "$filters,palettegen" -y $paletteOutput
    & $ffmpeg -v warning -ss $StartTime -t $Duration -i $VideoFile -i $paletteOutput -lavfi "$filters [x]; [x][1:v] paletteuse" -y $output
}