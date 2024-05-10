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
        [Parameter(Mandatory)]
        [Parameter(HelpMessage="Template or template fragment to parse. (Replace TOKENS with Data)")]
        [ValidateNotNullOrEmpty()]
        [String]
            $Template,
        
        [Parameter(Mandatory)]
        [Parameter(HelpMessage="Data Object used to fill template tokens")]
        [Alias("InputObject")]
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
    $Template.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { 
        $Token = [regex]::match($_, $TokenPatern).Value
        if (-not ([string]::IsNullOrEmpty($Token))) {
            $Tokens += $Token
        }
    }

    Foreach ($Token in $Tokens) {
        $Key = $Token.replace('%','')  ### -replace '%',''
        $value = $Data.$key

        if ($Formatting.Keys -contains $Key) {
            $format = $formatting.$key

            ### make sure Numeric and Decimal strings are converted properly even thought they are of type [string]
            if ($value -is [string]) {

                if($value -match '[\d\.\d]+') {   ### IDENTIFIES A STRING THATS NUMERIC OR DECIMAL

                    if ($value -match "^\d+$") {  ### [int]
                        $value = $($value -as [int]).tostring($format)
                    }
                    else {                        ### [decimal]
                        $value = $($value -as [decimal]).tostring($format)
                    }

                }
                else {
                    ### ITS A NON-NUMERIC STRING, NO FORMATTING NEEDED
                    $value = $value #Safety First?
                }

            }
            else {
                $value = $value.tostring($format)
            }

        }

        $Template = $Template.replace($Token, $value)
    }

    return $Template
}
