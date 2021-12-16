### Create a bunch of files for testing 
$directory = 'C:\Users\dbunt\Documents\TESTPATH'

### Create 10 files from today

for ($i=0; $i -lt 10; $i++) {
    ### Create Random String of letters and numbers
    $name = (([char[]]([char]'a'..[char]'z') + 0..9 | sort {get-random})[0..14] -join '')+".txt"
    $fullpath = $directory+'\'+$name

    New-Item -Path $directory -Name "$name" -ItemType "file"
}

for ($i=0; $i -lt 200; $i++) {
    ### Create Random String of letters and numbers
    $name = (([char[]]([char]'a'..[char]'z') + 0..9 | sort {get-random})[0..14] -join '')+".txt"
    $fullpath = $directory+'\'+$name

    New-Item -Path $directory -Name "$name" -ItemType "file"
    $month = ([int]1..12 | sort {get-random})[1]
    $date = ([int]1..28 | sort {get-random})[1]
    $year = ([int]2000..2021 | sort {get-random})[1]
    $hour = ([int]0..23 | sort {get-random})[1]
    $min = ([int]0..59 | sort {get-random})[1]
    $sec = ([int]0..59 | sort {get-random})[1]

    $stamp = get-date -month $month -day $date -year $year -Hour $hour -Minute $min 

    #(Get-ChildItem $fullpath).CreationTime = $stamp
    Set-ItemProperty -Path $fullpath -Name CreationTime -Value ($stamp.DateTime)
    Set-ItemProperty -Path $fullpath -Name LastWriteTime -Value ($stamp.DateTime)
}


