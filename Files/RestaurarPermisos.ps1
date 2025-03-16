# RestaurarPermisos.ps1
# Este script restaura los permisos de las carpetas de primer nivel en una ruta específica,
# eliminando las reglas de denegación aplicadas por el script ModificacionPermisos.ps1.

param (
    [string]$Ruta  # Ruta de la carpeta donde se restaurarán los permisos
)

# Verificar si la ruta existe
if (-not (Test-Path -Path $Ruta)) {
    Write-Host "La ruta especificada no existe: $Ruta" -ForegroundColor Red
    exit
}

# Obtener las carpetas de primer nivel en la ruta especificada
$carpetas = Get-ChildItem -Path $Ruta -Directory

foreach ($carpeta in $carpetas) {
    $acl = Get-Acl -Path $carpeta.FullName

    # Obtener las reglas de acceso actuales
    $reglas = $acl.Access | Where-Object {
        $_.AccessControlType -eq "Deny" -and (
            $_.FileSystemRights -match "WriteData|CreateFiles|Delete|Modify"
        )
    }

    # Eliminar las reglas de denegación
    foreach ($regla in $reglas) {
        Write-Host "Eliminando regla de denegación para: $($regla.IdentityReference) en $($carpeta.FullName)"
        $acl.RemoveAccessRule($regla) | Out-Null
    }

    # Aplicar los cambios a la carpeta
    Set-Acl -Path $carpeta.FullName -AclObject $acl
}

Write-Host "Permisos restaurados correctamente en la ruta: $Ruta" -ForegroundColor Green