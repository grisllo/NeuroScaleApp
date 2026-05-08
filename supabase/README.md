# Supabase — migraciones SQL

Las migraciones se aplican **manualmente** en Supabase Studio → SQL Editor → New Query, en orden numérico. No hay `supabase db push` automatizado en este proyecto.

## Orden de aplicación

| Archivo | Cambio | Fase |
|---|---|---|
| `migrations/0001_init.sql` | Tabla `evaluations`, enum `scale_type`, RLS por `auth.uid()`, trigger `updated_at`. | 1 |
| `migrations/0002_add_abcd2.sql` | Añade `'abcd2'` al enum `scale_type` (idempotente). | 2A |
| `migrations/0003_add_patients.sql` | Tabla `patients` con RLS + FK opcional `evaluations.patient_id`. | 3.2 |
| `migrations/0004_constrain_case_description.sql` | CHECK `length(case_description) ≤ 500` como defensa server-side. | 6.1 |
| `migrations/0005_add_scale_type_index.sql` | Índice compuesto `(user_id, scale_type, created_at desc)` para filtros de historial. | 6.2 |

## Convenciones

- **Naming**: `NNNN_descripcion_corta.sql` con padding a 4 dígitos.
- **RLS**: toda tabla con `user_id` debe tener RLS habilitado y políticas `auth.uid() = user_id` para SELECT / INSERT / UPDATE / DELETE.
- **Idempotencia**: usar `if not exists` / `add value if not exists` cuando aplique para que la migración pueda re-correrse sin error.
- **Sin PII**: ningún campo libre puede contener datos identificativos. Validación en cliente (regex) + CHECK de longitud en servidor.

## Aplicación

1. Abre Supabase Studio del proyecto correspondiente.
2. SQL Editor → New Query.
3. Pega el contenido del archivo a aplicar y ejecuta.
4. Verifica con la pestaña **Table Editor** que los cambios están presentes.
