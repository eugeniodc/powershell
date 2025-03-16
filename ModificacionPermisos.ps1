<#
.SYNOPSIS
Modifica los permisos de seguridad avanzada en las carpetas de primer nivel de una ruta específica, denegando permisos de escritura, creación, eliminación y modificación para uno o varios grupos de usuarios.

.DESCRIPTION
Este script recorre todas las carpetas de primer nivel dentro de la ruta especificada y aplica una regla de denegación para los grupos de usuarios indicados. Los permisos denegados incluyen:
- Write: Escritura.
- CreateFiles: Creación de archivos.
- CreateDirectories: Creación de carpetas.
- DeleteSubdirectoriesAndFiles: Eliminación de subcarpetas y archivos.
- Delete: Eliminación de archivos y carpetas.

El script respeta la herencia de permisos y registra toda la actividad en un archivo de log ubicado en el directorio temporal.

.PARAMETER Path
Especifica la ruta de la carpeta principal donde se aplicarán los cambios de permisos. Este parámetro es obligatorio.

.PARAMETER Groups
Define los grupos de usuarios a los que se aplicarán las reglas de denegación. Puede ser un solo grupo o una lista de grupos. Por defecto, se usa el grupo "Users".

.EXAMPLE
.\ModificacionPermisos.ps1 -Path "C:\Ruta\Principal" -Groups "Users"
Modifica los permisos en todas las carpetas de primer nivel dentro de "C:\Ruta\Principal", denegando permisos de escritura, creación y eliminación para el grupo "Users".

.EXAMPLE
.\ModificacionPermisos.ps1 -Path "D:\Data" -Groups @("Group1", "Group2")
Modifica los permisos en todas las carpetas de primer nivel dentro de "D:\Data", denegando permisos de escritura, creación y eliminación para los grupos "Group1" y "Group2".

.NOTES
- El script debe ejecutarse con permisos de administrador.
- Los cambios se aplican solo a las carpetas de primer nivel dentro de la ruta especificada.
- El archivo de log se guarda en el directorio temporal ($env:TEMP) con el nombre "ModificacionPermisos.log".
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Path, # Ruta de las carpetas

    [string[]]$Groups = @("Todos") # Lista de grupos de usuarios (predeterminado: "Users")
)

# Definir la ruta del archivo de log en el directorio temporal
$logFile = Join-Path -Path $env:TEMP -ChildPath "ModificacionPermisos.log"

# Iniciar el registro de actividad
Start-Transcript -Path $logFile -Append

Write-Host "Iniciando script de modificación de permisos..."
Write-Host "Ruta: $Path"
Write-Host "Grupos: $($Groups -join ', ')"

try {
    # Verificar si la ruta existe
    if (-not (Test-Path -Path $Path)) {
        throw "La ruta especificada no existe: $Path"
    }

    # Obtener todas las carpetas de primer nivel en la ruta principal
    $carpetasPrimerNivel = Get-ChildItem -Path $Path -Directory

    # Recorrer cada carpeta de primer nivel
    foreach ($carpeta in $carpetasPrimerNivel) {
        $rutaCarpeta = $carpeta.FullName

        # Obtener la ACL (Lista de Control de Acceso) de la carpeta
        $acl = Get-Acl -Path $rutaCarpeta

        # Recorrer cada grupo y aplicar la regla de denegación
        foreach ($group in $Groups) {
            # Definir la regla de denegación para el grupo especificado
            $reglaDenegacion = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $group, # Grupo de usuarios
            "Write, CreateFiles, CreateDirectories, DeleteSubdirectoriesAndFiles, Delete", # Permisos a denegar
            "ContainerInherit, ObjectInherit", # Herencia para subcarpetas y archivos
            "None", # No propagar (ya que la herencia está activada)
            "Deny" # Tipo de regla (denegar)
            )

            # Añadir la regla de denegación a la ACL
            $acl.AddAccessRule($reglaDenegacion)

            Write-Host "Permisos modificados para el grupo '$group' en la carpeta: $rutaCarpeta"
        }

        # Aplicar la ACL modificada a la carpeta
        Set-Acl -Path $rutaCarpeta -AclObject $acl
    }

    Write-Host "Proceso completado correctamente."
}
catch {
    # Capturar y registrar errores
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Error $_
}
finally {
    # Detener el registro de actividad
    Stop-Transcript
}