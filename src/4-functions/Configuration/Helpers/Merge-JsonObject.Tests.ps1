BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestSourceObject (
        [PSCustomObject]@{
            TEST_SOURCE_STRING          = 'TEST_SOURCE_STRING_VALUE'
            TEST_SOURCE_EMPTY           = ''
            TEST_SOURCE_NUMBER          = 1
            TEST_SOURCE_ZERO            = 0
            TEST_SOURCE_NUMBER_NEGATIVE = -1
            TEST_SOURCE_NULL            = $Null
            TEST_SOURCE_TRUE            = $True
            TEST_SOURCE_FALSE           = $False
            TEST_SOURCE_OBJECT_EMPTY    = @{}
            TEST_SOURCE_ARRAY           = @(
                'TEST_SOURCE_ARRAY_STRING_VALUE',
                '',
                11,
                0,
                -11,
                $Null,
                $True,
                $False,
                @{},
                @(111, 112, 113),
                @{ TEST_SOURCE_ARRAY_OBJECT_KEY = 'TEST_SOURCE_ARRAY_OBJECT_VALUE' }
            )
            TEST_SOURCE_OBJECT          = @{
                TEST_SOURCE_OBJECT_STRING              = 'TEST_SOURCE_OBJECT_STRING_VALUE'
                TEST_SOURCE_OBJECT_EMPTY               = ''
                TEST_SOURCE_OBJECT_NUMBER              = 23
                TEST_SOURCE_OBJECT_ZERO                = 0
                TEST_SOURCE_OBJECT_NUMBER_NEGATIVE     = -32
                TEST_SOURCE_OBJECT_NULL                = $Null
                TEST_SOURCE_OBJECT_TRUE                = $True
                TEST_SOURCE_OBJECT_FALSE               = $False
                TEST_SOURCE_OBJECT_NESTED_OBJECT_EMPTY = @{}
                TEST_SOURCE_OBJECT_ARRAY_EMPTY         = @()
                TEST_SOURCE_OBJECT_ARRAY               = @(
                    'SOURCE_OBJECT_ARRAY_VALUE_1',
                    'SOURCE_OBJECT_ARRAY_VALUE_2'
                )
                TEST_SOURCE_OBJECT_NESTED_OBJECT       = @{
                    TEST_SOURCE_NESTED_OBJECT_KEY_1 = 'TEST_SOURCE_NESTED_OBJECT_VALUE_1'
                    TEST_SOURCE_NESTED_OBJECT_KEY_2 = 'TEST_SOURCE_NESTED_OBJECT_VALUE_2'
                }
            }
            TEST_STRING                 = 'TEST_STRING_SOURCE'
            TEST_FROM_EMPTY             = ''
            TEST_TO_EMPTY               = 'TEST_TO_EMPTY_SOURCE'
            TEST_NUMBER                 = 123
            TEST_ZERO                   = 0
            TEST_FROM_ZERO              = 0
            TEST_TO_ZERO                = 321
            TEST_NULL                   = $Null
            TEST_FROM_NULL              = $Null
            TEST_TRUE                   = $True
            TEST_FROM_TRUE              = $True
            TEST_TO_TRUE                = $False
            TEST_FALSE                  = $False
            TEST_FROM_FALSE             = $False
            TEST_TO_FALSE               = $True
            TEST_OBJECT_EMPTY           = @{}
            TEST_TO_OBJECT_EMPTY        = @{}
            TEST_FROM_OBJECT_EMPTY      = @{ TEST_FROM_OBJECT_EMPTY_KEY = 'TEST_FROM_OBJECT_EMPTY_VALUE' }
            TEST_OBJECT                 = @{
                TEST_OBJECT_KEY           = 'TEST_OBJECT_KEY_VALUE_SOURCE'
                TEST_OBJECT_NESTED_OBJECT = @{
                    TEST_NESTED_OBJECT_KEY_1 = 'TEST_NESTED_OBJECT_VALUE_1_SOURCE'
                    TEST_NESTED_OBJECT_KEY_2 = 'TEST_NESTED_OBJECT_VALUE_2_SOURCE'
                }
            }
            TEST_FULL_ARRAY             = @(
                'TEST_ARRAY_ITEM_1_SOURCE',
                'TEST_ARRAY_ITEM_2_SOURCE'
            )
            TEST_INCREASE_ARRAY         = @(
                'TEST_ARRAY_ITEM_1_SOURCE'
            )
            TEST_DECREASE_ARRAY         = @(
                'TEST_ARRAY_ITEM_1_SOURCE',
                'TEST_ARRAY_ITEM_2_SOURCE'
            )
        }
    )

    Set-Variable -Option Constant TestExtendObject (
        [PSCustomObject]@{
            TEST_EXTEND_STRING          = 'TEST_EXTEND_STRING_VALUE'
            TEST_EXTEND_EMPTY           = ''
            TEST_EXTEND_NUMBER          = 1
            TEST_EXTEND_ZERO            = 0
            TEST_EXTEND_NUMBER_NEGATIVE = -1
            TEST_EXTEND_NULL            = $Null
            TEST_EXTEND_TRUE            = $True
            TEST_EXTEND_FALSE           = $False
            TEST_EXTEND_OBJECT_EMPTY    = @{}
            TEST_EXTEND_ARRAY           = @(
                'TEST_EXTEND_ARRAY_STRING_VALUE',
                '',
                11,
                0,
                -11,
                $Null,
                $True,
                $False,
                @{},
                @(111, 112, 113),
                @{ TEST_EXTEND_ARRAY_OBJECT_KEY = 'TEST_EXTEND_ARRAY_OBJECT_VALUE' }
            )
            TEST_EXTEND_OBJECT          = @{
                TEST_EXTEND_OBJECT_STRING              = 'TEST_EXTEND_OBJECT_STRING_VALUE'
                TEST_EXTEND_OBJECT_EMPTY               = ''
                TEST_EXTEND_OBJECT_NUMBER              = 23
                TEST_EXTEND_OBJECT_ZERO                = 0
                TEST_EXTEND_OBJECT_NUMBER_NEGATIVE     = -32
                TEST_EXTEND_OBJECT_NULL                = $Null
                TEST_EXTEND_OBJECT_TRUE                = $True
                TEST_EXTEND_OBJECT_FALSE               = $False
                TEST_EXTEND_OBJECT_NESTED_OBJECT_EMPTY = @{}
                TEST_EXTEND_OBJECT_ARRAY_EMPTY         = @()
                TEST_EXTEND_OBJECT_ARRAY               = @(
                    'SOURCE_OBJECT_ARRAY_VALUE_1',
                    'SOURCE_OBJECT_ARRAY_VALUE_2'
                )
                TEST_EXTEND_OBJECT_NESTED_OBJECT       = @{
                    TEST_EXTEND_NESTED_OBJECT_KEY_1 = 'TEST_EXTEND_NESTED_OBJECT_VALUE_1'
                    TEST_EXTEND_NESTED_OBJECT_KEY_2 = 'TEST_EXTEND_NESTED_OBJECT_VALUE_2'
                }
            }
            TEST_STRING                 = 'TEST_STRING_EXTEND'
            TEST_FROM_EMPTY             = 'TEST_FROM_EMPTY_EXTEND'
            TEST_TO_EMPTY               = ''
            TEST_NUMBER                 = 456
            TEST_ZERO                   = 0
            TEST_FROM_ZERO              = 654
            TEST_TO_ZERO                = 0
            TEST_NULL                   = $Null
            TEST_FROM_NULL              = 789
            TEST_TRUE                   = $True
            TEST_FROM_TRUE              = $False
            TEST_TO_TRUE                = $True
            TEST_FALSE                  = $False
            TEST_FROM_FALSE             = $True
            TEST_TO_FALSE               = $False
            TEST_OBJECT_EMPTY           = @{}
            TEST_TO_OBJECT_EMPTY        = @{ TEST_TO_OBJECT_EMPTY_KEY = 'TEST_TO_OBJECT_EMPTY_VALUE' }
            TEST_FROM_OBJECT_EMPTY      = @{}
            TEST_OBJECT                 = @{
                TEST_OBJECT_KEY           = 'TEST_OBJECT_KEY_VALUE_EXTEND'
                TEST_OBJECT_NESTED_OBJECT = @{
                    TEST_NESTED_OBJECT_KEY_1 = 'TEST_NESTED_OBJECT_VALUE_1_EXTEND'
                    TEST_NESTED_OBJECT_KEY_2 = 'TEST_NESTED_OBJECT_VALUE_2_EXTEND'
                }
            }
            TEST_FULL_ARRAY             = @(
                'TEST_ARRAY_ITEM_3_EXTEND',
                'TEST_ARRAY_ITEM_4_EXTEND'
            )
            TEST_INCREASE_ARRAY         = @(
                'TEST_ARRAY_ITEM_3_EXTEND',
                'TEST_ARRAY_ITEM_4_EXTEND'
            )
            TEST_DECREASE_ARRAY         = @(
                'TEST_ARRAY_ITEM_3_EXTEND'
            )
        }
    )

    Set-Variable -Option Constant TestUpdatedConfigObject (
        [PSCustomObject]@{
            TEST_SOURCE_STRING          = 'TEST_SOURCE_STRING_VALUE'
            TEST_SOURCE_EMPTY           = ''
            TEST_SOURCE_NUMBER          = 1
            TEST_SOURCE_ZERO            = 0
            TEST_SOURCE_NUMBER_NEGATIVE = -1
            TEST_SOURCE_NULL            = $Null
            TEST_SOURCE_TRUE            = $True
            TEST_SOURCE_FALSE           = $False
            TEST_SOURCE_OBJECT_EMPTY    = @{}
            TEST_SOURCE_ARRAY           = @(
                'TEST_SOURCE_ARRAY_STRING_VALUE',
                '',
                11,
                0,
                -11,
                $Null,
                $True,
                $False,
                @{},
                @(111, 112, 113),
                @{ TEST_SOURCE_ARRAY_OBJECT_KEY = 'TEST_SOURCE_ARRAY_OBJECT_VALUE' }
            )
            TEST_SOURCE_OBJECT          = @{
                TEST_SOURCE_OBJECT_STRING              = 'TEST_SOURCE_OBJECT_STRING_VALUE'
                TEST_SOURCE_OBJECT_EMPTY               = ''
                TEST_SOURCE_OBJECT_NUMBER              = 23
                TEST_SOURCE_OBJECT_ZERO                = 0
                TEST_SOURCE_OBJECT_NUMBER_NEGATIVE     = -32
                TEST_SOURCE_OBJECT_NULL                = $Null
                TEST_SOURCE_OBJECT_TRUE                = $True
                TEST_SOURCE_OBJECT_FALSE               = $False
                TEST_SOURCE_OBJECT_NESTED_OBJECT_EMPTY = @{}
                TEST_SOURCE_OBJECT_ARRAY_EMPTY         = @()
                TEST_SOURCE_OBJECT_ARRAY               = @(
                    'SOURCE_OBJECT_ARRAY_VALUE_1',
                    'SOURCE_OBJECT_ARRAY_VALUE_2'
                )
                TEST_SOURCE_OBJECT_NESTED_OBJECT       = @{
                    TEST_SOURCE_NESTED_OBJECT_KEY_1 = 'TEST_SOURCE_NESTED_OBJECT_VALUE_1'
                    TEST_SOURCE_NESTED_OBJECT_KEY_2 = 'TEST_SOURCE_NESTED_OBJECT_VALUE_2'
                }
            }
            TEST_STRING                 = 'TEST_STRING_EXTEND'
            TEST_FROM_EMPTY             = 'TEST_FROM_EMPTY_EXTEND'
            TEST_TO_EMPTY               = ''
            TEST_NUMBER                 = 456
            TEST_ZERO                   = 0
            TEST_FROM_ZERO              = 654
            TEST_TO_ZERO                = 0
            TEST_NULL                   = $Null
            TEST_FROM_NULL              = 789
            TEST_TRUE                   = $True
            TEST_FROM_TRUE              = $False
            TEST_TO_TRUE                = $True
            TEST_FALSE                  = $False
            TEST_FROM_FALSE             = $True
            TEST_TO_FALSE               = $False
            TEST_OBJECT_EMPTY           = @{}
            TEST_TO_OBJECT_EMPTY        = @{ TEST_TO_OBJECT_EMPTY_KEY = 'TEST_TO_OBJECT_EMPTY_VALUE' }
            TEST_FROM_OBJECT_EMPTY      = @{}
            TEST_OBJECT                 = @{
                TEST_OBJECT_KEY           = 'TEST_OBJECT_KEY_VALUE_EXTEND'
                TEST_OBJECT_NESTED_OBJECT = @{
                    TEST_NESTED_OBJECT_KEY_1 = 'TEST_NESTED_OBJECT_VALUE_1_EXTEND'
                    TEST_NESTED_OBJECT_KEY_2 = 'TEST_NESTED_OBJECT_VALUE_2_EXTEND'
                }
            }
            TEST_FULL_ARRAY             = @(
                'TEST_ARRAY_ITEM_3_EXTEND',
                'TEST_ARRAY_ITEM_4_EXTEND'
            )
            TEST_INCREASE_ARRAY         = @(
                'TEST_ARRAY_ITEM_3_EXTEND',
                'TEST_ARRAY_ITEM_4_EXTEND'
            )
            TEST_DECREASE_ARRAY         = @(
                'TEST_ARRAY_ITEM_3_EXTEND',
                'TEST_ARRAY_ITEM_2_SOURCE'
            )
            TEST_EXTEND_STRING          = 'TEST_EXTEND_STRING_VALUE'
            TEST_EXTEND_EMPTY           = ''
            TEST_EXTEND_NUMBER          = 1
            TEST_EXTEND_ZERO            = 0
            TEST_EXTEND_NUMBER_NEGATIVE = -1
            TEST_EXTEND_NULL            = $Null
            TEST_EXTEND_TRUE            = $True
            TEST_EXTEND_FALSE           = $False
            TEST_EXTEND_OBJECT_EMPTY    = @{}
            TEST_EXTEND_ARRAY           = @(
                'TEST_EXTEND_ARRAY_STRING_VALUE',
                '',
                11,
                0,
                -11,
                $Null,
                $True,
                $False,
                @{},
                @(111, 112, 113),
                @{ TEST_EXTEND_ARRAY_OBJECT_KEY = 'TEST_EXTEND_ARRAY_OBJECT_VALUE' }
            )
            TEST_EXTEND_OBJECT          = @{
                TEST_EXTEND_OBJECT_STRING              = 'TEST_EXTEND_OBJECT_STRING_VALUE'
                TEST_EXTEND_OBJECT_EMPTY               = ''
                TEST_EXTEND_OBJECT_NUMBER              = 23
                TEST_EXTEND_OBJECT_ZERO                = 0
                TEST_EXTEND_OBJECT_NUMBER_NEGATIVE     = -32
                TEST_EXTEND_OBJECT_NULL                = $Null
                TEST_EXTEND_OBJECT_TRUE                = $True
                TEST_EXTEND_OBJECT_FALSE               = $False
                TEST_EXTEND_OBJECT_NESTED_OBJECT_EMPTY = @{}
                TEST_EXTEND_OBJECT_ARRAY_EMPTY         = @()
                TEST_EXTEND_OBJECT_ARRAY               = @(
                    'SOURCE_OBJECT_ARRAY_VALUE_1',
                    'SOURCE_OBJECT_ARRAY_VALUE_2'
                )
                TEST_EXTEND_OBJECT_NESTED_OBJECT       = @{
                    TEST_EXTEND_NESTED_OBJECT_KEY_1 = 'TEST_EXTEND_NESTED_OBJECT_VALUE_1'
                    TEST_EXTEND_NESTED_OBJECT_KEY_2 = 'TEST_EXTEND_NESTED_OBJECT_VALUE_2'
                }
            }
        }
    )
}

Describe 'Merge-JsonObject' {
    It 'Should merge two JSON objects' {
        Set-Variable -Option Constant Result ([String](Merge-JsonObject $TestSourceObject $TestExtendObject | ConvertTo-Json -Depth 10 -Compress))
        Set-Variable -Option Constant Expected ([String]($TestUpdatedConfigObject | ConvertTo-Json -Depth 10 -Compress))

        $Result | Should -BeExactly $Expected
    }
}
