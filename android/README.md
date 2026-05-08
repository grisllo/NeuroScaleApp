# Android — firma de release

Este directorio contiene la configuración Gradle del módulo Android. El build de **release** se firma con un keystore que vive **fuera del repositorio** y se referencia desde un archivo `key.properties` (gitignored).

## Setup inicial (una sola vez por desarrollador)

### 1. Generar keystore

Coloca el `.jks` fuera del repo (recomendado: `~/.android-keystores/`). En PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\.android-keystores"

& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" `
    -genkey -v `
    -keystore "$HOME\.android-keystores\neuroscale-release.jks" `
    -keyalg RSA -keysize 2048 -validity 10000 `
    -alias neuroscale-release
```

`keytool` pedirá password del keystore (≥6 caracteres) y datos del certificado. Guarda los passwords en un gestor — si los pierdes, no podrás publicar actualizaciones nunca más en Play Store con esa firma.

### 2. Crear `android/key.properties`

Copia `android/key.example.properties` a `android/key.properties` y rellena con tus passwords reales. El archivo está gitignored.

### 3. Verificar firma

Tras `flutter build appbundle --release`:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\build-tools\<version>\apksigner.bat" verify --print-certs build/app/outputs/bundle/release/app-release.aab
```

El alias del certificado debe ser `neuroscale-release`, **no** `androiddebugkey`.

## Sin keystore (CI o clone limpio)

Si `key.properties` no existe, el build release cae a firma debug con un warning visible. Esto permite que CI corra sin secretos, pero el artefacto **no debe publicarse**.
