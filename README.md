# 🌲 Madera ERP - Backend API

Sistema backend para la gestión de aprovisionamiento, logística e inventario de madera para minería.

## 📋 Pre-requisitos

- Node.js 18+ LTS
- MySQL 8.0+
- Git

## 🚀 Instalación

### 1. Instalar dependencias

```bash
npm install
```

### 2. Configurar variables de entorno

```bash
cp .env.example .env
```

Edita `.env` y configura:
- `DATABASE_URL`: Tu conexión a MySQL
- `JWT_SECRET`: Genera uno seguro para producción
- `JWT_REFRESH_SECRET`: Genera uno diferente para producción

### 3. Configurar Prisma

```bash
# Generar schema desde la base de datos existente
npm run prisma:pull

# Generar el cliente de Prisma
npm run prisma:generate
```

### 4. Iniciar servidor de desarrollo

```bash
npm run dev
```

El servidor estará corriendo en `http://localhost:3000`

## 📁 Estructura del Proyecto

```
backend/
├── src/
│   ├── config/          # Configuraciones (DB, JWT, etc.)
│   ├── middlewares/     # Express middlewares
│   ├── modules/         # Módulos del negocio
│   │   ├── auth/
│   │   ├── maestros/
│   │   ├── requerimientos/
│   │   ├── viajes/
│   │   └── inventario/
│   ├── utils/           # Utilidades (JWT, validators, etc.)
│   ├── types/           # TypeScript types
│   ├── app.ts           # Express app setup
│   └── server.ts        # Entry point
├── prisma/
│   └── schema.prisma
├── tests/
└── scrips/              # Scripts de BD
```

## 🛠️ Scripts Disponibles

```bash
npm run dev              # Inicia servidor en modo desarrollo
npm run build            # Compila TypeScript a JavaScript
npm start                # Inicia servidor en modo producción
npm run lint             # Ejecuta ESLint
npm run format           # Formatea código con Prettier
npm test                 # Ejecuta tests
npm run test:watch       # Ejecuta tests en modo watch
npm run test:coverage    # Ejecuta tests con reporte de cobertura
npm run prisma:generate  # Genera Prisma client
npm run prisma:pull      # Importa schema desde BD
npm run prisma:studio    # Abre Prisma Studio (GUI para BD)
```

## 🔌 Endpoints API

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/refresh` - Renovar access token
- `GET /api/auth/me` - Obtener usuario actual

### Maestros
- `GET /api/products` - Listar productos
- `GET /api/providers` - Listar proveedores
- `GET /api/mines` - Listar minas
- `GET /api/supervisors` - Listar supervisores

### Requerimientos
- `GET /api/requirements` - Listar requerimientos
- `POST /api/requirements` - Crear requerimiento
- `GET /api/requirements/:id` - Ver detalle

### Viajes
- `GET /api/trips` - Listar viajes
- `POST /api/trips` - Registrar viaje

### Inventario
- `GET /api/stock` - Consultar stock
- `GET /api/stock/kardex/:productId` - Ver kardex
- `POST /api/stock/adjust` - Ajustar inventario

## 🧪 Testing

```bash
# Ejecutar todos los tests
npm test

# Tests en modo watch
npm run test:watch

# Reporte de cobertura
npm run test:coverage
```

## 📚 Documentación Adicional

- **[Plan de Implementación](./plan.md)** - Plan técnico completo
- **[Guía de Implementación](../artifacts/implementacion_backend.md)** - Guía paso a paso
- **[Análisis de Mejoras](../artifacts/analisis_mejoras.md)** - Análisis y mejoras aplicadas

## 🔐 Seguridad

- Autenticación JWT con access y refresh tokens
- Contraseñas hasheadas con bcrypt (12 rounds)
- Helmet.js para headers de seguridad
- Rate limiting en endpoints críticos
- Validación de datos con Zod
- RBAC (Role-Based Access Control)

## 👥 Roles

- **ADMIN**: Acceso completo al sistema
- **LOGISTICA**: Gestión de requerimientos, viajes e inventario
- **SUPERVISOR**: Consulta de requerimientos propios
- **MINA**: Consulta de información de entregas

## 📝 Convenciones de Código

- TypeScript strict mode habilitado
- Prettier para formateo automático
- ESLint para linting
- Nombres de archivos en snake_case
- Nombres de clases en PascalCase
- Nombres de funciones y variables en camelCase

## 🐛 Debug

Para habilitar logs detallados:

```env
LOG_LEVEL=debug
NODE_ENV=development
```

## 📦 Base de Datos

La base de datos incluye:
- ✅ 16 índices optimizados para performance
- ✅ 4 vistas estratégicas para reportes
- ✅ 5 procedimientos almacenados
- ✅ Triggers automáticos para stock y entregas
- ✅ Soft deletes en tablas maestras
- ✅ Auditoría completa de cambios

## 🚀 Despliegue

### Compilar para producción

```bash
npm run build
```

### Iniciar en producción

```bash
NODE_ENV=production npm start
```

## 📄 Licencia

MIT

---

**Desarrollado con ❤️ para la industria maderera peruana**
