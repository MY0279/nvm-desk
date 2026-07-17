<#
NVM Version Manager - PowerShell GUI
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$NvmRoot = "D:\Program Files\Roaming\nvm"
$Global:StatusLabel = $null
$Global:MainForm = $null

function Get-InstalledVersions {
    $versions = @()
    if (Test-Path $NvmRoot) {
        Get-ChildItem $NvmRoot -Directory | Where-Object {
            $_.Name -match "^v\d" -and (Test-Path (Join-Path $_.FullName "node.exe"))
        } | ForEach-Object {
            $versions += $_.Name
        }
    }
    $versions = $versions | Sort-Object { [Version]($_.TrimStart("v")) } -Descending
    return ,$versions
}

function Get-CurrentVersion {
    try {
        $result = & node --version 2>$null
        if ($LASTEXITCODE -eq 0) { return $result.Trim() }
    } catch {}
    return "unknown"
}

function Get-NpmVersion {
    try {
        $result = & npm --version 2>$null
        if ($LASTEXITCODE -eq 0) { return $result.Trim() }
    } catch {}
    return "unknown"
}

function Build-UI {
    param($Form)

    $current = Get-CurrentVersion
    $npmVer = Get-NpmVersion
    $installed = Get-InstalledVersions

    $font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)
    $boldFont = New-Object System.Drawing.Font("Microsoft YaHei UI", 18, [System.Drawing.FontStyle]::Bold)
    $monoFont = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
    $monoNorm = New-Object System.Drawing.Font("Consolas", 12)
    $smallFont = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
    $tinyFont = New-Object System.Drawing.Font("Microsoft YaHei UI", 8)
    $groupFont = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
    $green = [System.Drawing.Color]::FromArgb(39, 174, 96)
    $blue = [System.Drawing.Color]::FromArgb(52, 152, 219)
    $orange = [System.Drawing.Color]::FromArgb(230, 126, 34)

    # Title row
    $titleRow = New-Object System.Windows.Forms.Panel
    $titleRow.Location = New-Object System.Drawing.Point(20, 12)
    $titleRow.Size = New-Object System.Drawing.Size(480, 40)
    $Form.Controls.Add($titleRow)

    $title = New-Object System.Windows.Forms.Label
    $title.Text = "NVM Version Manager"
    $title.Font = $boldFont
    $title.Location = New-Object System.Drawing.Point(0, 0)
    $title.AutoSize = $true
    $titleRow.Controls.Add($title)

    $disclaimer = New-Object System.Windows.Forms.Label
    $disclaimer.Text = "For learning purposes only"
    $disclaimer.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
    $disclaimer.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
    $disclaimer.Location = New-Object System.Drawing.Point(300, 12)
    $disclaimer.AutoSize = $true
    $titleRow.Controls.Add($disclaimer)

    # Current environment
    $infoGroup = New-Object System.Windows.Forms.GroupBox
    $infoGroup.Text = "Current Environment"
    $infoGroup.Font = $groupFont
    $infoGroup.Location = New-Object System.Drawing.Point(20, 55)
    $infoGroup.Size = New-Object System.Drawing.Size(480, 90)
    $Form.Controls.Add($infoGroup)

    $nodeTitle = New-Object System.Windows.Forms.Label
    $nodeTitle.Text = "Node.js"
    $nodeTitle.Font = $font
    $nodeTitle.Location = New-Object System.Drawing.Point(15, 25)
    $nodeTitle.AutoSize = $true
    $infoGroup.Controls.Add($nodeTitle)

    $nodeVer = New-Object System.Windows.Forms.Label
    $nodeVer.Text = $current
    $nodeVer.Font = $monoFont
    $nodeVer.ForeColor = $green
    $nodeVer.Location = New-Object System.Drawing.Point(95, 22)
    $nodeVer.AutoSize = $true
    $infoGroup.Controls.Add($nodeVer)

    $npmTitle = New-Object System.Windows.Forms.Label
    $npmTitle.Text = "npm"
    $npmTitle.Font = $font
    $npmTitle.Location = New-Object System.Drawing.Point(260, 25)
    $npmTitle.AutoSize = $true
    $infoGroup.Controls.Add($npmTitle)

    $npmLabel = New-Object System.Windows.Forms.Label
    $npmLabel.Text = $npmVer
    $npmLabel.Font = $monoFont
    $npmLabel.ForeColor = $blue
    $npmLabel.Location = New-Object System.Drawing.Point(310, 22)
    $npmLabel.AutoSize = $true
    $infoGroup.Controls.Add($npmLabel)

    $Global:StatusLabel = New-Object System.Windows.Forms.Label
    $Global:StatusLabel.Text = ""
    $Global:StatusLabel.Font = $smallFont
    $Global:StatusLabel.ForeColor = $orange
    $Global:StatusLabel.Location = New-Object System.Drawing.Point(15, 58)
    $Global:StatusLabel.AutoSize = $true
    $infoGroup.Controls.Add($Global:StatusLabel)

    # Version list
    $listGroup = New-Object System.Windows.Forms.GroupBox
    $listGroup.Text = "Installed Versions"
    $listGroup.Font = $groupFont
    $listGroup.Location = New-Object System.Drawing.Point(20, 155)
    $listGroup.Size = New-Object System.Drawing.Size(480, 200)
    $Form.Controls.Add($listGroup)

    if ($installed.Count -eq 0) {
        $emptyLabel = New-Object System.Windows.Forms.Label
        $emptyLabel.Text = "No Node.js versions detected"
        $emptyLabel.ForeColor = [System.Drawing.Color]::Gray
        $emptyLabel.Location = New-Object System.Drawing.Point(15, 80)
        $emptyLabel.AutoSize = $true
        $listGroup.Controls.Add($emptyLabel)
        $tip = New-Object System.Windows.Forms.Label
        $tip.Text = "Tip: Click [Yes] on UAC prompt."
        $tip.Font = $smallFont
        $tip.ForeColor = [System.Drawing.Color]::Gray
        $tip.Location = New-Object System.Drawing.Point(20, 365)
        $tip.AutoSize = $true
        $Form.Controls.Add($tip)
        return
    }

    $headerVer = New-Object System.Windows.Forms.Label
    $headerVer.Text = "Version"
    $headerVer.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
    $headerVer.Location = New-Object System.Drawing.Point(15, 22)
    $headerVer.Size = New-Object System.Drawing.Size(130, 20)
    $listGroup.Controls.Add($headerVer)

    $headerStatus = New-Object System.Windows.Forms.Label
    $headerStatus.Text = "Status"
    $headerStatus.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
    $headerStatus.Location = New-Object System.Drawing.Point(160, 22)
    $headerStatus.Size = New-Object System.Drawing.Size(100, 20)
    $listGroup.Controls.Add($headerStatus)

    $headerAction = New-Object System.Windows.Forms.Label
    $headerAction.Text = "Action"
    $headerAction.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
    $headerAction.Location = New-Object System.Drawing.Point(280, 22)
    $headerAction.Size = New-Object System.Drawing.Size(100, 20)
    $listGroup.Controls.Add($headerAction)

    $line = New-Object System.Windows.Forms.Label
    $line.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $line.Location = New-Object System.Drawing.Point(15, 44)
    $line.Size = New-Object System.Drawing.Size(450, 2)
    $listGroup.Controls.Add($line)

    $count = $installed.Count
    for ($i = 0; $i -lt $count; $i++) {
        $ver = $installed[$i]
        $isCurrent = ($ver -eq $current)
        [int]$rowY = 55 + ($i * 30)

        $verLabel = New-Object System.Windows.Forms.Label
        $verLabel.Text = $ver
        $verLabel.Font = $monoNorm
        $verLabel.Location = New-Object System.Drawing.Point(15, $rowY)
        $verLabel.Size = New-Object System.Drawing.Size(130, 24)
        $listGroup.Controls.Add($verLabel)

        if ($isCurrent) {
            $curLabel = New-Object System.Windows.Forms.Label
            $curLabel.Text = "In Use"
            $curLabel.Font = $font
            $curLabel.ForeColor = $green
            $curLabel.Location = New-Object System.Drawing.Point(160, $rowY)
            $curLabel.Size = New-Object System.Drawing.Size(100, 24)
            $listGroup.Controls.Add($curLabel)

            $curHint = New-Object System.Windows.Forms.Label
            $curHint.Text = "Current"
            $curHint.Font = $smallFont
            $curHint.ForeColor = $green
            $curHint.Location = New-Object System.Drawing.Point(280, $rowY)
            $curHint.Size = New-Object System.Drawing.Size(120, 24)
            $listGroup.Controls.Add($curHint)
        } else {
            [int]$btnY = $rowY - 2
            $btn = New-Object System.Windows.Forms.Button
            $btn.Text = "Switch to this version"
            $btn.Font = $smallFont
            $btn.Location = New-Object System.Drawing.Point(280, $btnY)
            $btn.Size = New-Object System.Drawing.Size(150, 26)
            $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::System
            $btn.Tag = $ver
            $btn.Add_Click({
                param($sender, $e)
                $v = $sender.Tag
                $Global:StatusLabel.Text = "Switching to $v ..."
                $Global:MainForm.Refresh()
                try {
                    Start-Process -FilePath "nvm" -ArgumentList "use $v" -Verb RunAs -Wait -WindowStyle Hidden
                    $Global:StatusLabel.Text = "Switched to $v. Restart terminal to take effect."
                    $Global:StatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(230, 126, 34)
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("Switch failed: $($_.Exception.Message)", "Error")
                }
                Start-Sleep -Milliseconds 800
                $Global:MainForm.Controls.Clear()
                Build-UI $Global:MainForm
            })
            $listGroup.Controls.Add($btn)
        }
    }

    # Footer
    $footer = New-Object System.Windows.Forms.Panel
    $footer.Location = New-Object System.Drawing.Point(20, 365)
    $footer.Size = New-Object System.Drawing.Size(480, 40)
    $Form.Controls.Add($footer)

    $tip = New-Object System.Windows.Forms.Label
    $tip.Text = "Tip: Click [Yes] on UAC prompt."
    $tip.Font = $smallFont
    $tip.ForeColor = [System.Drawing.Color]::Gray
    $tip.Location = New-Object System.Drawing.Point(0, 0)
    $tip.AutoSize = $true
    $footer.Controls.Add($tip)

    $author = New-Object System.Windows.Forms.Label
    $author.Text = "Author: rrfhecong@163.com"
    $author.Font = $tinyFont
    $author.ForeColor = [System.Drawing.Color]::FromArgb(160, 160, 160)
    $author.Location = New-Object System.Drawing.Point(0, 20)
    $author.AutoSize = $true
    $footer.Controls.Add($author)
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "NVM Version Manager"
$form.Size = New-Object System.Drawing.Size(536, 450)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$Global:MainForm = $form

Build-UI $form
$form.ShowDialog() | Out-Null
