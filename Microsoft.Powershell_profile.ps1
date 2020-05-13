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