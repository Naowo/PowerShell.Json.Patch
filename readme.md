**PowerShell json patch script**  
How to use ? 

BasePath parameter describe the base path for the path you put in the configuration 
JsonPatchConfigurationPath parameter is the path to the jsonpatchconfiguration file 

All JSON Patch opérations are supported, REPLACE, ADD, DELETE 

You con replace a whole array or object or specify an index or a property 
None of the errors break the script if an error occurs the script exit with the exit code 1 (standard on error exit code)

Why this behavior ? cause this script have been develop to be used in CI/CD pipeline on azure devops 
(and I prefer to break at the end of task and not in the middle of execution with this behavior you can see all you configurations erros in one run, but the run is stop due to the exit code)
