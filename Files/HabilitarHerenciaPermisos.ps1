<#
.SYNOPSIS
Habilita la herencia de permisos y reemplaza todas las entradas de permisos explícitas por entradas heredables en las carpetas del nivel indicado.

.DESCRIPTION
Este script habilita la herencia de permisos en las carpetas de una ruta específica y reemplaza todas las entradas de permisos explícitas por entradas heredables.

.PARAMETER Ruta
La ruta de la carpeta donde se habilitará la herencia de permisos.

.PARAMETER Recursivo
Aplica los cambios en todas las subcarpetas.

.EXAMPLE
.\HabilitarHerenciaPermisos.ps1 -Ruta "C:\Prueba" -Recursivo
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Ruta,

    [switch]$Recursivo
)

# Validar si la ruta existe
if (-not (Test-Path -Path $Ruta)) {
    Write-Host "La ruta especificada no existe: $Ruta" -ForegroundColor Red
    exit
}

# Obtener las carpetas del nivel indicado
if ($Recursivo) {
    $carpetas = Get-ChildItem -Path $Ruta -Directory -Recurse
} else {
    $carpetas = Get-ChildItem -Path $Ruta -Directory
}

# Procesar cada carpeta
foreach ($carpeta in $carpetas) {
    try {
        # Obtener la ACL actual de la carpeta
        $acl = Get-Acl -Path $carpeta.FullName

        # Habilitar la herencia de permisos
        $acl.SetAccessRuleProtection($false, $true)  # $false: habilitar herencia, $true: copiar reglas existentes

        # Aplicar los cambios a la carpeta
        Set-Acl -Path $carpeta.FullName -AclObject $acl

        Write-Host "Herencia habilitada en: $($carpeta.FullName)" -ForegroundColor Green
    } catch {
        Write-Host "Error al habilitar la herencia en '$($carpeta.FullName)': $_" -ForegroundColor Red
    }
}

Write-Host "Proceso completado." -ForegroundColor Green