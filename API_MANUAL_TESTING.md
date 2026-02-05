# Guía de Pruebas Manuales de API (Postman / cURL)

Esta guía detalla el flujo completo para probar el backend del **Madera ERP**. Sigue estos pasos secuencialmente para validar la funcionalidad.

**Base URL**: `http://localhost:3000/api`

## 1. Autenticación (Login)
Obtén el token JWT necesario para todas las peticiones siguientes.

*   **Método**: `POST`
*   **Endpoint**: `/auth/login`
*   **Body (JSON)**:
    ```json
    {
        "username": "admin",
        "password": "password"
    }
    ```
*   **Respuesta Esperada**: `200 OK` con un objeto que contiene `accessToken`.
    *   *Nota*: Copia el `accessToken` para usarlo en los Headers de las siguientes peticiones.

## 2. Crear Requerimiento
Registra un nuevo pedido de madera.

*   **Método**: `POST`
*   **Endpoint**: `/requirements`
*   **Headers**:
    *   `Authorization`: `Bearer <TU_ACCESS_TOKEN>`
*   **Body (JSON)**:
    ```json
    {
        "id_proveedor": 1,
        "id_mina": 1,
        "id_supervisor": 1,
        "observaciones": "Pedido urgente para prueba manual",
        "fecha_prometida": "2024-12-31",
        "detalles": [
            {
                "id_producto": 1,
                "cantidad_solicitada": 100,
                "precio_proveedor": 50,
                "precio_mina": 120,
                "observacion": "Eucalipto de primera"
            }
        ]
    }
    ```
*   **Respuesta Esperada**: `201 Created`
    *   Guarda el `id_requerimiento` y el `id_detalle` (dentro del array `requerimiento_detalles`) de la respuesta.

## 3. Validar Requerimiento (Consulta)
Verifica que el requerimiento se creó correctamente.

*   **Método**: `GET`
*   **Endpoint**: `/requirements/<ID_REQUERIMIENTO>` (ej: `/requirements/1`)
*   **Headers**:
    *   `Authorization`: `Bearer <TU_ACCESS_TOKEN>`
*   **Respuesta Esperada**: `200 OK`
    *   Verifica que `estado` sea `PENDIENTE` y los datos coincidan.

## 4. Registrar Viaje (Recepción de Mercancía)
Registra la llegada de un camión asociado al requerimiento. Esto actualizará el inventario automáticamente.

*   **Método**: `POST`
*   **Endpoint**: `/trips`
*   **Headers**:
    *   `Authorization`: `Bearer <TU_ACCESS_TOKEN>`
*   **Body (JSON)**:
    ```json
    {
        "id_requerimiento": 1, 
        "numero_viaje": 1,
        "placa_vehiculo": "ABC-123",
        "conductor": "Juan Perez",
        "observaciones": "Primer viaje del pedido",
        "detalles": [
            {
                "id_detalle_requerimiento": 1, 
                "cantidad_recibida": 50,
                "estado_entrega": "OK",
                "observacion": "Todo correcto"
            }
        ]
    }
    ```
    *   *Nota*: Asegúrate de que `id_requerimiento` e `id_detalle_requerimiento` sean los mismos que obtuviste en el paso 2.
*   **Respuesta Esperada**: `201 Created`

## 5. Consultar Progreso del Requerimiento
Ve qué porcentaje se ha completado.

*   **Método**: `GET`
*   **Endpoint**: `/requirements/<ID_REQUERIMIENTO>/progress`
*   **Headers**:
    *   `Authorization`: `Bearer <TU_ACCESS_TOKEN>`
*   **Respuesta Esperada**: `200 OK`
    *   Debería mostrar `porcentaje_total: 50` (si pediste 100 y recibiste 50).

## 6. Verificar Inventario (Stock)
Confirma que el stock del producto ha aumentado.

*   **Método**: `GET`
*   **Endpoint**: `/inventory`
*   **Headers**:
    *   `Authorization`: `Bearer <TU_ACCESS_TOKEN>`
*   **Respuesta Esperada**: `200 OK`
    *   Busca el producto ID 1 y verifica que `stock_actual` sea 50 (o la suma acumulada).

## 7. Consultar Kardex (Historial)
Ve el historial de movimientos de ese producto.

*   **Método**: `GET`
*   **Endpoint**: `/inventory/kardex?id_producto=1`
*   **Headers**:
    *   `Authorization`: `Bearer <TU_ACCESS_TOKEN>`
*   **Respuesta Esperada**: `200 OK`
    *   Deberías ver una entrada tipo `ENTRADA` asociada al viaje recién creado.

## 8. Ajuste Manual de Inventario (Opcional)
Si necesitas corregir el stock manualmente.

*   **Método**: `POST`
*   **Endpoint**: `/inventory/adjust`
*   **Headers**:
    *   `Authorization`: `Bearer <TU_ACCESS_TOKEN>`
*   **Body (JSON)**:
    ```json
    {
        "id_producto": 1,
        "cantidad": 5,
        "tipo_movimiento": "AJUSTE_MANUAL",
        "observaciones": "Ajuste por conteo físico"
    }
    ```
*   **Respuesta Esperada**: `200 OK`
    *   El stock debería haber cambiado en +5 (o según lógica de tipo).
