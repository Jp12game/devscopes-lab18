# Laboratorio 17 · Respuestas de la Parte B (AcmeCorp)

**Integrantes:** _______________________
**Fecha:** _______________________

Fuente de los datos: `finops/aws-cost-sample.csv` y la salida de `finops/analyze_costs.py` (`entregables/salida_analyze_costs.txt`). Costo total del mes: **$1,743.85**.

---

## Pregunta 1: Desperdicio puro vs. rightsizing

Los "candidatos a optimización" del script mezclan cuatro tipos de acción distintos. Los clasifiqué así:

| Recurso | Costo/mes | Clasificación | Acción propuesta |
|---|---|---|---|
| `vol-0f1e2d3c4b5a6001` y `vol-0f1e2d3c4b5a6002` (EBS huérfanos) | $18.40 + $22.10 | **Desperdicio puro** | Tomar snapshot opcional y eliminar |
| `eipalloc-0011223344` (IP elástica sin uso) | $3.60 | **Desperdicio puro** | Liberar la IP |
| `acme-backups-2019` (backups de proyecto descontinuado) | $41.50 | **Desperdicio puro, condicionado** | Confirmar que no hay retención legal y luego archivar o borrar |
| `logs-retention` (logs sin política de retención) | $12.40 | Desperdicio de configuración | Definir periodo de retención |
| `acme-app-logs-prod` (logs en S3 Standard sin ciclo de vida) | $64.20 | Optimización de clase de almacenamiento | Ciclo de vida hacia clases de menor costo; los datos sí se usan |
| `nat-0a1b2c3d4e5f6001` y `nat-0a1b2c3d4e5f6002` (NAT de staging) | $32.85 + $1.20 | Elasticidad / arquitectura | El NAT cobra por hora aunque no tenga tráfico. Eliminarlo fuera de horario o reemplazarlo por VPC endpoints de tipo gateway (S3 y DynamoDB, sin costo) |
| `db-prod-analytics-01` (RDS db.r5.2xlarge) | $891.00 | **Rightsizing** | Ver Pregunta 3 |
| `i-0a1b2c3d4e5f60001` (EC2 m4.2xlarge producción) | $412.50 | Rightsizing y modernización | Medir CPU y memoria; migrar a una generación actual |
| `i-0a1b2c3d4e5f60004` (EC2 m4.large reportes) | $98.20 | Rightsizing y elasticidad | Verificar si necesita estar encendido 24/7; programar o rediseñar |
| `orders-table` (DynamoDB con capacidad de bajo uso) | $56.70 | Rightsizing de capacidad | Comparar consumo con capacidad aprovisionada; evaluar auto scaling u on-demand |
| `i-0a1b2c3d4e5f60002` y `i-0a1b2c3d4e5f60003` (staging y QA) | $30.10 + $7.60 | Elasticidad | Apagar fuera de horario laboral |

**Nota sobre el script:** `analyze_costs.py` no detecta dos hallazgos relevantes: el NAT de staging (`nat-0a1b2c3d4e5f6001`, $32.85), porque su descripción no contiene ninguna palabra clave, y DynamoDB (`orders-table`, $56.70), porque "bajo uso" no está en la lista. Además, el 89.7% del total que reporta el script no es desperdicio: incluye recursos que requieren rightsizing o que siguen siendo necesarios.

---

## Pregunta 2: Ahorro anual por eliminar EBS huérfanos e IP sin uso

| Recurso | Costo/mes | Costo/año (× 12) |
|---|---|---|
| Volumen huérfano 1 (`vol-0f1e2d3c4b5a6001`) | $18.40 | $220.80 |
| Volumen huérfano 2 (`vol-0f1e2d3c4b5a6002`) | $22.10 | $265.20 |
| IP elástica sin uso (`eipalloc-0011223344`) | $3.60 | $43.20 |
| **Total** | **$44.10** | **$529.20** |

**Ahorro anual estimado: $529.20.**

Si además se eliminan los backups de 2019 (una vez confirmada la ausencia de retención legal), el ahorro sube a $85.60/mes, es decir, **$1,027.20 al año**.

---

## Pregunta 3: Rightsizing de RDS `db-prod-analytics-01` (db.r5.2xlarge)

**Propuesta:** reducir primero a `db.r5.xlarge` y, si las métricas lo confirman, a `db.r5.large`.

**Justificación:**

1. **Validar antes de cambiar.** "Poco tráfico real" es una afirmación que hay que comprobar. Revisar al menos dos semanas de métricas de CloudWatch: `CPUUtilization`, `FreeableMemory`, `DatabaseConnections`, `ReadLatency` y `WriteLatency`.
2. **Reducir un paso a la vez.** Bajar de 2xlarge a xlarge reduce el costo a la mitad, aproximadamente $445.50/mes. Bajar a large lo reduce a unos $222.75/mes. Dentro de una familia, el precio escala de forma aproximadamente lineal con el tamaño.
3. **Ahorro estimado:**
   - Hacia `db.r5.xlarge`: $445.50/mes → **$5,346/año**
   - Hacia `db.r5.large`: $668.25/mes → **$8,019/año**
   - Estas cifras son estimaciones. Deben confirmarse en la calculadora de precios de AWS según motor, región y tipo de despliegue.
4. **Riesgo.** La familia `r5` está optimizada en memoria. Si las consultas analíticas necesitan memoria, reducir el tamaño puede provocar uso de swap y consultas lentas. Por eso la decisión depende de `FreeableMemory`, no solo de la CPU.
5. **Alternativas a evaluar:** instancias Graviton (`r6g` o `r7g`), que suelen ofrecer mejor relación precio-rendimiento; Aurora Serverless v2; o detener la base fuera del horario de análisis si la carga es por lotes.
6. **Orden recomendado.** Hacer rightsizing antes de comprometer capacidad con Reserved Instances o Savings Plans. Comprometerse sobre una instancia que luego se va a reducir genera costos innecesarios.
