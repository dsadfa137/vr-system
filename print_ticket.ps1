param(

    [string]$number = "001",

    [string]$service = "VR체험"

)



$port = New-Object System.IO.Ports.SerialPort COM5,9600,None,8,one

$port.Encoding = [System.Text.Encoding]::GetEncoding(949)

$port.Open()



$port.Write([char]27 + "@")

$port.Write([char]27 + "a" + [char]1)



$port.WriteLine("문경에코월드")

$port.WriteLine("번호표")

$port.WriteLine("")

$port.WriteLine($number)

$port.WriteLine("")

$port.WriteLine($service)

$port.WriteLine((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))

$port.WriteLine("")

$port.WriteLine("")

$port.WriteLine("")



$port.Write([char]29 + "V" + [char]1)

$port.Close() 