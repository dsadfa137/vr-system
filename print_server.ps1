$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://127.0.0.1:8787/')
$listener.Start()

Write-Host 'Kiosk print server started.'
Write-Host 'Test URL: http://127.0.0.1:8787/print?mode=VR&number=V-001&time=14:00~15:00&count=2'
Write-Host 'Press Ctrl + C to stop.'

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $response.Headers.Add('Access-Control-Allow-Origin', '*')
        $response.Headers.Add('Access-Control-Allow-Methods', 'GET, OPTIONS')
        $response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')

        if ($request.HttpMethod -eq 'OPTIONS') {
            $response.StatusCode = 200
            $response.Close()
            continue
        }

        if ($request.Url.AbsolutePath -eq '/print') {
            $number = $request.QueryString['number']
            $mode = $request.QueryString['mode']
            $time = $request.QueryString['time']
            $team = $request.QueryString['team']
            $count = $request.QueryString['count']
            $agree = $request.QueryString['agree']
            $name = $request.QueryString['name']

            if ([string]::IsNullOrWhiteSpace($name)) {
                $name = "-"
            }

            if ([string]::IsNullOrWhiteSpace($number)) { $number = '001' }
            if ([string]::IsNullOrWhiteSpace($mode)) { $mode = 'VR' }
            if ([string]::IsNullOrWhiteSpace($time)) { $time = '-' }
            if ([string]::IsNullOrWhiteSpace($count)) { $count = '-' }
            if ([string]::IsNullOrWhiteSpace($agree)) { $agree = '' }

            # VR은 팀 개념이 없으므로 team 값을 '-'로 보정
            # 이 처리를 하지 않으면 print_ticket.ps1 호출 시 -team 매개변수 누락 오류가 발생할 수 있음
            if ([string]::IsNullOrWhiteSpace($team)) { $team = "" }

            Write-Host 'PRINT REQUEST'
            Write-Host ('mode=' + $mode)
            Write-Host ('time=' + $time)
            Write-Host ('team=' + $team)
            Write-Host ('count=' + $count)
            Write-Host ('agree=' + $agree)
            Write-Host ('number=' + $number)

            $ticketScript = Join-Path $PSScriptRoot 'print_ticket.ps1'

            if (Test-Path $ticketScript) {
                $argList = @(
                    '-ExecutionPolicy', 'Bypass',
                    '-File', $ticketScript,
                    '-mode', $mode,
                    '-name', $name,
                    '-time', $time,
                    '-team', $team,
                    '-count', $count,
                    '-agree', $agree,
                    '-number', $number
                )

                & powershell.exe @argList
            }
            else {
                Write-Host 'print_ticket.ps1 not found.'
            }

            $message = 'PRINT_OK'
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)

            $response.StatusCode = 200
            $response.ContentType = 'text/plain; charset=utf-8'
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
        }
        else {
            $response.StatusCode = 404
            $message = 'NOT_FOUND'
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
        }
    }
    catch {
        Write-Host 'ERROR'
        Write-Host $_.Exception.Message
    }
}
