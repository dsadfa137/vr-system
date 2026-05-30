param(
    [string]$mode = "VR",
    [string]$name = "",
    [string]$time = "",
    [string]$team = "",
    [string]$count = "",
    [string]$agree = "",
    [string]$number = "001"
)
$portName = "COM5"
$baudRate = 9600

$port = New-Object System.IO.Ports.SerialPort
$port.PortName = $portName
$port.BaudRate = $baudRate
$port.Parity = [System.IO.Ports.Parity]::None
$port.DataBits = 8
$port.StopBits = [System.IO.Ports.StopBits]::One
$port.Handshake = [System.IO.Ports.Handshake]::None
$port.Encoding = [System.Text.Encoding]::GetEncoding(949)

try {
    $port.Open()

    # Initialize printer
    $port.Write([char]27 + "@")

    # Center align
    $port.Write([char]27 + "a" + [char]1)

    # Title
    $port.WriteLine("------------------------")
    $port.WriteLine("MUNGYEONG ECO WORLD")
    $port.WriteLine("TICKET")
    $port.WriteLine("------------------------")
    $port.WriteLine("")

    # Ticket content
    if ($mode -eq "SURVIVAL") {
    $serviceText = "SURVIVAL"
} else {
    $serviceText = "VR"
}

$port.WriteLine("Number : " + $number)
$port.WriteLine("Service: " + $serviceText)
$port.WriteLine("Time   : " + $time)

if ($mode -eq "SURVIVAL") {
    $port.WriteLine("Team   : " + $team)
    $port.WriteLine("Agree  : " + $agree)
}

$port.WriteLine("Name   : " + $name)
$port.WriteLine("Count  : " + $count)
$port.WriteLine("Issued : " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
    $port.WriteLine("")

    $port.WriteLine("Please wait for your call.")
    $port.WriteLine("")
    $port.WriteLine("")
    $port.WriteLine("")

    # Cut paper
    $port.Write([char]29 + "V" + [char]1)

    Start-Sleep -Milliseconds 500
}
catch {
    Write-Host "PRINT_ERROR"
    Write-Host $_.Exception.Message
}
finally {
    if ($port.IsOpen) {
        $port.Close()
    }
}
