<#
.SYNOPSIS
    Parse TOKENIZED template
.DESCRIPTION
    Takes in a TOKENIZED template string and returns a string with values in place of the tokens
.PARAMETER template
    The TOKENIZED template string
.PARAMETER InputHashtable
    A HASHTABLE that will be used to replace the tokens in the template. 
    Hashtable KEYS will be matched to the TOKENs in the template.
.PARAMETER InputObject
    An OBJECT that will be used to replace the TOKENs in the template.
    Object property names will be matched to the TOKENs in the template.
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
    [CmdletBinding(DefaultParameterSetName = 'Object')]
    Param(
        [Parameter(Mandatory,ParameterSetName = 'Hashtable')]
        [Parameter(Mandatory,ParameterSetName = 'Object')]
        [Parameter(HelpMessage="Template or template fragment to parse. (Replace TOKENS with Data)")]
        [ValidateNotNullOrEmpty()]
        [String]
            $Template,
        
        ### HASHTABLE
        [Parameter(Mandatory,ParameterSetName = 'Hashtable')]
        [ValidateScript( { $_ -is [Hashtable] })]
        [Parameter(HelpMessage="Data Object used to fill template tokens")]
        [ValidateNotNullOrEmpty()]
            $InputHashtable,

        ### OBJECT
        [Parameter(Mandatory,ParameterSetName = 'Object')]
        [ValidateScript( { $_ -is [object] })]
        [Parameter(HelpMessage="Data Object used to fill template tokens")]
        [ValidateNotNullOrEmpty()]
            $InputObject,

        [Parameter(ParameterSetName = 'Hashtable')]
        [Parameter(ParameterSetName = 'Object')]
        [Parameter(HelpMessage='RegEx patern used to Identify tokens in Template (Default: %([^%]+)% = %TOKEN_NAME%')]
        [String]
            $TokenPatern = "%([^%]+)%"
    )

    if ($inputobject) { $Data = $InputObject }
    elseif ($inputhashtable) { $Data = $inputhashtable }
    else { Throw { "Conditions out of bounds. neither INPUTOBJECT nor INPUTHASHTABLE contains a value" } }

    $Tokens = @()
    
    ### Automatically pull TOKENS out of template based on the RegEx pattern provided to make TOKENS array
    $Template.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { 
        $Token = [regex]::match($_, $TokenPatern).Value
        if (-not ([string]::IsNullOrEmpty($Token))) {
            $Tokens += $Token
        }
    }

    $Tokens | ForEach-Object {
        $Token = $_
        $Key = $Token -replace '%',''
        $Template = $Template.replace($Token, $Data.$Key)
    }

    return $Template
}
