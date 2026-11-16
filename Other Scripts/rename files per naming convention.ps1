###renames files per naming convention - useful for tracking photos of real pages in stamp book

#get items
$path = "C:\Users\Admin\Downloads\Stamps Book 1"
$items = get-childitem -path $path -Recurse
$targetItems = $items | Where-Object -Property 'name' -ne 'bookOne_20261112_145520.jpg' #omit book image in same folder

#sort items (as modified date incorrect, end of file increments somewhat accurately though)
$targetItems | ForEach-Object {$_ | add-member -MemberType NoteProperty -Name numericName -Value $($_.Name.Split('_') | select -last 1) -Force}
$targetItems = $targetItems | sort -Property numericName

$i = 1 #count iteratively
ForEach($file in $targetItems){

    $originalName = "$($file.name)"
    $newName = "stampPage$($i)_" + $($($file.name).split('_'))[1] + "_" + $($($file.name).split('_'))[2]
    write-host "Original File Name: $($originalName), New File Name: $($newName)" -ForegroundColor Green
    Rename-Item -Path $file.FullName -NewName $newName

    $i++

}

