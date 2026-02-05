# Madera ERP - Backend

Sistema backend para la gestión logística y de inventarios de madera (Eucalipto), soportando el flujo desde requerimientos hasta recepción en planta.

## Descripción General
Este proyecto implementa una API RESTful con Node.js, Express, TypeScript y MySQL (vía Prisma ORM). El objetivo es digitalizar el control de pedidos, viajes y stock de madera proveniente de minas.

## Stack Tecnológico
*   **Lenguaje**: TypeScript
*   **Framework**: Express.js
*   **ORM**: Prisma
*   **Base de Datos**: MySQL
*   **Validación**: Zod
*   **Testing**: Jest
*   **Documentación**: Swagger / OpenAPI

## Prerrequisitos
*   Node.js (v18+)
*   MySQL (v8+)
*   npm

## Instalación

1.  Clonar el repositorio:
    ```bash
    git clone <repo-url>
    cd backend
    ```

2.  Instalar dependencias:
    ```bash
    npm install
    ```

3.  Configurar variables de entorno:
    Copia el archivo `.env.example` a `.env` y configura tus credenciales.
    ```env
    DATABASE_URL="mysql://usuario:password@localhost:3306/nombre_db"
    JWT_SECRET="tu_secreto_jwt"
    JWT_REFRESH_SECRET="tu_secreto_refresh"
    ```

4.  Inicializar la Base de Datos:
    ```bash
    npx prisma migrate dev
    # O si usas db push
    npx prisma db push
    ```

    *Nota*: Asegúrate de ejecutar los scripts SQL de procedimientos almacenados y vistas (`database_optimizado.sql` si aplica) o seeders.

## Ejecución

### Desarrollo
```bash
npm run dev
```
El servidor iniciará en `http://localhost:3000`.

### Producción
```bash
npm run build
npm start
```

## Documentación API
La documentación interactiva (Swagger UI) está disponible en:
👉 **`http://localhost:3000/api-docs`**

## Testing

### Tests Automatizados
```bash
npm test
```
Ejecuta tests unitarios y de integración con Jest.

### Pruebas Manuales
Consulta el archivo **`API_MANUAL_TESTING.md`** para una guía paso a paso usando curl/Postman.

## Estructura del Proyecto
```
src/
├── config/         # Configuración (DB, Swagger)
├── modules/        # Módulos de negocio (Auth, Maestros, Requerimientos...)
├── middlewares/    # Auth, Error handling
├── utils/          # Utilidades (JWT, etc)
├── docs/           # Definiciones OpenAPI
└── app.ts          # Entry point
```
