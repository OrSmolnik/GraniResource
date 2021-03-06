﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_S3Content : *-TargetResource" {

    $path = "c:\hoge\ReadMe.md"
    $parent = Split-Path -Path $path -Parent

    # $bucketName = [Guid]::NewGuid()
    $bucketName = '8f7a6322-4fee-44f1-a2eb-533a7e9dff33'
    # $key =     [Guid]::NewGuid()
    $key = '8f7a6322-4fee-44f1-a2eb-533a7e9dff33'
    $checksum = "FileName"

    New-Item -Path $parent -ItemType Directory -Force > $null
    New-Item -Path $path -ItemType File -Force  > $null
    1..10 | Get-Random -Count 10 | Out-File -FilePath $path -Append -Force > $null

    New-S3Bucket -BucketName $bucketName > $null
    Write-S3Object -BucketName $bucketName -Key $key -File $path
    Remove-Item -Path $parent -Recurse -Force > $null

    #region CheckSum : FileHash
    Context "Scratch environment. CheckSum : FileHash " {
        It "Get-TargetResource should not throw for invalid S3Bucket" {
            {Get-TargetResource -S3BucketName "hogemoge$bucketName" -Key $key -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should not throw for invalid S3Object" {
            {Get-TargetResource -S3BucketName "$bucketName" -Key "$key-$bucketName" -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should not throw for invalid Path" {
            {Get-TargetResource -S3BucketName "$bucketName" -Key "$key" -DestinationPath "$path-$bucketName"} | should not Throw
        }

        It "Get-TargetResource should not throw for invalid S3Bucket / S3Object / Path" {
            {Get-TargetResource -S3BucketName "$hogemoge$bucketName" -Key "$key-$bucketName" -DestinationPath "$path-$bucketName"} | should not Throw
        }

        It "Get-TargetResource should not throw for valid S3Bucket / S3Object" {
            {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path} | should not Throw
        }

        $result = Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
        }

        It "Get-TargetResource should return DestinationPath : $path" {
            $result.DestinationPath | should be $path
        }

        It "Get-TargetResource should return BucketName : $bucketName" {
            $result.S3BucketName | should be $bucketName
        }

        It "Get-TargetResource should return Key : $key" {
            $result.Key | should be $key
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path | should be $true
        }
    }

    Context "Already configured environment. CheckSum : FileHash " {
        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path | should be $true
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path | should be $true
        }
    }

    Context "Already configured but delete file environment. CheckSum : FileHash " {
        Remove-Item -Path $path -Force

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path | should be $true
        }
    }

    Context "Exist same name Folder environment. CheckSum : FileHash " {
        Remove-Item -Path $path -Force
        New-Item -Path $path -ItemType Directory > $null

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path} | should Throw
        }
    }
 
    Remove-Item -Path $parent -Recurse -Force

    #endregion

    #region CheckSum : FileName

    Context "Scratch environment. CheckSum : FileName " {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum} | should not Throw
        }

        $result = Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
        }

        It "Get-TargetResource should return DestinationPath : $path" {
            $result.DestinationPath | should be $path
        }

        It "Get-TargetResource should return BucketName : $bucketName" {
            $result.S3BucketName | should be $bucketName
        }

        It "Get-TargetResource should return Key : $key" {
            $result.Key | should be $key
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum | should be $true
        }
    }

    Context "Already configured environment. CheckSum : FileHash " {
        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum | should be $true
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum | should be $true
        }
    }

    Context "Already configured but delete file environment. CheckSum : FileHash " {
        Remove-Item -Path $path -Force

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum | should be $true
        }
    }

    Context "Exist same name Folder environment. CheckSum : FileHash " {
        Remove-Item -Path $path -Force
        New-Item -Path $path -ItemType Directory > $null

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum} | should Throw
        }
    }

    Remove-S3Bucket -BucketName $bucketName -DeleteBucketContent -Force
    Remove-Item -Path $parent -Recurse -Force

    #endregion    
}