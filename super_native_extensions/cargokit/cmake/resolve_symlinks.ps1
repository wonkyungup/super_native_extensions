function Resolve-Symlinks {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Path
    )

    [string] $separator = '/'
    [string[]] $parts = $Path.Split($separator)

    [string] $realPath = ''
    foreach ($part in $parts) {
        if ($realPath -and !$realPath.EndsWith($separator)) {
            $realPath += $separator
        }

        $realPath += $part.Replace('\', '/')

        # The slash is important when using Get-Item on Drive letters in pwsh.
        if (-not($realPath.Contains($separator)) -and $realPath.EndsWith(':')) {
            $realPath += '/'
        }

        # -Force is required so Get-Item can read hidden/system folders such as
        # %LOCALAPPDATA% (the pub cache lives under a hidden AppData path). Without
        # it, resolving the cache path throws and the Windows build fails.
        $item = Get-Item -Force $realPath
        if ($item.LinkTarget) {
            $realPath = $item.LinkTarget.Replace('\', '/')
        }
    }
    $realPath
}

$path = Resolve-Symlinks -Path $args[0]
Write-Host $path
