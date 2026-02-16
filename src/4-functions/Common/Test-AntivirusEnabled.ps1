function Test-AntivirusEnabled {
    try {
        Set-Variable -Option Constant AntivirusProducts (
            @(Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName 'AntiVirusProduct' -ErrorAction Stop)
        )
    } catch {
        return $False
    }

    foreach ($Product in $AntivirusProducts) {
        [Int]$State = $Product.productState
        [Bool]$IsEnabled = ($State -shr 12) -band 1

        if ($IsEnabled) {
            return $True
        }
    }

    return $False
}
