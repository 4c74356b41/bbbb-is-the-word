Describe "Pester Routine" {
    Context "Sanity Checks" {
        It "Primary Main Page Render Test" {
            $req = Invoke-WebRequest "http://$primaryWepAppName.azurewebsites.net/" -UseBasicParsing
            $req.StatusCode | Should be 200
            $req.content.Contains('Azure High Availability PAAS and ARM templates Talk.') | Should Be $true
        }
        It "Secondary Main Page Render Test" {
            $req = Invoke-WebRequest "http://$secondaryWebAppName.azurewebsites.net/" -UseBasicParsing
            $req.StatusCode | Should be 200
            $req.content.Contains('Azure High Availability PAAS and ARM templates Talk.') | Should Be $true
        }
        It "Function Main Page Render Test" {
            $req = Invoke-WebRequest "http://$functionWebAppName.azurewebsites.net/" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Traffic Manager Test" {
            $req = Invoke-WebRequest "http://$rgName-TM.trafficmanager.net/" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "DB connectivity Test" {
            $req = Invoke-WebRequest "http://$rgName-TM.trafficmanager.net/test_db" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
    } #Context End
    Context "Logic Tests" {
        It "Primary Create Queue Test" {
            $req = Invoke-WebRequest "http://$primaryWepAppName.azurewebsites.net/create_queue?queueName=bbbb" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Primary Create Message Test" {
            $req = Invoke-WebRequest "http://$primaryWepAppName.azurewebsites.net/insert_queue?message=bbbb-is-the-word" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Secondary Create Queue Test" {
            $req = Invoke-WebRequest "http://$secondaryWebAppName.azurewebsites.net/create_queue?queueName=blabla" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Secondary Create Message Test" {
            $req = Invoke-WebRequest "http://$secondaryWebAppName.azurewebsites.net/insert_queue?message=blabla-is-the-word" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Traffic Manager Create Queue Test" {
            $req = Invoke-WebRequest "http://$rgName-TM.trafficmanager.net/create_queue?queueName=whydoyoucare" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Traffic Manager Create Message Test" {
            $req = Invoke-WebRequest "http://$rgName-TM.trafficmanager.net/insert_queue?message=trafficmanager-is-the-word" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Create Queue Fail Test" {
            try { Invoke-WebRequest "http://$rgName-TM.trafficmanager.net/create_queue?queueName=l" }
            catch { $req = $_.Exception.Response.StatusCode.Value__}
            $req | Should be 409
        }
    } #Context End
    Context "Advanced Tests" {
        It "Stop Function App" {
            Start-Sleep 45
            { Stop-AzureRmWebApp -Name $functionWebAppName -ResourceGroupName $rgName -ErrorAction Stop } | Should not Throw
            Start-Sleep 15
        }
        It "Add Some Messages" {
            $req = Invoke-WebRequest "http://$primaryWepAppName.azurewebsites.net/insert_queue?message=ftest1" -UseBasicParsing
            $req.StatusCode | Should be 200
            $req = Invoke-WebRequest "http://$primaryWepAppName.azurewebsites.net/insert_queue?message=ftest2" -UseBasicParsing
            $req.StatusCode | Should be 200
            $req = Invoke-WebRequest "http://$primaryWepAppName.azurewebsites.net/insert_queue?message=ftest3" -UseBasicParsing
            $req.StatusCode | Should be 200
        }
        It "Verify Added" {
            $req = Invoke-WebRequest "http://$primaryWepAppName.azurewebsites.net/peek_queue?queueName=bbbb" -UseBasicParsing
            $req.Content.Contains('ftest1;') | Should be True
            $req.Content.Contains('ftest2;') | Should be True
            $req.Content.Contains('ftest3;') | Should be True
        }
        It "Start Function App" {
            Start-Sleep 45
            { Start-AzureRmWebApp -Name $functionWebAppName -ResourceGroupName $rgName -ErrorAction Stop } | Should not Throw
        }
    } #Context End
} #Describe End