Param([string]$basePath,[string]$jsonPatchConfigurationPath);

##########################
#Format JSON Output      #
##########################
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  $indent = 0;
  ($json -Split '\n' |
    % {
      if ($_ -match '[\}\]]') {
        # This line contains  ] or }, decrement the indentation level
        $indent--
      }
      $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
      if ($_ -match '[\{\[]') {
        # This line contains [ or {, increment the indentation level
        $indent++
      }
      $line
  }) -Join "`n"
}

##########################
#Check If the Item is    #
#not null during path    #
#exploration             #
##########################
function Item-Not-Null([Parameter(ValueFromPipeline)][Object] $item){
	if ($item -eq $null){
		Write-Host -Foregroundcolor red "The current path exploration failed this patch operation for path: $($patchOperationPropertyPath), `nfor the following operation: $($patchOperationType.ToUpper())";
		if ($patchOperation.displayValue){
			Write-Host -Foregroundcolor red "with value: $patchOperationValue";
			$isOnError=$true;
			break;
		}
	}
}

##########################
#Global script variables #
##########################
$isOnError = $false;
$errorsReport = @();

##########################
#Display script parameter#
##########################
echo $jsonPatchConfigurationPath;
echo $basePath;

##########################
#Get JsonPatchConfig     #
##########################
$json2 = Get-Content $jsonPatchConfigurationPath -raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop;
echo $json2.jsonPatch[0];
$jsonPatchConfiguration = $json2.jsonPatch;

##########################
#Patch JSON file         #
##########################
foreach ($fileWithPatchOperations in $jsonPatchConfiguration){
	$filePath = "$basePath\$($fileWithPatchOperations.filePath)";
	echo "`nRetrieving the file at path : $filePath";

	try{
		$json = Get-Content $filePath -raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop;
		
	}
	catch{
		Write-Error -Exception $PSItem.Exception
		$isOnError=$true;
		#iterator.next & break current iteration
		continue
	}

	echo "`nFile Retrieved at : $filePath";

	$patchOperations = $fileWithPatchOperations.patchOperations;
	foreach ($patchOperation in $patchOperations){
		$patchOperationType = $patchOperation.type;
		$patchOperationPropertyPath = $patchOperation.propertyPath;
		$patchOperationValue = $patchOperation.value;

		echo "";
		echo "Patch Operation detected with the following configuration";
		echo "Patch Operation Type : $($patchOperationType.ToUpper())";
		echo "Patch Operation PropertyPath : $patchOperationPropertyPath";
		
		if($patchOperation.displayValue)
		{
			echo "Patch Operation Value : $patchOperationValue";
		}

		$splitPath = $patchOperationPropertyPath.split(".");;
		$item = $json; 
		echo "Property path exploring in progress";
		foreach($part in $splitPath){
			$isArrayPath = $part -match '(.*)\[(.)\]$';

			if ($part -ne $splitPath[-1]){
				if ($isArrayPath){
					$item = $item.$($Matches[1]);
					$item | Item-Not-Null;
					$item = $item[$Matches[2]];
				}
				else {
					$item = $item.$($part);
				}

				$item | Item-Not-Null;
			}
			else {
				echo "Patching property : $patchOperationPropertyPath";
				if ($patchOperationType.ToUpper() -eq "REPLACE"){
					if ($isArrayPath){
						$item = $item.$($Matches[1]);
						$item | Item-Not-Null;
						$isArray = $item -is [array];
						if ($isArray -and $item.Count -gt $Matches[2]){
							$item[$Matches[2]] = $patchOperationValue;
						}
						else {
							Write-Host -Foregroundcolor red "The current path exploration failed this patch operation for path: $($patchOperationPropertyPath), `nfor the following operation: $($patchOperationType.ToUpper())";
							if ($isArray){
								Write-Host -Foregroundcolor red "The given index $($Matches[2]) is out of bound arrayLength : $($item.Count)";
							}
							else {
								Write-Host -Foregroundcolor red "The targeted property is not an array, it's an $($item.GetType().ToString())";
							}
							$isOnError=$true;
							break;
						}
					}
					else {
						$item | Add-Member -Force @{$part=$patchOperationValue};
					}
				}
				elseif ($patchOperationType.ToUpper() -eq "ADD"){
					if($isArrayPath){
						$item = $item.$($Matches[1]);
						$item | Item-Not-Null;
						$isArray = $item -is [array];
						
						if ($isArray){
							$item += $patchOperationValue;
					
							if ($item.Count -gt $Matches[2]){
								Write-Warning "The given index $($Matches[2]) is not a contiguous index, the array contains currently $($item.Count), the index is ignore";
								Write-Warning "When performing an ADD operation on an array remove the index indication";
							}
						}
						else {
							Write-Host -Foregroundcolor red "The current path exploration failed this patch operation for path: $($patchOperationPropertyPath), `nfor the following operation: $($patchOperationType.ToUpper())";
							Write-Host -Foregroundcolor red "The targeted property is not an array, it's an $($item.GetType().ToString())";
							$isOnError=$true;
							break;
						}
					}
					else {
						if ($item.$($part) -is [array]){
							$item.$($part) += $patchOperationValue;
						}
						else{
							$item | Add-Member -Force @{$part=$patchOperationValue};
						}
					}
				}
				elseif ($patchOperationType.ToUpper() -eq "DELETE"){
					if ($isArrayPath){
						$item = $item.$($Matches[1]);
						$itemList = [System.Collections.ArrayList]$item;
						$itemList.Remove($Matches[2]);
						$item = $itemList.ToArray();
					}
					else {
						$item.PSObject.Properties.Remove($part);
					}
				}
			}
		}
	}

	$json | ConvertTo-Json -depth 32 |Format-Json| set-content $filePath;

	if(!$isOnError){
		exit 0
	}else{
		exit 1;
	}
}



