**PowerShell json patch script**  
How to use ? 

BasePath parameter describe the base path for the path you put in the configuration 
JsonPatchConfigurationPath parameter is the path to the jsonpatchconfiguration file 

All JSON Patch opérations are supported, REPLACE, ADD, DELETE 

You con replace a whole array or object or specify an index or a property 

Ok so how can I configure my json patch ? 

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

Ok now I can tell the script where find the json file wich must be patch so now let take a look on patch opérations. 

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
You can patch what ever you want you can replace/delete an array element by specifing the index of item
You can patch a whole object "one shot" by passing a sub object as value  
You can add an item to an array (don't specify index in this case)

None of the errors break the script if an error occurs the script exit with the exit code 1 (standard on error exit code)

Why this behavior ? cause this script have been develop to be used in CI/CD pipeline on azure devops 

(and I prefer to break at the end of task and not in the middle of execution with this behavior you can see all you configurations erros in one run, but the run is stop due to the exit code)


