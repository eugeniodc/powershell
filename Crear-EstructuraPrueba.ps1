<#
.SYNOPSIS
Crea una estructura de carpetas y archivos de prueba para testear scripts de permisos.

.DESCRIPTION
Este script genera una estructura de carpetas y archivos de prueba en la ruta especificada. 
Incluye carpetas de primer nivel, subcarpetas y archivos de texto vacíos.

.PARAMETER RutaBase
Ruta base donde se creará la estructura de prueba.

.PARAMETER NumCarpetas
Número de carpetas de primer nivel que se crearán. Por defecto, 10.

.PARAMETER NumSubcarpetas
Número de subcarpetas que se crearán dentro de cada carpeta de primer nivel. Por defecto, 5.

.PARAMETER NumArchivos
Número de archivos que se crearán dentro de cada carpeta y subcarpeta. Por defecto, 3.

.EXAMPLE
.\Crear-EstructuraPrueba.ps1 -RutaBase "C:\Pruebas" -NumCarpetas 5 -NumSubcarpetas 3 -NumArchivos 2
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$RutaBase,

    [int]$NumCarpetas = 10,
    [int]$NumSubcarpetas = 5,
    [int]$NumArchivos = 3
)

# Crear la ruta base si no existe
if (-not (Test-Path -Path $RutaBase)) {
    Write-Host "Creando ruta base: $RutaBase"
    New-Item -Path $RutaBase -ItemType Directory | Out-Null
}

# Crear carpetas de primer nivel
for ($i = 1; $i -le $NumCarpetas; $i++) {
    $carpeta = Join-Path -Path $RutaBase -ChildPath "Carpeta_$i"
    Write-Host "Creando carpeta: $carpeta"
    New-Item -Path $carpeta -ItemType Directory | Out-Null

    # Crear subcarpetas dentro de cada carpeta de primer nivel
    for ($j = 1; $j -le $NumSubcarpetas; $j++) {
        $subcarpeta = Join-Path -Path $carpeta -ChildPath "Subcarpeta_$j"
        Write-Host "Creando subcarpeta: $subcarpeta"
        New-Item -Path $subcarpeta -ItemType Directory | Out-Null

        # Crear archivos dentro de cada subcarpeta
        for ($k = 1; $k -le $NumArchivos; $k++) {
            $archivo = Join-Path -Path $subcarpeta -ChildPath "Archivo_$k.txt"
            Write-Host "Creando archivo: $archivo"
            New-Item -Path $archivo -ItemType File | Out-Null
        }
    }

    # Crear archivos dentro de cada carpeta de primer nivel
    for ($k = 1; $k -le $NumArchivos; $k++) {
        $archivo = Join-Path -Path $carpeta -ChildPath "Archivo_$k.txt"
        Write-Host "Creando archivo: $archivo"
        New-Item -Path $archivo -ItemType File | Out-Null
    }
}

Write-Host "Estructura de prueba creada en: $RutaBase"