# 📘 Plan Técnico de Desarrollo MEJORADO: ERP Gestión Maderera

## 1. Visión del Proyecto

Sistema web integral para la gestión de aprovisionamiento, logística y control de inventario de madera (postes, vigas, etc.). El sistema controlará el ciclo de vida desde el pedido al proveedor, la recepción física (viajes), hasta el control de stock (kardex) y despacho a minas.

---

## 2. Stack Tecnológico (Arquitectura)

### Infraestructura
- **Arquitectura**: Cliente-Servidor (REST API)
- **Protocolo**: HTTPS (TLS 1.3)
- **CORS**: Configurado para dominios específicos

### Base de Datos
- **Motor**: MySQL 8.0+ (InnoDB)
- **Features**: Triggers, Constraints, Stored Procedures, Views
- **Backup**: Replicación Master-Slave (recomendado para producción)

### Backend (API)
- **Runtime**: Node.js 18+ LTS
- **Framework**: Express.js 4.18+
- **Lenguaje**: TypeScript 5.0+
- **ORM**: Prisma 5.0+
- **Validación**: Zod 3.0+
- **Seguridad**: 
  - JWT (Access Token + Refresh Token)
  - Bcrypt (password hashing con salt rounds: 12)
  - Helmet.js (security headers)
  - Express Rate Limit
  - CORS configurado
- **Testing**:
  - Jest (unit tests)
  - Supertest (integration tests)
  - Prisma test database
- **Logging**: Winston + Morgan
- **Documentación**: Swagger/OpenAPI 3.0

### Frontend (UI)
- **Framework**: Vue 3 (Composition API)
- **Build Tool**: Vite 4.0+
- **Lenguaje**: TypeScript
- **Estilos**: Tailwind CSS 3.0+
- **Estado**: Pinia
- **HTTP Client**: Axios
- **Gráficos**: Chart.js 4.0+
- **Validación**: VeeValidate + Zod
- **UI Components**: PrimeVue (opcional) o componentes custom

---

## 3. Módulos y Casos de Uso (User Stories Expandidos)

### MÓDULO A: Seguridad y Acceso

**Actores**: Todos

**Casos de Uso Expandidos**:

#### CU-A1: Iniciar Sesión
- **Input**: username, password
- **Proceso**: 
  1. Validar credenciales
  2. Verificar usuario activo
  3. Generar Access Token (15 min) + Refresh Token (7 días)
  4. Registrar login en auditoria
- **Output**: tokens, usuario, rol, permisos
- **Errores**: 401 (credenciales inválidas), 403 (usuario inactivo)

#### CU-A2: Refresh Token
- **Input**: refresh_token
- **Output**: nuevo access_token
- **Seguridad**: Rotación de refresh tokens

#### CU-A3: Cerrar Sesión
- **Input**: refresh_token
- **Proceso**: Invalidar token (blacklist en Redis recomendado)

#### CU-A4: Cambiar Contraseña
- **Validación**: 
  - Mínimo 8 caracteres
  - Al menos 1 mayúscula, 1 minúscula, 1 número
  - No puede ser igual a las últimas 3 contraseñas

#### CU-A5: Control de Acceso (RBAC)
```typescript
Roles y Permisos:
ADMIN:
  - Todos los permisos
  - Gestión de usuarios
  - Auditoría completa

LOGISTICA:
  - Crear/Editar requerimientos
  - Registrar viajes
  - Ver stock
  - Ajustar inventario

SUPERVISOR:
  - Ver requerimientos propios
  - Ver stock
  - Reportes básicos

MINA:
  - Ver requerimientos propios
  - Ver cumplimiento de entregas
```

---

### MÓDULO B: Gestión de Maestros (Catálogos)

**Actores**: Admin, Logística

**Casos de Uso**:

#### CU-B1: Gestión de Productos
- CRUD completo
- Asignar medidas y clasificaciones
- Precio base de venta
- **Validaciones**:
  - Nombre único por medida
  - Precio >= 0
  - No eliminar si tiene movimientos históricos

#### CU-B2: Gestión de Precios por Proveedor
- Asignar precio de compra específico por Proveedor+Producto
- Historial de cambios de precios
- **Endpoint inteligente**: Sugerir precio según última compra

#### CU-B3: Gestión de Entidades
- Proveedores: nombre, RUC, contacto, teléfono
- Minas: nombre, razón social, RUC, ubicación
- Supervisores: nombre, teléfono, email
- **Soft Delete**: No eliminación física

---

### MÓDULO C: Aprovisionamiento (Requerimientos)

**Actores**: Logística, Supervisor

#### CU-C1: Crear Requerimiento
**Flujo**:
1. Seleccionar Proveedor → El sistema sugiere precios históricos
2. Seleccionar Mina destino
3. Seleccionar Supervisor responsable
4. Agregar productos:
   - Cantidad solicitada
   - Precio proveedor (sugerido, editable)
   - Precio mina (debe ser >= precio proveedor)
5. Sistema genera código automático: `REQ-2025-XXXX`
6. Guardar (transacción atómica)

**Validaciones**:
- Precio Mina >= Precio Proveedor (backend + BD)
- Cantidad > 0
- Al menos 1 producto en el detalle
- Fecha prometida >= Fecha actual

**Output**: ID del requerimiento, código generado

#### CU-C2: Editar Requerimiento
- Solo si estado = PENDIENTE o PARCIAL
- No editable si estado = COMPLETADO o ANULADO

#### CU-C3: Anular Requerimiento
- Cambiar estado a ANULADO
- Registrar motivo en observaciones
- Solo si cantidad_entregada = 0

#### CU-C4: Ver Seguimiento
- Barra de progreso: `(cantidad_entregada / cantidad_solicitada) * 100%`
- Listado de viajes asociados
- Estado automático:
  - PENDIENTE: 0% entregado
  - PARCIAL: 1-99% entregado
  - COMPLETADO: 100% entregado

---

### MÓDULO D: Logística de Entrada (Viajes)

**Actores**: Logística, Almacenero

#### CU-D1: Registrar Viaje
**Input**:
```json
{
  "id_requerimiento": 1,
  "placa_vehiculo": "ABC-123",
  "conductor": "Juan Pérez",
  "fecha_ingreso": "2025-02-05T14:30:00",
  "detalles": [
    {
      "id_detalle_requerimiento": 5,
      "cantidad_recibida": 50,
      "estado_entrega": "OK"
    },
    {
      "id_detalle_requerimiento": 6,
      "cantidad_recibida": 10,
      "estado_entrega": "RECHAZADO"
    }
  ]
}
```

**Proceso**:
1. Validar que el requerimiento existe y no está ANULADO
2. Generar numero_viaje automático (correlativo por requerimiento)
3. Por cada detalle:
   - Si estado = OK, PARCIAL, MUESTRA → suma a stock_actual
   - Si estado = RECHAZADO, DAÑADO → registrar pero NO suma a stock
4. Actualizar cantidad_entregada en requerimiento_detalles
5. Insertar movimientos en kardex
6. Verificar si se completó el requerimiento

**Automatizaciones (Triggers)**:
- Actualizar `cantidad_entregada`
- Actualizar `stock_actual`
- Insertar en `movimientos_stock`
- Cambiar estado de requerimiento si corresponde

#### CU-D2: Ver Viajes de un Requerimiento
- Listar todos los viajes
- Mostrar total recibido por producto

---

### MÓDULO E: Inventario y Control (Kardex)

**Actores**: Admin, Auditoría, Logística

#### CU-E1: Visualizar Stock Actual
- Filtros: producto, clasificación, medida
- Ordenamiento: stock, nombre, fecha
- **Vista optimizada**: `v_stock_disponible`

#### CU-E2: Consultar Kardex
**Input**: id_producto, rango de fechas
**Output**: Movimientos históricos
```
Fecha | Tipo | Cant. | Entrada | Salida | Saldo | Referencia
```

#### CU-E3: Ajuste Manual de Inventario
**Casos**:
- Merma
- Error de conteo
- Devolución
- Robo/Pérdida

**Validaciones**:
- Requiere motivo obligatorio
- No permitir stock negativo
- Registrar usuario y timestamp

---

## 4. Diseño de la API (Endpoints Completos)

### Autenticación
```http
POST   /api/auth/login
POST   /api/auth/refresh
POST   /api/auth/logout
GET    /api/auth/me
PUT    /api/auth/change-password
```

### Usuarios (ADMIN only)
```http
GET    /api/users?page=1&limit=20&rol=ADMIN&activo=true
POST   /api/users
GET    /api/users/:id
PUT    /api/users/:id
DELETE /api/users/:id (soft delete)
```

### Maestros - Productos
```http
GET    /api/products?page=1&limit=50&search=POSTE&medida_id=3
POST   /api/products
GET    /api/products/:id
PUT    /api/products/:id
DELETE /api/products/:id
```

### Maestros - Precios
```http
GET    /api/prices?provider_id=1&product_id=5
POST   /api/prices (crear/actualizar precio)
GET    /api/prices/history/:catalog_id (histórico de cambios)
```

### Maestros - Proveedores
```http
GET    /api/providers?activo=true
POST   /api/providers
GET    /api/providers/:id
PUT    /api/providers/:id
DELETE /api/providers/:id (soft delete)
```

### Maestros - Minas
```http
GET    /api/mines
POST   /api/mines
GET    /api/mines/:id
PUT    /api/mines/:id
DELETE /api/mines/:id
```

### Maestros - Supervisores
```http
GET    /api/supervisors
POST   /api/supervisors
GET    /api/supervisors/:id
PUT    /api/supervisors/:id
DELETE /api/supervisors/:id
```

### Requerimientos
```http
GET    /api/requirements?page=1&estado=PENDIENTE&proveedor_id=2&fecha_desde=2025-01-01
POST   /api/requirements
GET    /api/requirements/:id
PUT    /api/requirements/:id
DELETE /api/requirements/:id (anular)
PATCH  /api/requirements/:id/status (cambiar estado)
GET    /api/requirements/:id/progress (% cumplimiento)
GET    /api/requirements/:id/export?format=pdf
```

### Viajes
```http
GET    /api/trips?requerimiento_id=1&fecha_desde=2025-01-01
POST   /api/trips
GET    /api/trips/:id
PUT    /api/trips/:id
DELETE /api/trips/:id
GET    /api/trips/by-requirement/:req_id
```

### Inventario
```http
GET    /api/stock?producto_id=5&bajo_stock=true
GET    /api/stock/kardex/:product_id?desde=2025-01-01&hasta=2025-02-05
POST   /api/stock/adjust
GET    /api/stock/movements?tipo=ENTRADA&limit=100
GET    /api/stock/export?format=excel
```

### Reportes y Dashboards
```http
GET    /api/reports/stock-summary
GET    /api/reports/requirements-by-status
GET    /api/reports/provider-performance?fecha_desde=2025-01-01
GET    /api/reports/sales-by-mine
GET    /api/dashboard/kpi (total stock, reqs pendientes, viajes del mes)
```

### Auditoría (ADMIN only)
```http
GET    /api/audit?tabla=requerimientos&usuario=jtorres&fecha_desde=2025-01-01
```

---

## 5. Reglas de Negocio Críticas

### RN-1: Integridad Financiera
- Precio Mina >= Precio Proveedor (validado en backend + trigger BD)
- Precios siempre >= 0

### RN-2: Calidad de Stock
- Solo estados OK, PARCIAL, MUESTRA suman al inventario
- RECHAZADO y DAÑADO se registran pero no afectan stock

### RN-3: Consistencia de Datos
- No eliminar entidades con movimientos históricos (Foreign Keys)
- Usar Soft Delete en maestros

### RN-4: Atomicidad
- Crear Requerimiento = Transacción (cabecera + detalles)
- Registrar Viaje = Transacción (viaje + detalles + movimientos)

### RN-5: Stock Negativo
- No permitir stock_actual < 0 (constraint + validación backend)

### RN-6: Auditoría
- Todos los cambios críticos se registran automáticamente
- Capturar: usuario, fecha, acción, tabla, id_registro

---

## 6. Seguridad y Validación

### Autenticación JWT
```typescript
Access Token:
- Expira en 15 minutos
- Contiene: id_usuario, username, rol, permisos

Refresh Token:
- Expira en 7 días
- Almacenar en httpOnly cookie
- Rotación automática al refrescar
```

### Rate Limiting
```typescript
/api/auth/login: 5 intentos / 15 minutos
/api/auth/refresh: 10 intentos / 15 minutos
Endpoints generales: 100 req / minuto
```

### Validación con Zod
```typescript
// Ejemplo: Validación de crear requerimiento
const createRequirementSchema = z.object({
  id_proveedor: z.number().int().positive(),
  id_mina: z.number().int().positive(),
  id_supervisor: z.number().int().positive(),
  fecha_prometida: z.string().datetime().optional(),
  detalles: z.array(z.object({
    id_producto: z.number().int().positive(),
    cantidad_solicitada: z.number().int().positive(),
    precio_proveedor: z.number().nonnegative(),
    precio_mina: z.number().nonnegative()
  })).min(1)
});
```

### Headers de Seguridad (Helmet)
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- Strict-Transport-Security: max-age=31536000

---

## 7. Testing (Estrategia Completa)

### Pruebas Unitarias (Jest)
**Objetivo**: Cobertura >= 80% en servicios y utilidades

```bash
tests/unit/
├── services/
│   ├── requirements.service.test.ts
│   ├── trips.service.test.ts
│   └── stock.service.test.ts
├── validators/
│   └── schemas.test.ts
└── utils/
    └── jwt.test.ts
```

**Comandos**:
```bash
npm run test:unit
npm run test:coverage
```

### Pruebas de Integración (Supertest)
**Objetivo**: Validar flujos completos de API + BD

```bash
tests/integration/
├── auth.test.ts
├── requirements.flow.test.ts
└── trips.flow.test.ts
```

**Setup**: Base de datos de prueba con Prisma

**Comandos**:
```bash
npm run test:integration
```

### Pruebas E2E (Playwright o Cypress)
**Objetivo**: Validar flujos de usuario completos

**Casos**:
1. Login → Crear Requerimiento → Ver Lista
2. Registrar Viaje → Verificar Stock Actualizado
3. Ajuste de Inventario → Ver Kardex

**Comandos**:
```bash
npm run test:e2e
```

---

## 8. Deployment y DevOps

### Ambientes

| Ambiente | Base de Datos | URL | Propósito |
|----------|--------------|-----|-----------|
| Development | Local MySQL | localhost:3000 | Desarrollo local |
| Staging | MySQL Cloud | staging.maderera.com | Testing pre-producción |
| Production | MySQL Cloud (Réplica) | app.maderera.com | Producción |

### Variables de Entorno
```env
# .env.example
NODE_ENV=production
PORT=3000
DATABASE_URL=mysql://user:pass@host:3306/db
JWT_SECRET=super-secret-key-change-me
JWT_REFRESH_SECRET=another-secret-key
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
CORS_ORIGIN=https://app.maderera.com
```

### Backups
- **Frecuencia**: Diaria (automática a las 2 AM)
- **Retención**: 30 días
- **Estrategia**: Dump completo + Logs binarios

### Logging Centralizado
```typescript
// Winston + Morgan configuración
Niveles: error, warn, info, debug
Formato: JSON
Destino: Archivos rotados + Consola (dev)
```

### CI/CD Pipeline (GitHub Actions - ejemplo)
```yaml
on: [push]
jobs:
  test:
    - npm install
    - npm run test
    - npm run build

  deploy-staging:
    if: branch == 'develop'
    - rsync a servidor staging
    - pm2 restart app

  deploy-production:
    if: branch == 'main'
    - rsync a servidor producción
    - pm2 restart app
```

---

## 9. Plan de Ejecución (Fases Mejoradas)

### FASE 0: Setup Inicial (Día 1)
- [x] Crear repositorio Git
- [x] Inicializar proyecto Node.js + TypeScript
- [x] Configurar ESLint + Prettier
- [x] Instalar dependencias core
- [x] Configurar estructura de carpetas
- [x] Setup MySQL y ejecutar script mejorado

### FASE 1: Infraestructura (Días 2-3)
- [ ] Configurar Prisma (schema + migraciones)
- [ ] Implementar conexión a BD
- [ ] Setup JWT middleware
- [ ] Configurar Helmet + CORS + Rate Limiting
- [ ] Implementar logging (Winston)
- [ ] Crear esquemas Zod base

### FASE 2: Autenticación y Usuarios (Días 4-5)
- [ ] CRUD de usuarios
- [ ] Login con JWT
- [ ] Refresh token
- [ ] Middleware de autenticación
- [ ] Middleware de autorización (RBAC)
- [ ] Tests unitarios de auth

### FASE 3: Maestros (Días 6-7)
- [ ] CRUD Productos
- [ ] CRUD Medidas y Clasificaciones
- [ ] CRUD Proveedores, Minas, Supervisores
- [ ] Gestión de Precios por Proveedor
- [ ] Endpoint de sugerencia de precios
- [ ] Tests de integración de maestros

### FASE 4: Requerimientos (Días 8-10)
- [ ] Crear requerimiento (transacción)
- [ ] SP para generar código automático
- [ ] Editar/Anular requerimiento
- [ ] Listar con filtros y paginación
- [ ] Calcular % de cumplimiento
- [ ] Tests de flujo completo

### FASE 5: Viajes (Días 11-13)
- [ ] Registrar viaje (transacción)
- [ ] Validación de estados de entrega
- [ ] Trigger de actualización de stock
- [ ] Listar viajes por requerimiento
- [ ] Tests de triggers y transacciones

### FASE 6: Inventario y Kardex (Días 14-15)
- [ ] Vista de stock disponible
- [ ] Consulta de kardex
- [ ] Ajuste manual de inventario
- [ ] Exportación a Excel
- [ ] Tests de movimientos

### FASE 7: Reportes y Dashboard (Días 16-17)
- [ ] Stock summary
- [ ] Requirements by status
- [ ] Provider performance
- [ ] KPI dashboard
- [ ] Exportación PDF

### FASE 8: Frontend Base (Días 18-22)
- [ ] Setup Vue 3 + Vite + TypeScript
- [ ] Configurar Tailwind CSS
- [ ] Implementar autenticación
- [ ] Layout principal con sidebar
- [ ] Rutas protegidas
- [ ] Manejo de errores global

### FASE 9: Frontend - Vistas (Días 23-28)
- [ ] Gestión de Productos
- [ ] Gestión de Proveedores/Minas/Supervisores
- [ ] Crear/Editar Requerimientos
- [ ] Registrar Viajes
- [ ] Ver Stock y Kardex
- [ ] Dashboard con gráficos

### FASE 10: Testing y QA (Días 29-30)
- [ ] Completar suite de tests
- [ ] Testing manual de flujos críticos
- [ ] Corrección de bugs
- [ ] Optimización de queries

### FASE 11: Documentación (Día 31)
- [ ] Documentar API con Swagger
- [ ] README completo
- [ ] Guía de deployment
- [ ] Manual de usuario básico

### FASE 12: Deployment (Día 32)
- [ ] Configurar servidor producción
- [ ] Configurar CI/CD
- [ ] Configurar backups automáticos
- [ ] Deploy inicial
- [ ] Monitoreo post-deployment

---

## 10. Métricas de Éxito

### Performance
- Tiempo de respuesta API < 200ms (promedio)
- Carga de listados < 1 segundo
- Soporte para 50+ usuarios concurrentes

### Calidad
- Cobertura de tests >= 80%
- 0 vulnerabilidades críticas (npm audit)
- Uptime >= 99.5%

### Usabilidad
- Tiempo de carga inicial < 3 segundos
- Compatible con navegadores modernos (Chrome, Firefox, Edge)
- Responsive (desktop + tablet)

---

## 11. Documentación Técnica

### Swagger/OpenAPI
- Documentación interactiva en `/api/docs`
- Ejemplos de requests/responses
- Autenticación con Bearer token

### README
- Instrucciones de instalación
- Configuración de entorno
- Comandos disponibles
- Estructura del proyecto

---

## 12. Mantenimiento y Evolución

### Monitoreo
- Logs de errores
- Métricas de performance
- Alertas automáticas (errores 500, alta latencia)

### Actualizaciones
- Dependencias: revisión mensual
- Seguridad: inmediata ante vulnerabilidades
- Features: ciclos de 2 semanas (sprints)

---

> [!IMPORTANT]
> Este plan mejorado incluye:
> - ✅ Especificaciones de seguridad completas
> - ✅ Todos los endpoints documentados
> - ✅ Estrategia de testing definida
> - ✅ Plan de deployment y DevOps
> - ✅ Métricas de éxito claras
> - ✅ Roadmap de 32 días detallado

---

**Próximo paso**: Revisar el script de base de datos mejorado con todas las optimizaciones (índices, vistas, SPs, constraints).
