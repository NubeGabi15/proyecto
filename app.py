# =========================
# app.py — Ver a través de la voz (Home + Botones + PostgreSQL + TFLite)
# + Admin: Actualizar precios en app.precio ✅
# =========================

import os, io, re, base64, warnings
from datetime import datetime, date

import numpy as np
import pandas as pd
import streamlit as st
from PIL import Image
import cv2
import psycopg2
import psycopg2.extras
import tensorflow as tf

# =========================
# CONFIGURACIÓN
# =========================
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
warnings.filterwarnings("ignore")

st.set_page_config(
    page_title="Ver a través de la voz",
    page_icon="🍓",
    layout="wide",
)

# =========================
# RUTAS
# =========================
MODEL_PATH = "keras_unquant.tflite"
LABELS_PATH = "labels.txt"
BG_PATH = os.path.join("assets", "frutas.jpeg")  # <-- tu imagen de fondo
LOGO_PATH = os.path.join("imagen", "logo.png")  # opcional

# =========================
# UTILIDADES UI
# =========================
def _file_to_base64(path: str) -> str | None:
    if not os.path.exists(path):
        return None
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")

def set_bg_image(bg_path: str):
    b64 = _file_to_base64(bg_path)
    if not b64:
        return
    st.markdown(
        f"""
        <style>
        .stApp {{
            background-image: url("data:image/png;base64,{b64}");
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }}

        /* Oscurecer un poquito para mejor lectura */
        .overlay {{
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.35);
            z-index: -1;
        }}

        /* Botones estilo menú */
        .menu-title {{
            text-align:center;
            font-size: 2.0rem;
            font-weight: 800;
            color: white;
            text-shadow: 0 2px 14px rgba(0,0,0,0.55);
            margin-top: 1rem;
            margin-bottom: 0.4rem;
            letter-spacing: 0.5px;
        }}

        .menu-sub {{
            text-align:center;
            font-size: 1.05rem;
            color: rgba(255,255,255,0.9);
            text-shadow: 0 2px 14px rgba(0,0,0,0.55);
            margin-bottom: 1.6rem;
        }}

        .card {{
            background: rgba(10, 14, 26, 0.62);
            border: 1px solid rgba(255,255,255,0.10);
            border-radius: 18px;
            padding: 18px 18px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.35);
            backdrop-filter: blur(8px);
        }}

        .stButton > button {{
            width: 100%;
            border-radius: 14px;
            padding: 0.9rem 1rem;
            font-size: 1.05rem;
            font-weight: 700;
            border: 1px solid rgba(255,255,255,0.18);
            background: rgba(88, 90, 255, 0.35);
            color: white;
        }}
        .stButton > button:hover {{
            border-color: rgba(255,255,255,0.35);
            background: rgba(88, 90, 255, 0.55);
            transform: translateY(-1px);
        }}

        /* tarjetas internas */
        .panel {{
            background: rgba(7, 10, 20, 0.70);
            border: 1px solid rgba(255,255,255,0.10);
            border-radius: 16px;
            padding: 14px 14px;
            backdrop-filter: blur(8px);
        }}

        /* inputs un poco más claros sobre fondo */
        div[data-baseweb="input"] input {{
            background: rgba(255,255,255,0.95) !important;
        }}
        div[data-baseweb="select"] > div {{
            background: rgba(255,255,255,0.95) !important;
        }}
        </style>
        <div class="overlay"></div>
        """,
        unsafe_allow_html=True
    )

def goto(page_name: str):
    st.session_state["page"] = page_name

def back_home():
    goto("home")

# =========================
# MODELO TFLITE + LABELS
# =========================
def load_labels(path: str) -> list[str]:
    with open(path, encoding="utf-8") as f:
        return [l.strip() for l in f if l.strip()]

@st.cache_resource
def load_tflite():
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(f"No existe el modelo: {MODEL_PATH}")
    if not os.path.exists(LABELS_PATH):
        raise FileNotFoundError(f"No existe labels: {LABELS_PATH}")

    labels = load_labels(LABELS_PATH)
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()

    inp = interpreter.get_input_details()
    out = interpreter.get_output_details()

    # shape: [1, H, W, C]
    _, h, w, _ = inp[0]["shape"]
    size_hw = (int(w), int(h))
    return labels, interpreter, inp, out, size_hw

def prepare(img: Image.Image, size_hw: tuple[int, int]) -> np.ndarray:
    arr = np.array(img.convert("RGB"))
    arr = cv2.resize(arr, size_hw, interpolation=cv2.INTER_LINEAR)
    arr = (arr.astype("float32") / 127.5) - 1.0
    return np.expand_dims(arr, 0)

def predict_tflite(img: Image.Image, labels, interpreter, inp, out, size_hw):
    x = prepare(img, size_hw)
    t0 = datetime.now()
    interpreter.set_tensor(inp[0]["index"], x.astype(np.float32))
    interpreter.invoke()
    probs = interpreter.get_tensor(out[0]["index"])[0]
    dt_ms = int((datetime.now() - t0).total_seconds() * 1000)
    idx = int(np.argmax(probs))
    return labels[idx], float(probs[idx]), dt_ms, probs

def parse_label(label: str):
    clean = re.sub(r"^[0-9\s_]+", "", label.lower()).strip()
    clean = clean.replace("-", "_")
    parts = [p for p in clean.split("_") if p]
    if len(parts) < 2:
        return label.title(), "desconocido"

    estado_raw = parts[-1]
    fruta_raw = " ".join(parts[:-1]).title()

    mapa = {
        "daniado": "dañada",
        "danado": "dañada",
        "mal": "dañada",
        "maduro": "buena",
        "maduros": "buena",
        "medio": "media",
        "media": "media",
        "bueno": "buena",
        "buena": "buena",
    }
    estado = mapa.get(estado_raw, estado_raw)
    return fruta_raw, estado

# =========================
# VOZ (TTS) MEJORADA
# =========================
def speak(texto: str):
    try:
        from gtts import gTTS
        import io, base64, streamlit as st

        # Normalización para voz más humana
        texto = texto.replace("%", " por ciento")
        texto = texto.replace("kg", " kilo")

        # Pausas naturales
        texto = texto.replace(",", ", ")
        texto = texto.replace(".", ". ... ")

        buf = io.BytesIO()
        tts = gTTS(text=texto, lang="es", slow=False)
        tts.write_to_fp(buf)

        b64 = base64.b64encode(buf.getvalue()).decode()
        st.markdown(
            f"""
            <audio autoplay>
                <source src="data:audio/mp3;base64,{b64}" type="audio/mp3">
            </audio>
            """,
            unsafe_allow_html=True
        )
    except Exception:
        st.warning("No se pudo reproducir la voz")

# =========================
# BASE DE DATOS (PostgreSQL)
# =========================
def _db_params():
    defaults = dict(
        host="127.0.0.1",
        port="5432",
        dbname="frutas_finalV",
        user="postgres",
        password="12345"
    )
    try:
        pg = st.secrets["postgres"]
        return dict(
            host=pg.get("host", defaults["host"]),
            port=str(pg.get("port", defaults["port"])),
            dbname=pg.get("dbname", defaults["dbname"]),
            user=pg.get("user", defaults["user"]),
            password=pg.get("password", defaults["password"]),
        )
    except Exception:
        return defaults
    
# =========================
# PESO PROMEDIO POR FRUTA (gramos)
# =========================
PESO_PROMEDIO = {
    "Manzana": 180,
    "Naranja": 200,
    "Fresa": 15,
    "Banano": 120,
    "Guineo": 120,
    "Tomate Riñón": 150,
}


@st.cache_resource
def get_conn():
    p = _db_params()
    conn = psycopg2.connect(
        host=p["host"],
        port=p["port"],
        dbname=p["dbname"],
        user=p["user"],
        password=p["password"],
    )
    conn.autocommit = True
    return conn

def db_ping():
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("SELECT 1;")
        cur.fetchone()

def _label_key(label_modelo: str) -> str:
    clean = label_modelo.strip().lower().replace("-", "_")
    clean = re.sub(r"^[0-9\s_]+", "", clean).strip()
    return clean

def db_get_modelo_id() -> int:
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("SELECT modelo_id FROM app.modelo WHERE activo=true ORDER BY modelo_id ASC LIMIT 1;")
        row = cur.fetchone()
        return int(row[0]) if row else 1

def db_get_clase_id(label_modelo: str) -> int | None:
    # 1️⃣ quitar número inicial → "13 tomate_daniado" → "tomate_daniado"
    clean = re.sub(r"^[0-9]+\s*", "", label_modelo.strip().lower())

    # 2️⃣ normalizar género (modelo vs BD)
    reemplazos = {
        "_daniado": "_daniada",
        "_bueno": "_buena",
        "_medio": "_media"
    }

    for k, v in reemplazos.items():
        if clean.endswith(k):
            clean = clean.replace(k, v)

    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT clase_id
            FROM app.clase_modelo
            WHERE lower(etiqueta) = %s
            LIMIT 1;
            """,
            (clean,)
        )
        row = cur.fetchone()
        return int(row[0]) if row else None



def db_get_or_create_sesion() -> int:
    if "sesion_id" in st.session_state:
        return int(st.session_state["sesion_id"])

    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO app.sesion (dispositivo, plataforma, version_app)
            VALUES (%s,%s,%s)
            RETURNING sesion_id;
            """,
            ("desktop", "streamlit", "1.0")
        )
        sesion_id = int(cur.fetchone()[0])

    st.session_state["sesion_id"] = sesion_id
    return sesion_id

def db_insert_imagen(raw_bytes: bytes, pil_img: Image.Image, origen: str, sesion_id: int) -> int:
    import hashlib
    w, h = pil_img.size
    sha = hashlib.sha256(raw_bytes).hexdigest()
    fmt = (pil_img.format or "").lower() if hasattr(pil_img, "format") else ""
    if not fmt:
        fmt = "jpeg"

    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO app.imagen (sesion_id, ruta_imagen, hash_sha256, formato, ancho, alto, origen)
            VALUES (%s,%s,%s,%s,%s,%s,%s)
            ON CONFLICT (hash_sha256) DO UPDATE SET capturada_en=now()
            RETURNING imagen_id;
            """,
            (sesion_id, origen, sha, fmt, int(w), int(h), origen)
        )
        return int(cur.fetchone()[0])

def db_insert_prediccion(imagen_id: int, modelo_id: int, clase_id: int, confianza: float, tiempo_ms: int | None):
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO app.prediccion (imagen_id, modelo_id, clase_id, confianza, tiempo_ms)
            VALUES (%s,%s,%s,%s,%s);
            """,
            (int(imagen_id), int(modelo_id), int(clase_id), float(confianza), int(tiempo_ms) if tiempo_ms else None)
        )

def save_prediction(origen: str, label_modelo: str, confianza: float, tiempo_ms: int):
    if "last_raw_bytes" not in st.session_state or st.session_state["last_raw_bytes"] is None:
        raise RuntimeError("No hay bytes de imagen disponibles.")
    if "last_pil_img" not in st.session_state or st.session_state["last_pil_img"] is None:
        raise RuntimeError("No hay imagen PIL disponible.")

    raw_bytes = st.session_state["last_raw_bytes"]
    pil_img = st.session_state["last_pil_img"]

    sesion_id = db_get_or_create_sesion()
    imagen_id = db_insert_imagen(raw_bytes, pil_img, origen, sesion_id)
    modelo_id = db_get_modelo_id()
    clase_id = db_get_clase_id(label_modelo)
    if clase_id is None:
        raise RuntimeError(f"No se encontró clase_id para: {label_modelo}")

    db_insert_prediccion(imagen_id, modelo_id, clase_id, confianza, tiempo_ms)

def fetch_history(limit: int = 200):
    conn = get_conn()
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(
            """
            SELECT
                p.creado_en AS fecha,
                i.origen AS origen,
                f.nombre AS fruta,
                cm.estado AS estado,
                cm.etiqueta AS label_modelo,
                p.confianza AS confianza,
                p.tiempo_ms AS tiempo_ms
            FROM app.prediccion p
            JOIN app.imagen i ON i.imagen_id=p.imagen_id
            JOIN app.clase_modelo cm ON cm.clase_id=p.clase_id
            JOIN app.fruta f ON f.fruta_id=cm.fruta_id
            ORDER BY p.creado_en DESC
            LIMIT %s;
            """,
            (int(limit),)
        )
        rows = cur.fetchall()

    df = pd.DataFrame(rows)
    if df.empty:
        return df

    mapa_origen = {"camara": "Usuario", "galeria": "Administrador", "prueba": "Prueba"}
    df["modo"] = df["origen"].map(lambda x: mapa_origen.get(str(x), str(x)))

    mapa_estado = {"bueno": "buena", "medio": "media", "daniado": "dañada"}
    df["estado"] = df["estado"].map(lambda x: mapa_estado.get(str(x), str(x)))

    df["confianza"] = df["confianza"].astype(float)
    df["confianza_pct"] = (df["confianza"] * 100).round(1)
    return df

# ==========================================================
# ✅ NUEVO: PRECIOS (app.precio + app.mercado + app.fruta)
# ==========================================================
def db_list_frutas():
    conn = get_conn()
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT fruta_id, nombre FROM app.fruta WHERE activo=true ORDER BY nombre;")
        return cur.fetchall()

def db_list_mercados():
    conn = get_conn()
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("SELECT mercado_id, nombre, COALESCE(ciudad,'') AS ciudad FROM app.mercado ORDER BY nombre;")
        return cur.fetchall()

def db_get_or_create_mercado(nombre: str, ciudad: str = "", fuente: str = "manual") -> int:
    nombre = (nombre or "").strip()
    ciudad = (ciudad or "").strip()
    if not nombre:
        raise ValueError("El nombre del mercado no puede estar vacío.")

    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT mercado_id FROM app.mercado
            WHERE lower(nombre)=lower(%s) AND lower(COALESCE(ciudad,''))=lower(%s)
            LIMIT 1;
            """,
            (nombre, ciudad)
        )
        row = cur.fetchone()
        if row:
            return int(row[0])

        cur.execute(
            """
            INSERT INTO app.mercado (nombre, ciudad, fuente)
            VALUES (%s,%s,%s)
            RETURNING mercado_id;
            """,
            (nombre, ciudad, fuente)
        )
        return int(cur.fetchone()[0])

def db_upsert_precio(fruta_id: int, mercado_id: int | None, fecha_: date, precio_kg: float, moneda: str = "USD"):
    # app.precio tiene UNIQUE (fruta_id, mercado_id, fecha)
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO app.precio (fruta_id, mercado_id, fecha, precio_kg, moneda)
            VALUES (%s,%s,%s,%s,%s)
            ON CONFLICT (fruta_id, mercado_id, fecha)
            DO UPDATE SET precio_kg=EXCLUDED.precio_kg, moneda=EXCLUDED.moneda;
            """,
            (int(fruta_id), int(mercado_id) if mercado_id is not None else None, fecha_, float(precio_kg), moneda)
        )

def db_fetch_precios(limit: int = 200):
    conn = get_conn()
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(
            """
            SELECT
              p.precio_id,
              f.nombre AS fruta,
              COALESCE(m.nombre,'') AS mercado,
              COALESCE(m.ciudad,'') AS ciudad,
              p.fecha,
              p.precio_kg,
              p.moneda
            FROM app.precio p
            JOIN app.fruta f ON f.fruta_id=p.fruta_id
            LEFT JOIN app.mercado m ON m.mercado_id=p.mercado_id
            ORDER BY p.fecha DESC, p.precio_id DESC
            LIMIT %s;
            """,
            (int(limit),)
        )
        return pd.DataFrame(cur.fetchall())
    
def db_get_precio_actual(fruta_nombre: str):
    conn = get_conn()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT p.precio_kg, p.moneda, p.fecha
            FROM app.precio p
            JOIN app.fruta f ON f.fruta_id = p.fruta_id
            WHERE lower(f.nombre) = lower(%s)
            ORDER BY p.fecha DESC
            LIMIT 1;
        """, (fruta_nombre,))
        row = cur.fetchone()
        if row:
            return {
                "precio": float(row[0]),
                "moneda": row[1],
                "fecha": row[2]
            }
    return None


# =========================
# CARGA (modelo + DB)
# =========================
set_bg_image(BG_PATH)

# Logo opcional (arriba a la derecha)
logo_b64 = _file_to_base64(LOGO_PATH)
if logo_b64:
    st.markdown(
        f"""
        <style>
        .logo-fixed {{
            position: fixed;
            top: 90px;
            right: 90px;
            z-index: 999;
            opacity: 0.95;
        }}
        .logo-fixed img {{
            height: 100px;
            filter: drop-shadow(0 6px 16px rgba(0,0,0,0.35));
        }}
        </style>
        <div class="logo-fixed"><img src="data:image/png;base64,{logo_b64}"></div>
        """,
        unsafe_allow_html=True
    )

# Cargar TFLite
try:
    labels, interpreter, inp, out, SIZE = load_tflite()
except Exception as e:
    st.error("❌ No se pudo cargar el modelo o labels.txt")
    st.write(e)
    st.stop()

# DB ping
db_ok, db_error = True, None
try:
    db_ping()
except Exception as e:
    db_ok, db_error = False, e

# =========================
# ROUTER
# =========================
if "page" not in st.session_state:
    st.session_state["page"] = "home"

page = st.session_state["page"]

# =========================
# HOME
# =========================
if page == "home":
    st.markdown('<div class="menu-title">VER A TRAVÉS DE LA VOZ</div>', unsafe_allow_html=True)
    st.markdown('<div class="menu-sub">Interfaz en computadora</div>', unsafe_allow_html=True)

    c1, c2, c3 = st.columns([1, 1, 1], gap="large")
    with c2:
        st.markdown('<div class="card">', unsafe_allow_html=True)
        st.markdown("#### Elige una opción")
        st.caption("Accesibilidad • IA • Registro de predicciones")
        st.write("")

        b1 = st.button("👤 Usuario")
        b2 = st.button("🛠️ Administrador")
        b3 = st.button("📊 Estadísticas")
        b4 = st.button("🗄️ Base de datos")

        st.write("")
        st.markdown(
            f"<div class='small-muted'>Estado BD: {'Conectado ✅' if db_ok else 'No conectado ❌'}</div>",
            unsafe_allow_html=True
        )
        if (not db_ok) and db_error:
            st.caption("Si estás en Streamlit Cloud, configura `.streamlit/secrets.toml`.")
        st.markdown("</div>", unsafe_allow_html=True)

        if b1: goto("usuario")
        if b2: goto("admin")
        if b3: goto("stats")
        if b4: goto("db")

# =========================
# PÁGINA: USUARIO
# =========================
elif page == "usuario":
    st.markdown("### 👤 Modo Usuario")
    if st.button("⬅ Volver al inicio"):
        back_home()
        st.stop()

    st.markdown('<div class="panel">', unsafe_allow_html=True)
    col_cam, col_res = st.columns([1.2, 1.0], gap="large")

    img = None
    with col_cam:
        st.markdown("#### 📷 Captura una fruta")
        cam = st.camera_input(" ", label_visibility="collapsed")
        if cam:
            raw = cam.getvalue()
            img = Image.open(io.BytesIO(raw))
            st.image(img, use_container_width=True)
            st.session_state["last_raw_bytes"] = raw
            st.session_state["last_pil_img"] = img

    with col_res:
        st.markdown("#### 🎯 Resultado")
        if img is None:
            st.info("Captura una imagen para analizar.")
        else:
            label, conf, tiempo_ms, _ = predict_tflite(img, labels, interpreter, inp, out, SIZE)
            fruta, estado = parse_label(label)

            st.success(f"**{fruta}**")
            st.write(f"**Estado:** {estado}")
            st.write(f"**Confianza:** {int(conf*100)}%")
            st.write(f"**Tiempo:** {tiempo_ms} ms")

            # ===== PRECIO + CANTIDAD =====
            precio_info = None
            if db_ok:
                precio_info = db_get_precio_actual(fruta)

            peso = PESO_PROMEDIO.get(fruta)
            cantidad = None

            if peso:
                cantidad = round(1000 / peso)

            # Mostrar en pantalla
            if precio_info:
                st.write(f"💲 **Precio estimado:** {precio_info['precio']:.2f} {precio_info['moneda']} / kg")

            if cantidad:
                st.write(f"⚖️ **Cantidad aproximada:** {cantidad} unidades ≈ 1 kg")

            # Voz completa (mensaje natural)
            mensaje = (
                f"La fruta detectada es {fruta}. "
                f"Su estado es {estado}. "
                f"La confianza del modelo es del {int(conf*100)} por ciento. "
            )

            if precio_info:
                mensaje += (
                    f"El precio estimado es de {precio_info['precio']:.2f} dólares por kilo. "
                )

            if cantidad:
                mensaje += (
                    f"Para un kilo se necesitan aproximadamente {cantidad} unidades."
                )

            speak(mensaje)


            if db_ok:
                try:
                    # label viene como "12 tomate_bueno"
                    label_limpio = label.split(" ", 1)[1]
                    save_prediction("camara", label_limpio, conf, tiempo_ms)
                except Exception as e:
                    st.warning("No se pudo guardar en PostgreSQL.")
                    st.write(e)

    st.markdown("</div>", unsafe_allow_html=True)

# =========================
# PÁGINA: ADMINISTRADOR
# =========================
elif page == "admin":
    st.markdown("### 🛠️ Modo Administrador")
    if st.button("⬅ Volver al inicio"):
        back_home()
        st.stop()

    st.markdown('<div class="panel">', unsafe_allow_html=True)
    col1, col2 = st.columns([1.2, 1.0], gap="large")

    img = None
    raw_bytes = None

    with col1:
        st.markdown("#### 📤 Subir imagen")
        up = st.file_uploader("Selecciona una imagen", ["jpg", "png", "jpeg"])
        if up:
            raw_bytes = up.getvalue()
            img = Image.open(io.BytesIO(raw_bytes))
            st.image(img, use_container_width=True)
            st.session_state["last_raw_bytes"] = raw_bytes
            st.session_state["last_pil_img"] = img

    with col2:
        st.markdown("#### 🎯 Resultado")
        if img is None:
            st.info("Sube una imagen para analizar.")
        else:
            label, conf, tiempo_ms, _ = predict_tflite(img, labels, interpreter, inp, out, SIZE)
            fruta, estado = parse_label(label)

            st.success(f"**{fruta}**")
            st.write(f"**Estado:** {estado}")
            st.write(f"**Confianza:** {int(conf*100)}%")
            st.write(f"**Tiempo:** {tiempo_ms} ms")

            if db_ok:
                try:
                    save_prediction("galeria", label, conf, tiempo_ms)
                except Exception as e:
                    st.warning("No se pudo guardar en PostgreSQL.")
                    st.write(e)

    st.markdown("</div>", unsafe_allow_html=True)

    # ==========================================================
    # ✅ NUEVO BLOQUE: ACTUALIZAR PRECIOS (Admin)
    # ==========================================================
    st.markdown('<div class="panel">', unsafe_allow_html=True)
    st.markdown("### 💲 Actualizar precio de frutas")

    if not db_ok:
        st.error("No hay conexión a PostgreSQL.")
        st.write(db_error)
        st.markdown("</div>", unsafe_allow_html=True)
    else:
        frutas = db_list_frutas()
        mercados = db_list_mercados()

        if not frutas:
            st.warning("No hay frutas en app.fruta. Inserta primero Fresa, Manzana, Naranja, Tomate riñón, Guineo.")
            st.markdown("</div>", unsafe_allow_html=True)
        else:
            # Select fruta
            fruta_map = {f["nombre"]: int(f["fruta_id"]) for f in frutas}
            fruta_sel = st.selectbox("Fruta", list(fruta_map.keys()))
            fruta_id = fruta_map[fruta_sel]

            # Mercado: elegir existente o crear uno
            colm1, colm2 = st.columns([1, 1])
            with colm1:
                modo_mercado = st.radio("Mercado", ["Usar existente", "Crear nuevo"], horizontal=True)
            with colm2:
                fecha_sel = st.date_input("Fecha del precio", value=date.today())

            mercado_id = None
            if modo_mercado == "Usar existente":
                if mercados:
                    m_names = [f'{m["nombre"]} ({m["ciudad"]})'.strip() for m in mercados]
                    m_sel = st.selectbox("Selecciona mercado", m_names)
                    idx = m_names.index(m_sel)
                    mercado_id = int(mercados[idx]["mercado_id"])
                else:
                    st.warning("No hay mercados en app.mercado. Cambia a 'Crear nuevo'.")
            else:
                nm = st.text_input("Nombre mercado", value="Mercado Principal")
                cd = st.text_input("Ciudad", value="Cuenca")
                if st.button("➕ Crear mercado"):
                    try:
                        mercado_id = db_get_or_create_mercado(nm, cd, fuente="manual")
                        st.success(f"Mercado listo ✅ (ID: {mercado_id})")
                        # refrescar lista
                        mercados = db_list_mercados()
                    except Exception as e:
                        st.error("No se pudo crear mercado.")
                        st.write(e)

            colp1, colp2, colp3 = st.columns([1, 1, 1])
            with colp1:
                precio_kg = st.number_input("Precio por kg (USD)", min_value=0.00, value=1.00, step=0.10, format="%.2f")
            with colp2:
                moneda = st.selectbox("Moneda", ["USD"])
            with colp3:
                st.write("")
                st.write("")
                guardar = st.button("💾 Guardar/Actualizar precio")

            if guardar:
                try:
                    if mercado_id is None:
                        st.warning("Primero selecciona un mercado o crea uno.")
                    else:
                        db_upsert_precio(fruta_id, mercado_id, fecha_sel, float(precio_kg), moneda)
                        st.success(f"Precio actualizado ✅ {fruta_sel} = {precio_kg:.2f} {moneda}/kg")
                except Exception as e:
                    st.error("No se pudo guardar el precio.")
                    st.write(e)

            st.markdown("#### 📋 Últimos precios registrados")
            df_p = db_fetch_precios(limit=200)
            if df_p.empty:
                st.info("Aún no hay precios en app.precio.")
            else:
                st.dataframe(df_p, use_container_width=True, hide_index=True)

    st.markdown("</div>", unsafe_allow_html=True)

# =========================
# PÁGINA: ESTADÍSTICAS
# =========================
elif page == "stats":
    st.markdown("### 📊 Estadísticas")
    if st.button("⬅ Volver al inicio"):
        back_home()
        st.stop()

    if not db_ok:
        st.error("No hay conexión a PostgreSQL.")
        st.write(db_error)
        st.stop()

    # --- Plotly ---
    import plotly.express as px
    import plotly.graph_objects as go

    st.markdown('<div class="panel">', unsafe_allow_html=True)

    # Parámetros
    limit = st.slider("Límite de registros", 50, 5000, 500, step=50)
    df = fetch_history(limit=limit)

    if df.empty:
        st.info("Aún no hay registros.")
        st.markdown("</div>", unsafe_allow_html=True)
        st.stop()

    # Asegurar datetime y campos útiles
    df = df.copy()
    df["fecha"] = pd.to_datetime(df["fecha"], errors="coerce")
    df = df.dropna(subset=["fecha"])

    # Filtros interactivos (arriba)
    cF1, cF2, cF3, cF4 = st.columns([1, 1, 1, 1])
    with cF1:
        modos = sorted(df["modo"].dropna().unique().tolist())
        f_modo = st.multiselect("Modo", modos, default=modos)
    with cF2:
        frutas = sorted(df["fruta"].dropna().unique().tolist())
        f_fruta = st.multiselect("Fruta", frutas, default=frutas)
    with cF3:
        estados = sorted(df["estado"].dropna().unique().tolist())
        f_estado = st.multiselect("Estado", estados, default=estados)
    with cF4:
        min_conf = st.slider("Confianza mínima (%)", 0, 100, 0, step=5)

    dff = df.copy()
    if f_modo:
        dff = dff[dff["modo"].isin(f_modo)]
    if f_fruta:
        dff = dff[dff["fruta"].isin(f_fruta)]
    if f_estado:
        dff = dff[dff["estado"].isin(f_estado)]
    dff = dff[dff["confianza_pct"] >= float(min_conf)]

    if dff.empty:
        st.warning("Con esos filtros no hay datos.")
        st.markdown("</div>", unsafe_allow_html=True)
        st.stop()

    # ======================
    # KPIs
    # ======================
    c1, c2, c3, c4 = st.columns(4)
    with c1:
        st.metric("Total predicciones", len(dff))
    with c2:
        st.metric("Confianza promedio", f"{dff['confianza_pct'].mean():.1f}%")
    with c3:
        tmean = dff["tiempo_ms"].dropna().mean()
        st.metric("Tiempo promedio", f"{tmean:.0f} ms" if pd.notna(tmean) else "—")
    with c4:
        st.metric("Frutas distintas", dff["fruta"].nunique())

    st.divider()

    # ======================
    # 1) Serie temporal (Predicciones por día)
    # ======================
    daily = (
        dff.assign(dia=dff["fecha"].dt.date)
           .groupby("dia", as_index=False)
           .size()
           .rename(columns={"size": "predicciones"})
    )

    fig_daily = px.line(
        daily,
        x="dia",
        y="predicciones",
        markers=True,
        title="Predicciones por día (uso de la app)"
    )
    fig_daily.update_layout(height=380)
    st.plotly_chart(fig_daily, use_container_width=True)

    # ======================
    # 2) Ranking de frutas + 3) Estados
    # ======================
    cA, cB = st.columns(2)

    with cA:
        top_frutas = dff["fruta"].value_counts().reset_index()
        top_frutas.columns = ["fruta", "conteo"]
        fig_frutas = px.bar(
            top_frutas,
            x="fruta",
            y="conteo",
            title="Top frutas detectadas"
        )
        fig_frutas.update_layout(height=380)
        st.plotly_chart(fig_frutas, use_container_width=True)

    with cB:
        top_est = dff["estado"].value_counts().reset_index()
        top_est.columns = ["estado", "conteo"]
        fig_est = px.pie(
            top_est,
            names="estado",
            values="conteo",
            hole=0.45,
            title="Distribución por estado"
        )
        fig_est.update_layout(height=380)
        st.plotly_chart(fig_est, use_container_width=True)

    # ======================
    # 4) Histograma de confianza + 5) Boxplot por fruta
    # ======================
    cC, cD = st.columns(2)

    with cC:
        fig_conf = px.histogram(
            dff,
            x="confianza_pct",
            nbins=20,
            title="Distribución de confianza (%)"
        )
        fig_conf.update_layout(height=380)
        st.plotly_chart(fig_conf, use_container_width=True)

    with cD:
        fig_box = px.box(
            dff,
            x="fruta",
            y="confianza_pct",
            points="all",
            title="Confianza por fruta (detección de clases confusas)"
        )
        fig_box.update_layout(height=380)
        st.plotly_chart(fig_box, use_container_width=True)

    # ======================
    # 6) Heatmap Hora vs Día
    # ======================
    dff["hora"] = dff["fecha"].dt.hour
    dff["dia_semana"] = dff["fecha"].dt.day_name()

    # ordenar días (lunes-domingo)
    order_days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    dff["dia_semana"] = pd.Categorical(dff["dia_semana"], categories=order_days, ordered=True)

    heat = (
        dff.groupby(["dia_semana", "hora"], as_index=False)
           .size()
           .rename(columns={"size":"predicciones"})
    )

    fig_heat = px.density_heatmap(
        heat,
        x="hora",
        y="dia_semana",
        z="predicciones",
        title="Mapa de calor: uso por día y hora",
        nbinsx=24
    )
    fig_heat.update_layout(height=420)
    st.plotly_chart(fig_heat, use_container_width=True)

    # ======================
    # Tabla final + exportar
    # ======================
    st.markdown("#### Últimos registros (filtrados)")
    st.dataframe(
        dff.sort_values("fecha", ascending=False)[
            ["fecha", "modo", "fruta", "estado", "confianza_pct", "tiempo_ms", "label_modelo"]
        ].head(200),
        use_container_width=True,
        hide_index=True
    )

    csv = dff.to_csv(index=False).encode("utf-8")
    st.download_button(
        "⬇️ Descargar estadísticas (CSV)",
        csv,
        file_name="estadisticas_predicciones.csv",
        mime="text/csv"
    )

    st.markdown("</div>", unsafe_allow_html=True)

# =========================
# PÁGINA: BASE DE DATOS
# =========================
elif page == "db":
    st.markdown("### 🗄️ Base de datos")
    if st.button("⬅ Volver al inicio"):
        back_home()
        st.stop()

    st.markdown('<div class="panel">', unsafe_allow_html=True)

    if db_ok:
        st.success("Conectado ✅")
        st.caption("Puedes usar esta vista para verificar tablas y exportar datos para Power BI.")
        try:
            conn = get_conn()
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT table_schema, table_name
                    FROM information_schema.tables
                    WHERE table_schema='app'
                    ORDER BY table_name;
                """)
                rows = cur.fetchall()
            tbl = pd.DataFrame(rows, columns=["schema", "tabla"])
            st.dataframe(tbl, use_container_width=True, hide_index=True)

            st.markdown("#### Exportar historial (CSV)")
            dfh = fetch_history(limit=2000)
            if not dfh.empty:
                csv = dfh.to_csv(index=False).encode("utf-8")
                st.download_button("⬇ Descargar historial (CSV)", csv, file_name="historial_predicciones.csv", mime="text/csv")

        except Exception as e:
            st.error("Error consultando la base.")
            st.write(e)
    else:
        st.error("No conectado ❌")
        st.write(db_error)
        st.caption("En Streamlit Cloud debes configurar `.streamlit/secrets.toml`.")

    st.markdown("</div>", unsafe_allow_html=True)

# =========================
# FOOTER
# =========================
st.markdown("---")
st.caption("Exámen Complexivo -- Karina Chisaguano Nube Gutierrez")