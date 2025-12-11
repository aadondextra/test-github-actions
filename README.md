# Purchase Order - Proyecto Maestro-Detalle con Workflow de Aprobaciones

Este proyecto implementa un sistema completo de órdenes de compra en Business Central con relación maestro-detalle, configuración centralizada y flujo de aprobaciones.

## 📋 Estructura del Proyecto

### Tablas

**Table 50120: Purchase Order Header (Maestro)**
- **Primary Key**: `No.` (Code[20]) - Auto-generado con serie numérica
- Campos principales:
  - `Vendor No.`: Proveedor
  - `Vendor Name`: Nombre del proveedor
  - `Order Date`: Fecha del pedido (auto-inicializada a WorkDate)
  - `Expected Receipt Date`: Fecha esperada de recepción
  - `Status`: Estado (Open, Released, Completed)
  - `Total Amount`: Suma total calculada automáticamente desde las líneas
- Campos de aprobación:
  - `Approval Status`: Estado de aprobación (Not Required, Pending Approval, Approved, Rejected)
  - `Approver User ID`: Usuario aprobador asignado
  - `Requested By User ID`: Usuario que solicitó la aprobación
  - `Approval Date`: Fecha de aprobación
  - `Requires Approval`: Flag automático basado en el monto total

**Table 50121: Purchase Order Line (Detalle)**
- **Primary Key**: `Order No.` (FK a Purchase Order Header) + `Line No.` (Integer auto-incrementado)
- Campos principales:
  - `Type`: Tipo (Item, Resource, Service)
  - `No.`: Número del artículo/recurso
  - `Description`: Descripción
  - `Quantity`: Cantidad
  - `Unit of Measure`: Unidad de medida
  - `Unit Price`: Precio unitario
  - `Amount`: Importe total (calculado automáticamente)

**Table 50122: Purchase Order Setup (Configuración)**
- **Pattern**: Singleton (un solo registro)
- Campos:
  - `Purchase Order Nos.`: Serie numérica para órdenes
  - `Require Approval`: Activar/desactivar workflow de aprobaciones
  - `Approval Amount Limit`: Umbral de monto que requiere aprobación
  - `Default Approver User ID`: Aprobador por defecto
  - `Default Payment Terms`: Términos de pago por defecto
  - `Auto-Post on Release`: Auto-posteo al liberar

**Table 50123: Purchase Order Approval Entry (Historial)**
- Registro de todas las acciones de aprobación
- Campos:
  - `Entry No.`: ID único (AutoIncrement)
  - `Purchase Order No.`: Orden relacionada
  - `Sequence No.`: Número de secuencia
  - `Approver User ID`: Usuario aprobador
  - `Approval Status`: Estado (Pending, Approved, Rejected)
  - `Date-Time Requested`: Cuándo se solicitó
  - `Date-Time Responded`: Cuándo se respondió
  - `Requested By User ID`: Quién solicitó
  - `Amount`: Monto de la orden
  - `Comment`: Comentarios

### Páginas

**Page 50122: Purchase Order Card**
- Tipo: Card
- Página principal para gestionar una orden de compra individual
- Incluye subpágina con las líneas de detalle
- Grupo de campos de aprobación con indicador visual
- Acciones: Release, Reopen, Print, Print Receipt (Thermal)
- Acciones de aprobación:
  - Request Approval (visible cuando requiere aprobación)
  - Approve (habilitado para el aprobador)
  - Reject (habilitado para el aprobador)
  - Cancel Approval Request
- FactBox: Historial de aprobaciones

**Page 50123: Purchase Orders List**
- Tipo: List
- Lista de todas las órdenes de compra
- UsageCategory: Lists (visible en el menú)
- Acción: Crear nueva orden

**Page 50124: Purchase Order Subpage**
- Tipo: ListPart
- Gestión de líneas de detalle
- Integrada en el Purchase Order Card mediante SubPageLink
- Actualización automática del Total Amount al editar Quantity/Unit Price

**Page 50128: Purchase Order Setup**
- Tipo: Card
- Configuración centralizada del sistema
- UsageCategory: Administration
- Auto-inicialización en OnOpenPage

**Page 50129: PO Approval Entries**
- Tipo: List
- Visualización completa del historial de aprobaciones
- UsageCategory: Lists

**Page 50130: PO Approval Entries Part**
- Tipo: ListPart
- FactBox integrado en Purchase Order Card
- Muestra historial de aprobaciones por orden

### Codeunits

**Codeunit 50130: Purchase Order Tests**
- Subtype: Test
- 11 pruebas unitarias cubren:
  - Auto-generación de números
  - Inicialización de fechas y estados
  - Relaciones maestro-detalle
  - Cálculos automáticos
  - Cascade deletes

**Codeunit 50135: Purchase Order Approval Mgt**
- Lógica centralizada de aprobaciones
- Procedures:
  - `RequestApproval()`: Crea entry con status Pending
  - `ApproveRequest()`: Actualiza entry existente a Approved
  - `RejectRequest()`: Actualiza entry existente a Rejected
  - `CancelRequest()`: Cancela solicitud de aprobación

**Codeunit 50136: PO Installation**
- Subtype: Install
- Crea automáticamente la serie numérica PO-ORDER al instalar

### Reportes

**Report 50125: Purchase Order Report**
- Layout: RDLC
- Reporte estándar de orden de compra

**Report 50126: Purchase Order Grouped Report**
- Layout: RDLC
- Reporte agrupado por vendor

**Report 50127: Purchase Order Receipt Report**
- Layout: RDLC (3 pulgadas - formato térmico)
- Incluye:
  - Logo y datos de la compañía
  - Código de barras (Code128) vía API externa
  - Código QR vía API externa
  - Desglose de ITBIS (16%)
  - Formato optimizado para impresoras térmicas
- EnableExternalImages = true

### Traducciones

**XLIFF 1.2**
- `es-MX.xlf`: Traducción al español (México)
- Todos los captions traducidos

## 🔑 Características Clave

### ✅ Primary Keys Auto-generados
- **Tabla Maestro**: Usa serie numérica configurable en Setup
- **Tabla Detalle**: `Line No.` se auto-incrementa en 10,000

### ✅ Workflow de Aprobaciones
- Configuración flexible por monto
- Aprobador por defecto o por orden
- Historial completo de acciones
- Un entry por orden (actualizado según avanza el proceso)
- Validación de permisos de aprobador
- Estados visuales en la UI

### ✅ Relaciones Correctas
- Foreign Keys con TableRelation
- SubPageLink garantiza integridad
- Cascade delete automático
- UpdatePropagation = Both para sincronización

### ✅ Cálculos Automáticos en Tiempo Real
- `Amount` en líneas: `Quantity * Unit Price`
- `Total Amount` en header: FlowField (SUM de líneas)
- Actualización automática al modificar Quantity/Unit Price
- Flag `Requires Approval` se actualiza automáticamente según el total

### ✅ Configuración Centralizada
- Pattern Singleton para Setup
- Método `GetRecordOnce()` auto-inicializa si no existe
- Serie numérica configurable
- Umbral de aprobación configurable

## 🚀 Cómo Usar

### Configuración Inicial
1. Busca "Purchase Order Setup" en BC
2. Configura:
   - Purchase Order Nos.: PO-ORDER (o tu serie personalizada)
   - Require Approval: Sí
   - Approval Amount Limit: 10000 (ejemplo)
   - Default Approver User ID: Selecciona un usuario

### Crear Orden de Compra
1. Busca "Purchase Orders" en el menú
2. Clic en "New" - el número se genera automáticamente
3. Selecciona Vendor
4. Agrega líneas de detalle
5. El Total Amount se actualiza automáticamente

### Workflow de Aprobación
1. Si el total > límite configurado:
   - "Requires Approval" = Sí (resaltado amarillo)
   - Clic en "Request Approval"
   - Status cambia a "Pending Approval"
2. Como aprobador:
   - Abre la orden
   - Clic en "Approve" o "Reject"
   - El historial aparece en el FactBox
3. Después de aprobación:
   - Usa "Release" para liberar la orden

## 📦 Rango de IDs

- Tables: 50120-50123
- Pages: 50122-50130
- Codeunits: 50130, 50135-50136
- Reports: 50125-50127
- Rango disponible en app.json: 50100-50149

## ⚙️ Requisitos

- Business Central 26.0 o superior
- Runtime 14.0
- User Setup configurado con usuarios válidos
- Serie numérica PO-ORDER (creada automáticamente en instalación)
