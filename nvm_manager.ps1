<#
NVM Version Manager - PowerShell GUI
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$NvmRoot = "D:\Program Files\Roaming\nvm"
$Global:StatusLabel = $null
$Global:MainForm = $null
$Global:ViewMode = "installed"

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

function Get-AvailableVersions {
    try {
        $settingsPath = Join-Path $NvmRoot "settings.txt"
        $mirror = "https://nodejs.org/dist/"
        if (Test-Path $settingsPath) {
            $content = Get-Content $settingsPath -Raw
            if ($content -match 'node_mirror\s+(https?://\S+)') {
                $mirror = $Matches[1].Trim()
            }
        }
        $indexUrl = $mirror.TrimEnd('/') + "/index.json"
        $data = Invoke-RestMethod -Uri $indexUrl -TimeoutSec 15
        $versions = $data | ForEach-Object {
            if ($_.version -match "^v(\d+\.\d+\.\d+)$") {
                $Matches[1]
            }
        }
        return ,($versions | Sort-Object { [Version]$_ } -Descending)
    } catch {
        return @()
    }
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
    $gray = [System.Drawing.Color]::FromArgb(150, 150, 150)
    $accent = [System.Drawing.Color]::FromArgb(0, 120, 215)
    $accentHover = [System.Drawing.Color]::FromArgb(0, 105, 190)
    $redLight = [System.Drawing.Color]::FromArgb(255, 235, 235)
    $redText = [System.Drawing.Color]::FromArgb(200, 60, 60)
    $greenBg = [System.Drawing.Color]::FromArgb(235, 250, 240)
    $whiteText = [System.Drawing.Color]::White
    $badgeFont = New-Object System.Drawing.Font("Microsoft YaHei UI", 9, [System.Drawing.FontStyle]::Bold)

    # Title row
    $titleRow = New-Object System.Windows.Forms.Panel
    $titleRow.Location = New-Object System.Drawing.Point(20, 12)
    $titleRow.Size = New-Object System.Drawing.Size(480, 40)
    $titleRow.Anchor = 'Top, Left, Right'
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
    $disclaimer.ForeColor = $gray
    $disclaimer.Location = New-Object System.Drawing.Point(300, 12)
    $disclaimer.AutoSize = $true
    $titleRow.Controls.Add($disclaimer)

    # Current environment
    $infoGroup = New-Object System.Windows.Forms.GroupBox
    $infoGroup.Text = "Current Environment"
    $infoGroup.Font = $groupFont
    $infoGroup.Location = New-Object System.Drawing.Point(20, 55)
    $infoGroup.Size = New-Object System.Drawing.Size(480, 90)
    $infoGroup.Anchor = 'Top, Left, Right'
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

    # Tab bar
    $tabBar = New-Object System.Windows.Forms.Panel
    $tabBar.Location = New-Object System.Drawing.Point(20, 150)
    $tabBar.Size = New-Object System.Drawing.Size(480, 30)
    $tabBar.Anchor = 'Top, Left, Right'
    $Form.Controls.Add($tabBar)

    $tabInstalled = New-Object System.Windows.Forms.Button
    $tabInstalled.Text = "Installed"
    $tabInstalled.Location = New-Object System.Drawing.Point(0, 0)
    $tabInstalled.Size = New-Object System.Drawing.Size(90, 28)
    $tabInstalled.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $tabInstalled.FlatAppearance.BorderSize = 0
    $tabInstalled.Tag = "installed"
    $tabInstalled.Cursor = [System.Windows.Forms.Cursors]::Hand
    $tabInstalled.Add_Click({
        $Global:ViewMode = "installed"
        $Global:MainForm.Controls.Clear()
        Build-UI $Global:MainForm
    })
    $tabBar.Controls.Add($tabInstalled)

    $tabOnline = New-Object System.Windows.Forms.Button
    $tabOnline.Text = "Available Online"
    $tabOnline.Location = New-Object System.Drawing.Point(94, 0)
    $tabOnline.Size = New-Object System.Drawing.Size(126, 28)
    $tabOnline.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $tabOnline.FlatAppearance.BorderSize = 0
    $tabOnline.Tag = "online"
    $tabOnline.Cursor = [System.Windows.Forms.Cursors]::Hand
    $tabOnline.Add_Click({
        $Global:StatusLabel.Text = "Loading online versions..."
        $Global:MainForm.Refresh()
        $Global:ViewMode = "online"
        $Global:MainForm.Controls.Clear()
        Build-UI $Global:MainForm
    })
    $tabBar.Controls.Add($tabOnline)

    # Style active/inactive tabs
    if ($Global:ViewMode -eq "installed") {
        $tabInstalled.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
        $tabInstalled.BackColor = $accent
        $tabInstalled.ForeColor = $whiteText
        $tabOnline.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)
        $tabOnline.BackColor = [System.Drawing.Color]::FromArgb(232, 232, 232)
        $tabOnline.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
    } else {
        $tabOnline.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
        $tabOnline.BackColor = $accent
        $tabOnline.ForeColor = $whiteText
        $tabInstalled.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10)
        $tabInstalled.BackColor = [System.Drawing.Color]::FromArgb(232, 232, 232)
        $tabInstalled.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
    }

    # List group
    $listGroup = New-Object System.Windows.Forms.GroupBox
    $listGroup.Text = ""
    $listGroup.Font = $groupFont
    $listGroup.Location = New-Object System.Drawing.Point(20, 182)
    $listGroup.Size = New-Object System.Drawing.Size(496, 243)
    $listGroup.Anchor = 'Top, Bottom, Left, Right'
    $Form.Controls.Add($listGroup)

    if ($Global:ViewMode -eq "installed") {
        if ($installed.Count -eq 0) {
            $emptyLabel = New-Object System.Windows.Forms.Label
            $emptyLabel.Text = "No Node.js versions detected"
            $emptyLabel.ForeColor = [System.Drawing.Color]::Gray
            $emptyLabel.Location = New-Object System.Drawing.Point(15, 85)
            $emptyLabel.AutoSize = $true
            $listGroup.Controls.Add($emptyLabel)
        } else {
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
                    # Badge-style "In Use" indicator
                    $curBadge = New-Object System.Windows.Forms.Label
                    $curBadge.Text = "  In Use  "
                    $curBadge.Font = $badgeFont
                    $curBadge.ForeColor = $green
                    $curBadge.BackColor = $greenBg
                    $curBadge.TextAlign = 'MiddleCenter'
                    $curBadge.AutoSize = $true
                    $curBadge.Location = New-Object System.Drawing.Point(155, $rowY)
                    $curBadge.Padding = New-Object System.Windows.Forms.Padding(4, 2, 4, 2)
                    $listGroup.Controls.Add($curBadge)
                } else {
                    [int]$btnY = $rowY - 2
                    $btn = New-Object System.Windows.Forms.Button
                    $btn.Text = "Switch"
                    $btn.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9, [System.Drawing.FontStyle]::Bold)
                    $btn.Location = New-Object System.Drawing.Point(280, $btnY)
                    $btn.Size = New-Object System.Drawing.Size(82, 28)
                    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                    $btn.BackColor = $accent
                    $btn.ForeColor = $whiteText
                    $btn.FlatAppearance.BorderSize = 0
                    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
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

                    $delBtn = New-Object System.Windows.Forms.Button
                    $delBtn.Text = "Delete"
                    $delBtn.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
                    $delBtn.Location = New-Object System.Drawing.Point(370, $btnY)
                    $delBtn.Size = New-Object System.Drawing.Size(60, 28)
                    $delBtn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                    $delBtn.BackColor = $redLight
                    $delBtn.ForeColor = $redText
                    $delBtn.FlatAppearance.BorderSize = 0
                    $delBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
                    $delBtn.Tag = $ver
                    $delBtn.Add_Click({
                        param($sender, $e)
                        $v = $sender.Tag
                        $confirm = [System.Windows.Forms.MessageBox]::Show(
                            "Uninstall Node.js $v ? This operation cannot be undone.",
                            "Confirm Delete",
                            [System.Windows.Forms.MessageBoxButtons]::YesNo,
                            [System.Windows.Forms.MessageBoxIcon]::Warning
                        )
                        if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
                            $Global:StatusLabel.Text = "Uninstalling $v ..."
                            $Global:MainForm.Refresh()
                            try {
                                Start-Process -FilePath "nvm" -ArgumentList "uninstall $v" -Verb RunAs -Wait -WindowStyle Hidden
                                $Global:StatusLabel.Text = "$v has been uninstalled."
                                $Global:StatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(230, 126, 34)
                            } catch {
                                [System.Windows.Forms.MessageBox]::Show("Uninstall failed: $($_.Exception.Message)", "Error")
                            }
                            Start-Sleep -Milliseconds 800
                            $Global:MainForm.Controls.Clear()
                            Build-UI $Global:MainForm
                        }
                    })
                    $listGroup.Controls.Add($delBtn)
                }
            }
        }
    } else {
        # Online view
        $onlineLabel = New-Object System.Windows.Forms.Label
        $onlineLabel.Text = "Loading..."
        $onlineLabel.Font = $font
        $onlineLabel.ForeColor = $gray
        $onlineLabel.Location = New-Object System.Drawing.Point(15, 25)
        $onlineLabel.AutoSize = $true
        $listGroup.Controls.Add($onlineLabel)

        # Load online versions async-like
        $Global:MainForm.Refresh()
        $available = Get-AvailableVersions

        if ($available.Count -eq 0) {
            $onlineLabel.Text = "No versions found or network unavailable."
        } else {
            $onlineLabel.Dispose()

            # Header panel (fixed at top, does not scroll)
            $headerPanel = New-Object System.Windows.Forms.Panel
            $headerPanel.Location = New-Object System.Drawing.Point(0, 5)
            $headerPanel.Size = New-Object System.Drawing.Size(494, 45)
            $headerPanel.Anchor = 'Top, Left, Right'
            $listGroup.Controls.Add($headerPanel)

            $headerVer = New-Object System.Windows.Forms.Label
            $headerVer.Text = "Version"
            $headerVer.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
            $headerVer.Location = New-Object System.Drawing.Point(15, 2)
            $headerVer.Size = New-Object System.Drawing.Size(160, 20)
            $headerPanel.Controls.Add($headerVer)

            $headerAction = New-Object System.Windows.Forms.Label
            $headerAction.Text = "Action"
            $headerAction.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
            $headerAction.Location = New-Object System.Drawing.Point(280, 2)
            $headerAction.Size = New-Object System.Drawing.Size(150, 20)
            $headerPanel.Controls.Add($headerAction)

            $line = New-Object System.Windows.Forms.Label
            $line.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
            $line.Location = New-Object System.Drawing.Point(15, 26)
            $line.Size = New-Object System.Drawing.Size(460, 1)
            $line.BackColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
            $headerPanel.Controls.Add($line)

            # Scrollable panel fills the rest
            $scrollPanel = New-Object System.Windows.Forms.Panel
            $scrollPanel.Location = New-Object System.Drawing.Point(0, 50)
            $scrollPanel.Size = New-Object System.Drawing.Size(494, 190)
            $scrollPanel.Anchor = 'Top, Bottom, Left, Right'
            $scrollPanel.AutoScroll = $true
            $listGroup.Controls.Add($scrollPanel)

            $count = $available.Count
            $totalH = $count * 30 + 5
            $scrollPanel.AutoScrollMinSize = New-Object System.Drawing.Size(0, $totalH)

            for ($i = 0; $i -lt $count; $i++) {
                $ver = $available[$i]
                [int]$rowY = $i * 30

                $verLabel = New-Object System.Windows.Forms.Label
                $verLabel.Text = "v$ver"
                $verLabel.Font = $monoNorm
                $verLabel.Location = New-Object System.Drawing.Point(15, $rowY)
                $verLabel.Size = New-Object System.Drawing.Size(130, 24)
                $scrollPanel.Controls.Add($verLabel)

                $isInstalled = $installed -contains "v$ver"
                if ($isInstalled) {
                    $mark = New-Object System.Windows.Forms.Label
                    $mark.Text = "  Installed  "
                    $mark.Font = $badgeFont
                    $mark.ForeColor = $green
                    $mark.BackColor = $greenBg
                    $mark.TextAlign = 'MiddleCenter'
                    $mark.AutoSize = $true
                    $mark.Location = New-Object System.Drawing.Point(150, $rowY)
                    $mark.Padding = New-Object System.Windows.Forms.Padding(4, 2, 4, 2)
                    $scrollPanel.Controls.Add($mark)
                } else {
                    [int]$btnY = $rowY - 1
                    $btn = New-Object System.Windows.Forms.Button
                    $btn.Text = "Install"
                    $btn.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9, [System.Drawing.FontStyle]::Bold)
                    $btn.Location = New-Object System.Drawing.Point(280, $btnY)
                    $btn.Size = New-Object System.Drawing.Size(82, 28)
                    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                    $btn.BackColor = $accent
                    $btn.ForeColor = $whiteText
                    $btn.FlatAppearance.BorderSize = 0
                    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
                    $btn.Tag = $ver
                    $btn.Add_Click({
                        param($sender, $e)
                        $v = $sender.Tag
                        $Global:StatusLabel.Text = "Installing Node.js v$v ..."
                        $Global:MainForm.Refresh()
                        try {
                            $proc = Start-Process -FilePath "nvm" -ArgumentList "install $v" -Verb RunAs -Wait -PassThru
                            if ($proc.ExitCode -ne 0) {
                                [System.Windows.Forms.MessageBox]::Show(
                                    "Install exited with code $($proc.ExitCode). Check network or mirror settings.",
                                    "Install Failed", [System.Windows.Forms.MessageBoxButtons]::OK,
                                    [System.Windows.Forms.MessageBoxIcon]::Error
                                )
                            } else {
                                $Global:StatusLabel.Text = "v$v installed successfully."
                                $Global:StatusLabel.ForeColor = [System.Drawing.Color]::FromArgb(39, 174, 96)
                            }
                        } catch {
                            [System.Windows.Forms.MessageBox]::Show("Install error: $($_.Exception.Message)", "Error")
                        }
                        Start-Sleep -Milliseconds 800
                        $Global:ViewMode = "installed"
                        $Global:MainForm.Controls.Clear()
                        Build-UI $Global:MainForm
                    })
                    $scrollPanel.Controls.Add($btn)
                }
            }
        }

        $Global:StatusLabel.Text = "$($available.Count) versions available online. Scroll to browse."
    }

    # Footer
    $footer = New-Object System.Windows.Forms.Panel
    $footer.Location = New-Object System.Drawing.Point(20, 430)
    $footer.Size = New-Object System.Drawing.Size(496, 40)
    $footer.Anchor = 'Bottom, Left, Right'
    $Form.Controls.Add($footer)

    $tip = New-Object System.Windows.Forms.Label
    $tip.Text = "Tip: Click [Yes] on UAC prompt. Open new terminal after switching."
    $tip.Font = $smallFont
    $tip.ForeColor = $gray
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
$form.Size = New-Object System.Drawing.Size(536, 485)
$form.MinimumSize = New-Object System.Drawing.Size(536, 485)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$form.MaximizeBox = $true
$form.MinimizeBox = $true
$Global:MainForm = $form

$form.Add_Resize({
    $this.Refresh()
})
# Enable double-buffering to reduce flicker
$form.GetType().GetMethod('SetStyle', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance).Invoke(
    $form, @([System.Windows.Forms.ControlStyles]::OptimizedDoubleBuffer -bor
             [System.Windows.Forms.ControlStyles]::AllPaintingInWmPaint, $true)
)

Build-UI $form
$form.ShowDialog() | Out-Null
