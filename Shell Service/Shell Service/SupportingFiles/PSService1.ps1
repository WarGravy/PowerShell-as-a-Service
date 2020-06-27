# make sure you adjust this to point to the folder you want to monitor
param([string]$browser = "edge")

function Get-DefaultBrowserCode{
    param($defaultBrowser)
    switch -Regex ($defaultBrowser.ToLower())
    {
        # Edge
        'ie|internet|explorer|edge' {
            return 'MSEdgeHTM'
        }
        # Firefox
        'ff|firefox' {
            return 'FirefoxURL'
        }
        # Google Chrome
        'cr|google|chrome' {
            return 'ChromeHTML'
        }
        # Safari
        'sa*|apple' {
            return 'SafariURL'
        }
        # Opera
        'op*' {
            return 'Opera.Protocol'
        }
        default {
            return 'MSEdgeHTM'
		}
    }
}
function Set-DefaultBrowser
{
    param($defaultBrowser)

    $regKey      = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\{0}\UserChoice"
    $regKeyHttp  = $regKey -f 'http'
    $regKeyHttps = $regKey -f 'https'

    $code = (Get-DefaultBrowserCode $defaultBrowser)
    Write-Host "Code: $code" -Foreground Yellow
    Set-ItemProperty $regKeyHttp  -name ProgId "$code"
    Set-ItemProperty $regKeyHttps  -name ProgId "$code"

} 

# thanks to http://newoldthing.wordpress.com/2007/03/23/how-does-your-browsers-know-that-its-not-the-default-browser/

<#
(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice').ProgId
(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice').ProgId
#>



# Set-DefaultBrowser cr
# Set-DefaultBrowser ff
# Set-DefaultBrowser ie
# Set-DefaultBrowser op
# Set-DefaultBrowser sa
try
{
    do
    {
        Wait-Event -Timeout 1
        $setting1 = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice').ProgId
        $setting2 = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice').ProgId

        if($setting1 -ne (Get-DefaultBrowserCode $browser) -or $setting2 -ne (Get-DefaultBrowserCode $browser))
        {
            Write-Host "Setting default browser: $browser" -Foreground Green
            Set-DefaultBrowser $browser
            
		}
    } while ($true)
}
finally
{
    # this gets executed when user presses CTRL+C
    Write-Host "CTRL+C detected"
}