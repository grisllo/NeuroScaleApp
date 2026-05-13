# Release Guide — NeuroScale App

## Prerequisitos

- Flutter 3.41.9+: `flutter --version`
- `env/prod.json` configurado (ver plantilla `env/dev.example.json`)
- Android: keystore firmado en `android/neuroscale.jks`
- iOS: certificado de distribución en Keychain

## Variables de entorno

Crear `env/prod.json` (gitignored) con:

```json
{
  "SUPABASE_URL": "https://<project>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-key>",
  "SENTRY_DSN": "<sentry-dsn>",
  "FLAVOR": "prod"
}
```

> La URL debe ser la URL base del proyecto Supabase, **sin** `/rest/v1` al final.

---

## Build Web (GitHub Pages)

```powershell
flutter build web --dart-define-from-file=env/prod.json --base-href /NeuroScaleApp/
```

El artefacto queda en `build/web/`. CI despliega automáticamente en push a `main` vía `.github/workflows/deploy.yml`.

## Build APK Android (firmado)

```powershell
flutter build apk --release --dart-define-from-file=env/prod.json
```

APK en `build/app/outputs/flutter-apk/app-release.apk`.

Para firmar con keystore existente, configurar `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=neuroscale
storeFile=../neuroscale.jks
```

Y en `android/app/build.gradle`:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

## Build iOS (Archive)

```bash
flutter build ipa --dart-define-from-file=env/prod.json
```

Abrir `build/ios/archive/Runner.xcarchive` en Xcode → Distribute App.

## CI/CD

| Workflow | Trigger | Acción |
|---|---|---|
| `ci.yml` | Push / PR a `main` | `dart format`, `flutter analyze`, `flutter test` |
| `deploy.yml` | Push a `main` (CI verde) | Build web + deploy a GitHub Pages |

Los workflows leen secrets de GitHub Actions: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`.

---

## Checklist pre-release

- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — 204+ tests verdes
- [ ] `dart format --set-exit-if-changed lib test` — 0 cambios
- [ ] Versión actualizada en `pubspec.yaml` (`version: X.Y.Z+N`)
- [ ] Changelog actualizado en `docs/ROADMAP.md`
- [ ] Tag de release creado: `git tag v1.0.0 && git push origin v1.0.0`
- [ ] APK probado en dispositivo físico Android
- [ ] Web de producción verificada en `grisllo.github.io/NeuroScaleApp`
