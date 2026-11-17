# CloudFlare's resolvers, preferred and alternate, for IPv4 and for IPv6: on a dual-stack network a resolver left as it
# was in either family would answer around the filtering
function Get-CloudFlareDnsAddress {
    return @{
        Default           = @{ IPv4 = @('1.1.1.1', '1.0.0.1'); IPv6 = @('2606:4700:4700::1111', '2606:4700:4700::1001') }
        MalwareProtection = @{ IPv4 = @('1.1.1.2', '1.0.0.2'); IPv6 = @('2606:4700:4700::1112', '2606:4700:4700::1002') }
        FamilyFriendly    = @{ IPv4 = @('1.1.1.3', '1.0.0.3'); IPv6 = @('2606:4700:4700::1113', '2606:4700:4700::1003') }
    }
}
