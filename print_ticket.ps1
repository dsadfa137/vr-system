param(
    [string]$mode = "VR",
    [string]$time = "",
    [string]$team = "",
    [string]$count = "",
    [string]$agree = "",
    [string]$number = "001"
)

$portName = "COM5"
$baudRate = 9600

# 체험구분 한글 변환
if ($mode -eq "SURVIVAL") {
    $serviceText = "레이저 서바이벌"
} else {
    $serviceText = "VR체험"
}

# 동시체험 동의 여부 한글 변환
if ($agree -eq "Y") {
    $agreeText = "동의"
} elseif ($agree -eq "N") {
    $agreeText = "비동의"
} else {
    $agreeText = "-"
}

# 값이 비어 있을 때 기본값 처리
if ([string]::IsNullOrWhiteSpace($number)) {
    $number = "001"
}

if ([string]::IsNullOrWhiteSpace($time)) {
    $time = "-"
}

if ([string]::IsNullOrWhiteSpace($count)) {
    $count = "-"
}

if ([string]::IsNullOrWhiteSpace($team)) {
    $team = "-"
}

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

    # 프린터 초기화
    $port.Write([char]27 + "@")

    # 가운데 정렬
    $port.Write([char]27 + "a" + [char]1)

    $port.WriteLine("문경에코월드")
    $port.WriteLine("번호표")
    $port.WriteLine("------------------------")
    $port.WriteLine("")

    $port.WriteLine("예약번호")
    $port.WriteLine($number)
    $port.WriteLine("")

    $port.WriteLine("체험구분 : " + $serviceText)
    $port.WriteLine("예약시간 : " + $time)
    $port.WriteLine("인원수   : " + $count + "명")

    if ($mode -eq "SURVIVAL") {
        $port.WriteLine("배정팀   : " + $team + "팀")
        $port.WriteLine("동시체험 : " + $agreeText)
    }

    $port.WriteLine("------------------------")
    $port.WriteLine("발권시간")
    $port.WriteLine((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
    $port.WriteLine("")
    $port.WriteLine("호출 시 입장해 주세요.")
    $port.WriteLine("")
    $port.WriteLine("")
    $port.WriteLine("")

    # 자동 컷팅
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
