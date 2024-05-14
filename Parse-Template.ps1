<#
.SYNOPSIS
    Parse TOKENIZED template
.DESCRIPTION
    Takes in a TOKENIZED template string and returns a string with values in place of the tokens
    TOKENS from the template are stripped of their special characters and used to build a lst of KEYS
    The KEYS will be used to match data properties and those properties will be used to replace the TOKEN in the template.
    This function DOES support NUMERIC and DECIMAL strings. So if the data is read in from JSON it will still work
.PARAMETER template
    The TOKENIZED template string
.PARAMETER Data
    Data object that will be used to fill in template. Property names will be matched with Keys (Tokens stripped of their special characters)
.PARAMETER Formatting
    A hashtable where the property names = KEY (Tokens stripped of their special characters) and the values = a toString number format
.EXAMPLE
    C:\PS> $date = Get-Date
    C:\PS> Parse-Template -template 'Today is the %DAYOFYEAR% day of the year and its %DAYOFWEEK% The date is %MONTH% / %DAY% / %YEAR%' -InputObject $data
    
    OUTPUT: Today is the 127 day of the year and its Monday The date is 5 / 6 / 2024

    This is an overly simplified use of the function. It is intended more for parsing large template files.
.NOTES
    Author: David Bunting
    Date:   May 6, 2024
#>
Function Parse-Template() {
    Param(
        [Parameter(Mandatory, HelpMessage="Template or template fragment to parse. (Replace TOKENS with Data)")]
        [ValidateNotNullOrEmpty()]
        [String]
            $Template,
        
        [Parameter(Mandatory, HelpMessage="Data Object used to fill template tokens")]
        [Alias("InputObject","InputHashtable")]
        [ValidateNotNullOrEmpty()]
            $Data,

        [Parameter(HelpMessage="Object/Hashtable of Token Keys and output formatting options")]
        [ValidateNotNullOrEmpty()]
            $Formatting,

        [Parameter(HelpMessage='RegEx patern used to Identify tokens in Template (Default: %([^%]+)% = %TOKEN_NAME%')]
        [String]
            $TokenPatern = "%([^%]+)%"
    )

    $Tokens = @()
    
    ### Automatically pull TOKENS out of template based on the RegEx pattern provided to make TOKENS array
    
    
    (([regex]$TokenPatern).Matches($Template)).value | ForEach-Object {    
        $Tok = $_
        
        if ($Tokens -notcontains $Tok) {
            $Tokens += $Tok
        }
    }

    Foreach ($Token in $Tokens) {
        $Key = $Token.replace('%','')  ### -replace '%',''
        $value = $Data.$key

        if ($Formatting.Keys -contains $Key) {
            $format = $formatting.$key
            
            if($value -match '[\d\.\d]+') {   ### Is the Input a number regardless of TYPE
                
                if ($value -is [string]) { ### Only cast if the input is of type STRING instead of an actual [INT] or [DECIMAL]
                    
                    if ($value -match "^\d+$") {  ### [int]
                        $value = $($value -as [int]).tostring($format)
                    }
                    else {                        ### [decimal]
                        $value = $($value -as [decimal]).tostring($format)
                    }
                }
                else {
                    ### Value is of proper TYPE, just format it
                    $value = $value.tostring($format)
                }
            }
            else {
                ### Input isnt a number so... do nothing?  does this REALLY need to be here? Safety first?
                $value = $value
            }
        }

        $Template = $Template.replace($Token, $value)
    }

    return $Template
}
