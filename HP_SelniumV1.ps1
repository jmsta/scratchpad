$filePath="c:\temp\hp\"
# list of computers from AD that are HP based on first characters of serial number...  Last letter trimed because its not part of the serial number in our environment.  
$comps = (get-adcomputer -filter * |where {$_.name -like "MX*" -or $_.name -like "5CG*" -or $_.name -like "2U*" }).name|Foreach{$_.Substring(0, $_.Length - 1) }

Import-Module Selenium

$driver = Start-SeFirefox

foreach($comp in $comps|select -first 50  ){
    #Load HPs warranty check site  
    $driver.Navigate().GoToUrl("https://support.hp.com/us-en/check-warranty")
    
    #Give it some time to fully load
    start-sleep -Seconds 5
    
    #Find field and enter serial number  
    $formField = $Driver.FindElementById("inputtextpfinder")
    $formField.SendKeys("$comp")
    
    #Find Submit Button and click it
    $submitButton = $Driver.FindElementByID("FindMyProduct")
    $submitButton.Click()
    
    #give results some time to load"
    start-sleep -seconds 5
    #get all the relevant data 
    $divModel= $Driver.FindElementByXPath("//div[contains(@class, 'ng-tns')]")
    
    #save results it to a file 
    $divmodel.Text|out-file "$filepath\$comp.txt"

}

Stop-SeDriver  
