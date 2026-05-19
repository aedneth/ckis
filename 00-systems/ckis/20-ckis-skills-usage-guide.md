---
type: system
created: 2026-05-17
modified: 2026-05-19
tags: [ckis, skills, sop, workflow, guide]
status: active
related: ["[[19-agent-habits-guide]]", "[[16-skill-cards-for-second-brain-workflows]]", "[[00-ckis-master-context]]", "[[17-crons-architecture]]"]
---

# 20 — CKIS Skills Usage Guide

> Guía operativa de todas las skills del Second Brain. Cuándo disparar cada una, qué esperar, cómo encadenarlas, y cómo resolver problemas comunes.
>
> **Complemento de [[19-agent-habits-guide]]** — ese documento cubre los hábitos de sesiones de desarrollo con agentes. Este cubre las sesiones de knowledge management con el CKIS.

━━━

## 0. Cómo funciona el sistema de skills

Las skills son archivos de instrucciones en `.claude/ckis-skills/<nombre>/skill.md`. Claude los lee y ejecuta cuando detectas la frase trigger en tu prompt.

**Mecánica:**
1. Abres una sesión en el vault: `cd ~/Documents/Second\ Brain && claude`
2. Escribes el trigger exacto en el chat
3. Claude lee el skill file correspondiente y ejecuta el workflow completo
4. No necesitas explicar qué hacer — el skill ya lo sabe

**Regla de oro:** Los triggers son frases cortas. No las hagas más largas. `daily brief` funciona. `por favor genera el brief del día de hoy` también funciona pero es ineficiente.

━━━

## 1. Mapa de skills por momento del día

```
MAÑANA                    DURANTE EL DÍA              FIN DE DÍA / SEMANA
──────────────────────    ────────────────────────    ────────────────────────
daily brief               braindump                   weekly review
                          process URL [url]           ckis weekly review
                          process YouTube [url]
                          process social
                          triage inbox
                          process inbox
                          synthesize [topic]
                          log decision [título]
                          project context [nombre]
```

```
INICIO DE PROYECTO        MANTENIMIENTO               MES
──────────────────────    ────────────────────────    ────────────────────────
onboard client            sync overviews              knowledge consolidation
vault maintenance         vault maintenance
  add-project <slug>        health-check
                          export context
                          cross-model handoff
```

━━━

## 2. Skills de captura

### `braindump`

**Cuándo:** Tienes un pensamiento, idea, tarea o insight que no puedes perder. No necesitas organizarlo — solo capturarlo.

**Trigger:**
```
braindump
```

**Lo que hace:**
- Te pide el dump o toma lo que dices directamente
- Clasifica el tipo (idea, tarea, insight, recurso, persona)
- Crea un archivo en `00-inbox/quick-capture/` con frontmatter correcto
- No lo procesa ni lo mueve — solo captura

**Cuándo NO usar:** Si ya sabes exactamente a dónde va la nota (por ejemplo, una decisión de proyecto → usa `log decision`).

**Ejemplo:**
```
braindump — los clientes siempre preguntan por SEO, podría ser un servicio productizado de $200
```

---

### `process URL [url]`

**Cuándo:** Encontraste un artículo, post o página web que quieres retener. URL en mano.

**Trigger:**
```
process URL https://example.com/articulo
```

**Lo que hace:**
- Extrae el contenido de la URL
- Resume las ideas principales
- Crea una nota en `04-resources/articles/` con frontmatter y wikilinks
- No modifica nada más

**Variantes del trigger:** `fetch [url]`, `scrape [url]`, `read [url]`

---

### `process YouTube [url]`

**Cuándo:** Viste un video que vale la pena retener — tutorial, conferencia, entrevista.

**Trigger:**
```
process YouTube https://youtube.com/watch?v=...
```

**Lo que hace:**
- Extrae la transcripción del video
- Sintetiza los puntos clave (no sólo resume — extrae insights accionables)
- Crea nota en `04-resources/youtube/`

---

### `process social`

**Cuándo:** Tienes capturas de LinkedIn, Twitter, o cualquier red social en `00-inbox/social-media-queue/`.

**Trigger:**
```
process social
```

**Lo que hace:**
- Escanea `00-inbox/social-media-queue/`
- Extrae ideas y las convierte en notas procesables
- Mueve el original a `09-archive/` o lo elimina

---

### `convert files`

**Cuándo:** Tienes PDFs, DOCX o archivos no-markdown en el inbox que necesitan convertirse antes de procesar.

**Trigger:**
```
convert files
```

**Lo que hace:**
- Escanea `00-inbox/` por archivos `.pdf`, `.docx`, `.rtf`, `.txt`
- Los convierte a Markdown usando las herramientas disponibles
- Los deposita en `00-inbox/` para procesamiento posterior

**Nota:** `process inbox` incluye este paso automáticamente (Step 0). Solo usar `convert files` como paso aislado si necesitas la conversión sin el procesamiento completo.

━━━

## 3. Skills de procesamiento

### `triage inbox`

**Cuándo:** El inbox está desordenado y quieres organizarlo antes de hacer el procesamiento completo. Paso previo opcional.

**Trigger:**
```
triage inbox
```

**Lo que hace:**
- Mueve archivos a las subcarpetas correctas dentro de `00-inbox/`:
  - Screenshots/socials → `social-media-queue/`
  - URLs/artículos → `url-dumps/`
  - PDFs/DOCX → `convert-queue/`
  - Pensamientos crudos → `quick-capture/`
- **No mueve nada fuera de `00-inbox/`** — ese es el trabajo de `process inbox`

**Cuándo NO usar:** Si el inbox es pequeño (<10 items), ve directo a `process inbox`.

---

### `process inbox`

**Cuándo:** El inbox tiene items acumulados y es hora de procesarlos. El workflow más importante del sistema.

**Trigger:**
```
process inbox
```

**Lo que hace (en orden):**
1. Convierte archivos no-markdown automáticamente
2. Clasifica cada item como Tipo A (raw capture → procesamiento completo) o Tipo B (documento curado → solo indexar)
3. Para Tipo A: añade frontmatter, normaliza, crea wikilinks, mueve a carpeta final
4. Para Tipo B: añade frontmatter y wikilinks **sin tocar el cuerpo** del documento
5. Reporta items stale (>7 días)

**Expectativa de tiempo:** 5-15 minutos según el volumen del inbox.

**Regla crítica:** El skill nunca elimina — mueve o deja en lugar con flag de stale.

---

### `synthesize [topic]`

**Cuándo:** Quieres saber qué sabes sobre un tema — integra todas las notas relacionadas en un MOC.

**Trigger:**
```
synthesize value-based pricing
synthesize estrategias de adquisición de clientes
```

**Lo que hace:**
- Busca en todo el vault por el tema y sinónimos (ES + EN)
- Lee cada nota relevante
- Produce una síntesis en prosa (no bullet list) con patrones, contradicciones y gaps
- Crea o actualiza el MOC en `03-knowledge/maps-of-content/MOC-[Tema].md`

**Cuándo NO usar:** Si tienes <3 notas sobre el tema, primero captura más. El skill te lo dirá.

━━━

## 4. Skills de planificación y revisión

### `daily brief`

**Cuándo:** Primera cosa en la mañana, antes de empezar a trabajar.

**Trigger:**
```
daily brief
```

**Lo que hace:**
1. Verifica si Cron 1 ya sincronizó (si sí, salta el sync)
2. Lee la nota de ayer, los **3 compacts más recientes** de `01-daily/logs/compacts/` (NO los raw session logs de `01-daily/logs/`) y `_ACTIVE-PROJECTS.md`
3. Cuenta items en el inbox, flaggea stale
4. Lee los `_overview.md` de cada proyecto activo
5. Escribe el brief en `01-daily/YYYY-MM-DD.md`
6. Te lo muestra directamente en el chat

**Output esperado:**
- Top 3 prioridades del día
- Blockers / decisiones abiertas
- Estado del inbox
- Carryover de ayer
- Pulso por proyecto (dinámico desde `_ACTIVE-PROJECTS.md`)

**Nota:** Si Cron 1 corrió esta mañana, el brief se genera en segundos. Si no, puede tardar un poco más en sincronizar overviews primero.

---

### `weekly review`

**Cuándo:** Fin de semana (domingo). El Cron 4 lo corre automáticamente los viernes a las 17:00. Si lo corres manualmente el domingo, el skill detectará si ya existe un review para hoy y te preguntará antes de sobreescribir.

**Trigger:**
```
weekly review
```

**Lo que hace:**
- Lee todas las notas diarias de los últimos 7 días
- Revisa avance en `06-goals/2026-annual.md`
- Detecta temas recurrentes (≥3 menciones = tema)
- Escribe el reporte en `06-goals/weekly/YYYY-MM-DD-weekly-review.md`
- Te muestra el resumen inline (wins, gaps, focus próxima semana)

---

### `ckis weekly review`

**Cuándo:** La versión extendida del `weekly review`. Incluye todo lo anterior más health checks del sistema CKIS y propuestas de edición a `_MEMORY.md`.

**Trigger:**
```
ckis weekly review
```

**Lo que hace adicionalmente al `weekly review`:**
- Verifica que los archivos CKIS 17, 18, 19 existen
- Propone edits a `_MEMORY.md` (diff-style) — **nunca los aplica sin que digas que sí**
- Cuenta sesiones de código registradas en Dev Brain esta semana
- Verifica integridad del índice CKIS

**Cuándo usar `ckis weekly review` vs `weekly review`:**
- `weekly review` → cuando solo quieres ver qué pasó en la semana
- `ckis weekly review` → cuando también quieres hacer mantenimiento del sistema

---

### `knowledge consolidation`

**Cuándo:** Una vez por mes. El Cron 5 maneja `_MEMORY.md` y `_ACTIVE-PROJECTS.md` — este skill maneja el conocimiento: detecta patrones en permanent notes y crea/actualiza MOCs.

**Trigger:**
```
knowledge consolidation
```

**Lo que hace:**
- Lee todas las permanent notes del mes
- Detecta patrones (temas en ≥3 notas → crea MOC o patrón)
- Actualiza `03-knowledge/maps-of-content/`
- Identifica gaps (capturado pero nunca procesado)
- Escribe reporte en `06-goals/monthly/YYYY-MM-monthly-report.md`

━━━

## 5. Skills de proyecto

### `project context [nombre]`

**Cuándo:** Antes de empezar una sesión de trabajo en un proyecto — sea en el vault o en la terminal de código.

**Trigger:**
```
project context [your-project]
project context [your-project]
project context recmp3-cli
project context university
```

**Lo que hace:**
- Lee `02-projects/<proyecto>/_overview.md`
- Escanea los últimos 14 daily notes por menciones del proyecto
- Revisa Dev Brain: `sessions/index.md` (últimas 5 sesiones de código) y `wiki/<slug>.md`
- Busca notas taggeadas con `#<proyecto>` en knowledge y inbox
- Compila brief de ≤300 palabras con: estado actual, decisiones abiertas, progreso reciente, blockers, y una **acción concreta sugerida** para hoy
- El brief incluye comandos de Dev Brain si el proyecto tiene repo conectado

**Output incluye (si Dev Brain está presente):**
```
## 🧠 Recent coding sessions (Dev Brain)
- 2026-05-17T04:10Z | [your-project] | session summary line...
→ Para código: graphify query "autenticación" en /ruta/al/repo
→ Wiki completo: cat ~/Documents/Dev\ Brain/wiki/[your-project].md
```

---

### `sync overviews`

**Cuándo:** Cuando varios archivos de proyectos cambiaron y los `_overview.md` están desactualizados.

**Trigger:**
```
sync overviews
```

**Lo que hace:**
- Detecta qué proyectos tuvieron cambios desde el último `modified:` del overview
- Lanza subagentes en paralelo (uno por proyecto con cambios)
- Cada subagente lee los archivos nuevos y actualiza el overview
- Cero tokens gastados en proyectos sin cambios

**Importante:** NO toca `graph-report.md` — ese archivo es responsabilidad del hook `post-commit.brain` y se actualiza automáticamente con cada commit.

---

### `onboard client`

**Cuándo:** Empieza el engagement con un nuevo cliente de [YOUR_PROJECT].

**Trigger:**
```
onboard client
```

**Lo que hace:**
- Crea la estructura de proyecto en `02-projects/<slug>/`
- Genera `_overview.md` con los campos del cliente
- Agrega entrada a `_ACTIVE-PROJECTS.md`
- Propone edits a `_MEMORY.md`

━━━

## 6. Skills de decisión y cross-model

### `log decision [título]`

**Cuándo:** Tomaste una decisión de proyecto o sistema que quieres documentar formalmente.

**Trigger:**
```
log decision usar Supabase Auth en lugar de Clerk
log decision productizar SEO audits como servicio de $200
```

**Lo que hace:**
- Te pide los campos que faltan (máximo una pregunta)
- Genera el bloque de decisión con: fecha, proyecto, status, por qué, alternativas, trade-offs, costo de reversión
- Lo escribe en el destino correcto:
  - Decisión de proyecto → `02-projects/<slug>/_overview.md`
  - Decisión de sistema → `00-systems/ckis/CHANGELOG.md`
  - Decisión estratégica/personal → `03-knowledge/permanent-notes/decision-<slug>.md`
- Actualiza `_MEMORY.md` Open Decisions si status es `proposed`

**Regla:** Nunca sobreescribe decisiones anteriores. Agrega una nueva y marca la vieja como `superseded`.

---

### `cross-model handoff [destino] [tema]`

**Cuándo:** Necesitas continuar el trabajo en Claude Chat o ChatGPT con contexto completo del vault, sin hacer copy-paste manual.

**Trigger:**
```
cross-model handoff chatgpt pricing [your-project] bloque 3
cross-model handoff claude-chat arquitectura auth supabase
```

**Lo que hace:**
- Lee el working slot activo (`14-active-working-slot.md`)
- Lee el `_overview.md` del proyecto relevante
- Genera un bloque copy-pasteable de ≤300 palabras (ChatGPT) o ≤500 palabras (Claude Chat)
- Incluye: contexto, archivos CKIS relevantes, estado del proyecto, y **el ask concreto**
- Lista qué NO pegar (secretos, PII, _MEMORY.md completo)

---

### `export context`

**Cuándo:** Después de cualquier cambio significativo en los archivos CKIS, antes de una sesión en ChatGPT Projects.

**Trigger:**
```
export context
```

**Lo que hace:**
- Lee la lista canonical de archivos en CKIS file 11 §1
- Verifica que los archivos 17, 18 y 19 estén incluidos (los agrega si no)
- Copia todos los archivos a `00-systems/ckis/chatgpt-project-upload/`
- Diff contra la versión anterior
- Escribe entrada en CHANGELOG
- Te recuerda re-subir el paquete a ChatGPT Projects (paso manual)

━━━

## 7. Skills de mantenimiento del sistema

### `vault maintenance health-check`

**Cuándo:** Una vez a la semana, o cuando sospeches que el sistema tiene drift (notas stale, overviews incorrectos, etc.).

**Trigger:**
```
vault maintenance health-check
```

**Lo que hace (solo lectura — no modifica nada):**
- Proyectos activos silenciosos ≥30 días
- Items en inbox >7 días
- Archivos CKIS 17, 18, 19 presentes
- ChatGPT package incluye los 3 nuevos archivos
- `_MEMORY.md` actualizado en los últimos 35 días (Cron 5 currency)
- Templates en sync con el spec de CKIS file 08

**Output:** Reporte de estado. No toca nada.

---

### `vault maintenance add-project [slug]`

**Cuándo:** Empiezas a trabajar en un proyecto nuevo que necesita estructura en el vault.

**Trigger:**
```
vault maintenance add-project recmp3-cli
vault maintenance add-project [your-project]-crm
```

**Lo que hace:**
- Crea `02-projects/<slug>/`
- Scaffoldea `_overview.md` con frontmatter correcto
- Agrega entrada a `_ACTIVE-PROJECTS.md`
- Propone (no escribe) edits a `_MEMORY.md`
- Escribe CHANGELOG entry

---

### `vault maintenance archive-project [slug]`

**Cuándo:** Un proyecto terminó o se pausó definitivamente.

**Trigger:**
```
vault maintenance archive-project [archived-project]
```

**Siempre confirma antes de ejecutar.** Mueve el folder completo a `09-archive/<slug>/`.

━━━

## 8. Cadenas de skills (flujos completos)

### Flujo matutino estándar
```
daily brief
→ (si inbox tiene items) triage inbox → process inbox
→ braindump [cualquier idea de la mañana]
```

### Flujo de sesión de knowledge
```
project context [nombre]
→ synthesize [tema relevante al proyecto]
→ log decision [si tomaste alguna]
→ braindump [al cerrar: ideas residuales]
```

### Flujo semanal completo
```
ckis weekly review
→ (si propone edits a _MEMORY.md y dices sí) aplica
→ sync overviews
→ vault maintenance health-check
```

### Flujo de procesamiento profundo
```
triage inbox
→ convert files
→ process inbox
→ synthesize [tema que emergió del inbox]
→ knowledge consolidation (si es fin de mes)
```

### Flujo de briefing multi-modelo
```
export context
→ [re-subir paquete a ChatGPT Projects — manual]
→ cross-model handoff chatgpt [tema]
→ [pegar el bloque en ChatGPT]
```

### Flujo de inicio de proyecto nuevo
```
vault maintenance add-project [slug]
→ onboard client (si es cliente)
→ project context [slug]
→ log decision [primera decisión de arquitectura o estrategia]
```

━━━

## 9. Tabla de referencia rápida

| Trigger | Skill | Cuándo | Output |
|---|---|---|---|
| `daily brief` | daily-brief | Mañana, antes de trabajar | Brief en `01-daily/YYYY-MM-DD.md` + inline |
| `braindump` | braindump | Cualquier momento, idea rápida | Archivo en `00-inbox/quick-capture/` |
| `triage inbox` | ckis-capture-triage | Pre-sort antes de procesar | Archivos movidos a subcarpetas de inbox |
| `process inbox` | process-inbox | Inbox acumulado | Inbox vaciado, notas en carpetas finales |
| `process URL [url]` | url-processor | URL encontrada | Nota en `04-resources/articles/` |
| `process YouTube [url]` | youtube-processor | Video a retener | Nota en `04-resources/youtube/` |
| `process social` | social-media-processor | Capturas de redes | Notas en `04-resources/social-captures/` |
| `convert files` | convert-to-md | PDFs/DOCX en inbox | Archivos .md en inbox |
| `synthesize [tema]` | knowledge-synthesis | Quiero saber qué sé sobre X | MOC actualizado/creado + síntesis inline |
| `weekly review` | weekly-review | Domingo / fin de semana | Reporte en `06-goals/weekly/` |
| `ckis weekly review` | ckis-weekly-review | Domingo + mantenimiento sistema | Como arriba + health check + propuestas _MEMORY.md |
| `knowledge consolidation` | monthly-consolidation | Fin de mes | MOCs actualizados + reporte en `06-goals/monthly/` |
| `project context [nombre]` | project-context | Antes de sesión de trabajo | Brief 300 palabras + Dev Brain refs |
| `sync overviews` | sync-overviews | Overviews desactualizados | `_overview.md` actualizados |
| `onboard client` | client-onboarding | Nuevo cliente [YOUR_PROJECT] | Estructura en `02-projects/` |
| `log decision [título]` | ckis-decision-log | Decisión tomada | Entry en destino + `_MEMORY.md` actualizado |
| `cross-model handoff [dest] [tema]` | ckis-cross-model-handoff | Continuar en otro modelo | Bloque copy-pasteable |
| `export context` | ckis-context-export | Cambios en CKIS, antes de ChatGPT | Paquete en `chatgpt-project-upload/` |
| `vault maintenance health-check` | ckis-vault-maintenance | Semanal o ante sospecha de drift | Reporte de salud (read-only) |
| `vault maintenance add-project [slug]` | ckis-vault-maintenance | Proyecto nuevo | Estructura creada en `02-projects/` |
| `vault maintenance archive-project [slug]` | ckis-vault-maintenance | Proyecto terminado | Folder movido a `09-archive/` |

━━━

## 10. Troubleshooting

### El skill no ejecuta
→ Verifica que el trigger está exactamente como en la tabla (mayúsculas/minúsculas no importan, pero la estructura sí)
→ Lee `.claude/CLAUDE.md` sección Commands — si el trigger no está listado, el skill no está registrado

### El skill arranca pero no encuentra archivos
→ Verifica que el cwd es la raíz del vault: `pwd` debe mostrar la ruta del vault
→ Si estás en otro directorio, `cd ~/Documents/Second\ Brain` (o tu ruta) antes de abrir Claude

### `daily brief` muestra "sin contexto de sesión" o contexto vacío
→ Verifica que `01-daily/logs/compacts/` existe y tiene archivos: `ls 01-daily/logs/compacts/ | sort | tail -5`
→ Los compacts se generan cuando corres `/compact` en una sesión. Si nunca lo has corrido, el directorio está vacío.
→ El skill NO lee los raw session logs en `01-daily/logs/*.md` — solo lee compacts.

### `daily brief` muestra proyectos hardcodeados ([YOUR_PROJECT], Brisas, University)
→ La guía está desactualizada. A partir de v2.2 el brief lee dinámicamente `_ACTIVE-PROJECTS.md` 🟢
→ Si sigues viendo proyectos hardcodeados, el skill necesita actualizarse — reportar

### `process inbox` modifica el cuerpo de un documento que no debería tocar
→ Añade `processing: index-only` al frontmatter del documento
→ O añade el tag `#preserve-body` en las primeras 50 líneas del body
→ Próxima vez, el skill lo detectará como Tipo B y solo actualizará frontmatter

### `ckis weekly review` quiere sobreescribir el review de Cron 4
→ Cron 4 corrió automáticamente — ya hay un review del día
→ El skill te pregunta: overwrite / append / abort
→ Responde `append` para agregar una sección con reflexiones manuales sin perder el de Cron 4

### `log decision` me hace demasiadas preguntas
→ Solo hace **una** pregunta: el campo más importante que falta
→ Si hace más de una, es un bug — reportar en el repo de CKIS

### `export context` no incluye los archivos 17, 18, 19
→ Esto es un bug que debería auto-corregirse: el skill verifica y agrega los 3 archivos a la lista
→ Si no lo hace, ejecutar manualmente: `vault maintenance health-check` para diagnosticar

### `project context` no muestra sesiones de Dev Brain
→ Verificar que `~/Documents/Dev\ Brain/sessions/index.md` existe: `cat ~/Documents/Dev\ Brain/sessions/index.md`
→ Si está vacío, las sesiones de código aún no lo han alimentado — revisar que el hook Stop de los repos de código está activo
→ Para ver compacts del proyecto (más detalle que el index): `ls ~/Documents/Dev\ Brain/sessions/compacts/<slug>/`
→ Proyectos registrados en Dev Brain: `cat ~/Documents/Dev\ Brain/projects.json`

━━━

## 11. Lo que las skills NO hacen

Para evitar confusión con qué está automatizado vs qué es manual:

| Acción | Automático | Manual |
|---|---|---|
| Actualizar `_MEMORY.md` | Cron 5 (mensual) | `ckis weekly review` (propone, tú confirmas) |
| Sincronizar vault a git | Cron 1 (cada 6h) | `git commit && git push` |
| Actualizar `graph-report.md` | post-commit.brain (por commit) | Nunca — no tocar |
| Actualizar `code-graph/` en Dev Brain | post-commit.brain (cada 10 commits) | Nunca — no tocar |
| Indexar sesiones en Dev Brain | Stop hook de cada repo | Nunca — no tocar |
| Rutear compacts a Dev Brain | Stop hook (catch-all) + UserPromptSubmit hook (eager en `/compact`) | Nunca — automático |
| Crear notas de knowledge desde braindump | ❌ | `process inbox` |
| Decidir qué notas borrar | ❌ | Eduardo — siempre |
| Re-subir contexto a ChatGPT Projects | ❌ | Manual en browser |

━━━

**Principio:** Las skills son aceleradores, no sustitutos. Saben cómo procesar, pero tú decides qué importa. La calidad del sistema depende de la frecuencia con que usas las skills — especialmente `daily brief`, `process inbox`, y `log decision`.
