Function Merge-Add() {  ### HOW IS THIS NOT ALREADY A THING? ## ONLY USING "MERGE" BECAUSE ITS AN APPROVED POWERSHELL "DATA" VERB # its stupid but comes in handy
    Param(	
        [Parameter(Mandatory)]
        [Parameter(HelpMessage="Array or collection of NUMERICAL values to add together. CAN contain numeric or decimal Strings")]
            $Data
    )

    if([string]::IsNullOrEmpty($Data)) {
        Return 0
    }

    $Total = 0

    foreach ($value in $Data) {
    
        if ([string]::isnullorempty($value)) {
            Write-Warning "NULL Value Encountered. Replacing with ZERO"
            $value = 0
        }

        if ($value -is [string]) {
        
            if($value -match '[\d\.\d]+') {   ### IDENTIFIES A STRING THATS NUMERIC OR DECIMAL
        
                if ($value -match "^\d+$") {  ### [int]
                    $value = $($value -as [int]) # loosely cast to INT
                }
                else {                        ### [decimal]
                    $value = $($value -as [decimal]) # loosely cast to DECIMAL
                }
            }
            else {
                Write-Warning "Value [$Value] is not numeric. Replacing with ZERO"
                $value = 0
            }
        }

        $Total += $value
    }
    Return $Total
}
