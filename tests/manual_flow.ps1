$baseUrl = "http://localhost:3000/api"
$user = "admin"
$pass = "password"

# 1. Login
Write-Host "--- LOGIN ---" -ForegroundColor Cyan
$loginBody = @{ username = $user; password = $pass } | ConvertTo-Json
try {
    $loginRes = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginRes.data.accessToken
    Write-Host "Login Exitoso" -ForegroundColor Green
} catch {
    Write-Host "Error Login: $_" -ForegroundColor Red
    exit
}

$headers = @{ Authorization = "Bearer $token" }

# 2. Obtener IDs (Asumir ID 1 para simplicidad o usar seed output si fuera dinamico)
# Simplemente usamos ID 1 que sabemos que el seed creo o upserted.
$idProv = 1
$idMina = 1
$idSup = 1
$idProd = 1

# 3. Crear Requerimiento
Write-Host "--- CREAR REQUERIMIENTO ---" -ForegroundColor Cyan
$reqBody = @{
    id_proveedor = $idProv
    id_mina = $idMina
    id_supervisor = $idSup
    observaciones = "Prueba Manual PS1 $(((Get-Date).ToString('HH:mm:ss')))"
    fecha_prometida = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
    detalles = @(
        @{
            id_producto = $idProd
            cantidad_solicitada = 100
            precio_proveedor = 50
            precio_mina = 100
            observacion = "Detalle prueba"
        }
    )
} | ConvertTo-Json -Depth 5

try {
    $reqRes = Invoke-RestMethod -Uri "$baseUrl/requirements" -Method Post -Body $reqBody -ContentType "application/json" -Headers $headers
    $reqId = $reqRes.data.id_requerimiento
    $detId = $reqRes.data.requerimiento_detalles[0].id_detalle
    Write-Host "Requerimiento Creado. ID: $reqId, Codigo: $($reqRes.data.codigo)" -ForegroundColor Green
} catch {
    Write-Host "Error Crear Requerimiento: $_" -ForegroundColor Red
    $stream = $_.Exception.Response.GetResponseStream()
    if ($stream) {
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host "Detalle: $($reader.ReadToEnd())" -ForegroundColor Red
    }
    exit
}

# 4. Registrar Viaje
Write-Host "--- REGISTRAR VIAJE ---" -ForegroundColor Cyan
if ($reqId) {
    $viajeBody = @{
        id_requerimiento = $reqId
        numero_viaje = 1
        placa_vehiculo = "ABC-123"
        conductor = "Juan Perez"
        observaciones = "Viaje de prueba"
        fecha_salida = (Get-Date).AddHours(-2).ToString("yyyy-MM-dd HH:mm:ss")
        detalles = @(
            @{
                id_detalle_requerimiento = $detId
                cantidad_recibida = 50
                estado_entrega = "OK"
                observacion = "Llego OK 50%"
            }
        )
    } | ConvertTo-Json -Depth 5

    try {
        $viajeRes = Invoke-RestMethod -Uri "$baseUrl/trips" -Method Post -Body $viajeBody -ContentType "application/json" -Headers $headers
        Write-Host "Viaje creado: ID $($viajeRes.data.id_viaje)" -ForegroundColor Green
    } catch {
        Write-Host "Error Viaje: $_" -ForegroundColor Red
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
            $reader = New-Object System.IO.StreamReader($stream)
            Write-Host "Detalle: $($reader.ReadToEnd())" -ForegroundColor Red
        }
    }
}

# 5. Ver Inventario
Write-Host "--- STOCK DISPONIBLE ---" -ForegroundColor Cyan
try {
    $inv = Invoke-RestMethod -Uri "$baseUrl/inventory" -Method Get -Headers $headers
    # Filtrar solo el prod 1
    $prodStock = $inv.data.data | Where-Object { $_.id_producto -eq $idProd }
    Write-Host "Stock Producto $($idProd): $($prodStock.stock_actual)" -ForegroundColor Green
} catch {
    Write-Host "Error Inventario: $_" -ForegroundColor Red
}

# ...

# 8. Ver Stock Final
try {
    $invAfter = Invoke-RestMethod -Uri "$baseUrl/inventory" -Method Get -Headers $headers
    $prodStockAfter = $invAfter.data.data | Where-Object { $_.id_producto -eq $idProd }
    Write-Host "Stock Final Producto $($idProd): $($prodStockAfter.stock_actual)" -ForegroundColor Green
} catch { }

Write-Host "--- FIN TEST MANUAL ---" -ForegroundColor Cyan
