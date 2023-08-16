PowerShell json patch script  
==
Compatibility : PS & PScore (might work on abrove versions too)
System compatibility: Windows 10-11 & Unix (with powershell core)

How to use ? 
=

BasePath parameter describe the base path for the path you put in the configuration 
JsonPatchConfigurationPath parameter is the path to the JsonPatchConfiguration file 

All JSON Patch opérations are supported, REPLACE, ADD, DELETE 

How to configure it ?  
-
You need a json file that contains a jsonPatch property : 

```
{
    "jsonPatch": []
}
```
Why an array there ? 
Cause you can patch multiples files in one run ! 

```
{
    "jsonPatch": [{"filePath": "path/to/my/file.json"},{"filePath": "path2/to2/my2/file2.json"}]
}
```

Ok now I can tell the script where find the json file wich must be patched so now let take a look on patch opérations. 

```
{
    "jsonPatch": [{"filePath": "path/to/my/file.json",
                   "patchOperations": [{
                        "type": "REPLACE",
                        "propertyPath": "myprop.path",
                        "value": "mapatchedvalue"
                   },
                   {
                        "type": "ADD",
                        "propertyPath": "myprop.path2",
                        "value": "mapatchedvalue2"
                   },
                   {
                        "type": "DELETE",
                        "propertyPath": "myprop.todelete",
                        "value": "mapatchedvalue"
                   }]
                }]
}
```

What can I patch ?
- 
You can patch what ever you want you can replace/delete an array element by specifing the index of item
You can add an item to an array (don't specify index in this case)
You con replace a whole array or object or specify an index or a property by passing a sub object as value  

How to run it ? 
-
So the configuration is ready ! now it's time to run ! 
Open Powershell we will assume you command line is in the folder where is the jsonPatch.ps1 script

```
./patchJson.ps1 -basePath "C:base/path/to/my/patched/files" -jsonPatchConfiguration "C:full/path/to/my/config/file.json"
```

There is no output configuration patched files are overwritten. 

Errors behavior
=
None of the errors break the script if an error occurs the script exit with the exit code 1 (standard on error exit code)

Why this behavior ? cause this script have been develop to be used in CI/CD pipeline on azure devops and in this use case I prefer to break at the end of task and not in the middle of execution with this behavior you can see all you configurations erros in one run, but the run is stop due to the exit code

However All erros are displayed in RED in the output and if an error occured during the path exploration or a patch operation, the script will exit on error (exit code -1)

Debug Helpers
=
You can set displayValue to true in each jsonPatchOperation to display the value when reading the patch operation
/!\ be carefull if you use this in a CI/CD pipelines and you use this script to patch secrets they will appear in the log output 

```
{
    "type": "ADD",
    "propertyPath": "myprop.toADD",
    "value": "mapatchedvalue",
    "displayValue": true
}
```

Note one thing if you set displayValue to false is an equivalent of removing this property by default is a false