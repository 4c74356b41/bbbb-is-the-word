# bbbb-is-the-word

This is a repo for my "Azure High Availability PAAS and ARM templates" talk. For the Jenkins container you could use this http://4c74356b41.com/?p=5671 or use your own Jenkins.

Master Branch is for the "release" version.  
FeatureX Branch is for the "feature" version. Jenkins grabs data from feature branchand pushes changes to master.  
Function Branch is for the Functions App code.

_arm folder is for the ARM Templates  
FlaskWebApp folder is for the python App code  
deployment.tests.ps1 - Pester Tests that check the App stability  
jenkinsjob.ps1 - contains code for the Jenkins job  
Azure High Availability PAAS and ARM templates.pptx - presentation ;)

Message me for questions https://twitter.com/4c74356b41
