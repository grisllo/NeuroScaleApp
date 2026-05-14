# Android — firma de release

Este directorio contiene la configuración Gradle del módulo Android. El build de **release** se firma con un keystore que vive **fuera del repositorio** y se referencia desde un archivo `key.properties` gitignored.

---

## Tabla de contenidos

- [1. Setup inicial](#1-setup-inicial)
  - [1.1 Generar el keystore](#11-generar-el-keystore)
  - [1.2 Configurar `key.properties`](#12-configurar-keyproperties)
- [2. Build de release](#2-build-de-release)
- [3. Verificar la firma](#3-verificar-la-firma)
- [4. Pérdida del keystore](#4-pérdida-del-keystore)
- [5. Cambio de keystore](#5-cambio-de-keystore)
- [6. Sin keystore (CI o clone limpio)](#6-sin-keystore-ci-o-clone-limpio)

---

## 1. Setup inicial

Solo se realiza una vez por desarrollador. El keystore generado se reutiliza durante toda la vida del proyecto y nunca se sube al repositorio.

### 1.1 Generar el keystore

Coloca el archivo `.jks` fuera del repo. La convención recomendada es `~/.android-keystores/`:

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.android-keystores"

& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" `
    -genkey -v `
    -keystore "$HOME\.android-keystores\neuroscale-release.jks" `
    -keyalg RSA -keysize 2048 -validity 10000 `
    -alias neuroscale-release
```

`keytool` pedirá una contraseña del keystore (mínimo 6 caracteres), una contraseña del alias y los datos del certificado (CN, O, OU, L, ST, C). Guarda **ambas contraseñas** en un gestor seguro.

> **Aviso crítico**: el keystore es la única forma de firmar actualizaciones de la aplicación en Google Play. Si lo pierdes, **no podrás publicar actualizaciones nunca más** con la misma identidad de aplicación. Detalles en §4.

### 1.2 Configurar `key.properties`

Copia la plantilla y rellénala con los valores reales:

```powershell
Copy-Item android/key.example.properties android/key.properties
```

Contenido esperado de `android/key.properties` (ejemplo):

```properties
storePassword=<password-del-keystore>
keyPassword=<password-del-alias>
keyAlias=neuroscale-release
storeFile=C:/Users/<usuario>/.android-keystores/neuroscale-release.jks
```

El archivo está incluido en `.gitignore` y nunca debe versionarse.

---

## 2. Build de release

Con `key.properties` correctamente configurado:

```powershell
flutter build apk --release --dart-define-from-file=env/prod.json
# o, si vas a publicar en Play Store:
flutter build appbundle --release --dart-define-from-file=env/prod.json
```

Artefactos resultantes:

- APK: `build/app/outputs/flutter-apk/app-release.apk`.
- AAB: `build/app/outputs/bundle/release/app-release.aab`.

---

## 3. Verificar la firma

Tras un build de release, verifica que el binario está firmado con el keystore correcto:

```powershell
# Listar las versiones de build-tools instaladas
Get-ChildItem "$env:LOCALAPPDATA\Android\sdk\build-tools" -Directory | Select-Object -ExpandProperty Name

# Sustituir <version> por la más reciente (por ejemplo 35.0.0)
& "$env:LOCALAPPDATA\Android\sdk\build-tools\35.0.0\apksigner.bat" `
    verify --print-certs build/app/outputs/bundle/release/app-release.aab
```

Salida esperada (extracto):

```
Signer #1 certificate DN: CN=NeuroScale, OU=..., O=..., L=..., ST=..., C=...
Signer #1 certificate SHA-256 digest: <hash>
```

El alias del firmante debe ser **`neuroscale-release`** — si aparece `androiddebugkey` significa que el build cayó a firma de depuración y **no debe publicarse**.

---

## 4. Pérdida del keystore

El keystore de release es irreemplazable. Si se pierde:

- **Play Store**: imposible publicar actualizaciones con el mismo `applicationId`. La única solución es publicar la aplicación bajo un nuevo `applicationId`, perdiendo descargas, valoraciones e historial.
- **Distribución directa (sideload)**: cualquier actualización requerirá desinstalar la versión anterior, ya que Android rechaza la instalación de un APK firmado con keystore distinto al previo.
- **Play App Signing** (opcional al publicar la primera vez en Play Store): si está activado, Google guarda una copia de la clave de firma y puede recuperarse contactando con el soporte. Recomendado para proyectos de larga vida.

**Por tanto**: respaldar el `.jks` en al menos dos ubicaciones seguras (gestor de contraseñas + almacenamiento cifrado offline) es una práctica obligatoria, no opcional.

---

## 5. Cambio de keystore

Si por motivos legítimos hace falta cambiar de keystore (rotación de claves, transferencia de proyecto, compromiso de la clave actual):

- **Sin Play App Signing**: no es posible mantener la continuidad. Se requiere publicar la app con un nuevo `applicationId` y migrar usuarios manualmente.
- **Con Play App Signing**: Google permite subir una nueva clave de carga (upload key) manteniendo la clave de firma original. El procedimiento se documenta en [Play Console → Configuración → Integridad de la app](https://support.google.com/googleplay/android-developer/answer/9842756?hl=es).

Durante el período transitorio, los APKs firmados con la nueva clave serán rechazados por Android al actualizar versiones existentes hasta que la migración esté completa.

---

## 6. Sin keystore (CI o clone limpio)

Si `android/key.properties` no existe, el script de Gradle del proyecto cae a firma de depuración (`debug.keystore` autogenerado) con un warning visible en la salida del build:

```
WARNING: key.properties not found. Falling back to debug signing.
```

Esto permite que la CI ejecute `flutter build apk` sin secretos y que un clone limpio del repositorio sea funcional inmediatamente. Sin embargo, el artefacto resultante **no es apto para distribución pública** y debe descartarse tras los tests.

---

## Documentos relacionados

- [`../docs/RELEASE_GUIDE.md`](../docs/RELEASE_GUIDE.md) — procedimiento completo de release.
- [`../docs/SECURITY.md`](../docs/SECURITY.md) — modelo de seguridad y gestión de secretos.
