--
-- PostgreSQL database dump
--

-- Dumped from database version 14.15
-- Dumped by pg_dump version 14.15

-- Started on 2026-01-06 10:19:34

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 17889)
-- Name: app; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app;


ALTER SCHEMA app OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 213 (class 1259 OID 17905)
-- Name: clase_modelo; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.clase_modelo (
    clase_id bigint NOT NULL,
    fruta_id bigint NOT NULL,
    estado text NOT NULL,
    etiqueta text NOT NULL,
    creado_en timestamp with time zone DEFAULT now(),
    CONSTRAINT clase_modelo_estado_check CHECK ((estado = ANY (ARRAY['bueno'::text, 'medio'::text, 'daniado'::text])))
);


ALTER TABLE app.clase_modelo OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 17904)
-- Name: clase_modelo_clase_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.clase_modelo_clase_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.clase_modelo_clase_id_seq OWNER TO postgres;

--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 212
-- Name: clase_modelo_clase_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.clase_modelo_clase_id_seq OWNED BY app.clase_modelo.clase_id;


--
-- TOC entry 211 (class 1259 OID 17891)
-- Name: fruta; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.fruta (
    fruta_id bigint NOT NULL,
    nombre text NOT NULL,
    unidad text DEFAULT 'kg'::text,
    activo boolean DEFAULT true,
    creado_en timestamp with time zone DEFAULT now()
);


ALTER TABLE app.fruta OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 17890)
-- Name: fruta_fruta_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.fruta_fruta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.fruta_fruta_id_seq OWNER TO postgres;

--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 210
-- Name: fruta_fruta_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.fruta_fruta_id_seq OWNED BY app.fruta.fruta_id;


--
-- TOC entry 219 (class 1259 OID 17947)
-- Name: imagen; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.imagen (
    imagen_id bigint NOT NULL,
    sesion_id bigint,
    ruta_imagen text,
    hash_sha256 text,
    formato text,
    ancho integer,
    alto integer,
    origen text,
    capturada_en timestamp with time zone DEFAULT now(),
    CONSTRAINT imagen_origen_check CHECK ((origen = ANY (ARRAY['camara'::text, 'galeria'::text, 'camara_usb'::text])))
);


ALTER TABLE app.imagen OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17946)
-- Name: imagen_imagen_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.imagen_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.imagen_imagen_id_seq OWNER TO postgres;

--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 218
-- Name: imagen_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.imagen_imagen_id_seq OWNED BY app.imagen.imagen_id;


--
-- TOC entry 223 (class 1259 OID 17989)
-- Name: mercado; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.mercado (
    mercado_id bigint NOT NULL,
    nombre text NOT NULL,
    ciudad text,
    fuente text
);


ALTER TABLE app.mercado OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17988)
-- Name: mercado_mercado_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.mercado_mercado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.mercado_mercado_id_seq OWNER TO postgres;

--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 222
-- Name: mercado_mercado_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.mercado_mercado_id_seq OWNED BY app.mercado.mercado_id;


--
-- TOC entry 215 (class 1259 OID 17923)
-- Name: modelo; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.modelo (
    modelo_id bigint NOT NULL,
    nombre text NOT NULL,
    version text NOT NULL,
    framework text DEFAULT 'TensorFlow'::text,
    input_w integer NOT NULL,
    input_h integer NOT NULL,
    n_clases integer NOT NULL,
    activo boolean DEFAULT true,
    creado_en timestamp with time zone DEFAULT now()
);


ALTER TABLE app.modelo OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 17922)
-- Name: modelo_modelo_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.modelo_modelo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.modelo_modelo_id_seq OWNER TO postgres;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 214
-- Name: modelo_modelo_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.modelo_modelo_id_seq OWNED BY app.modelo.modelo_id;


--
-- TOC entry 225 (class 1259 OID 17998)
-- Name: precio; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.precio (
    precio_id bigint NOT NULL,
    fruta_id bigint NOT NULL,
    mercado_id bigint,
    fecha date NOT NULL,
    precio_kg numeric(10,2) NOT NULL,
    moneda text DEFAULT 'USD'::text
);


ALTER TABLE app.precio OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17997)
-- Name: precio_precio_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.precio_precio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.precio_precio_id_seq OWNER TO postgres;

--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 224
-- Name: precio_precio_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.precio_precio_id_seq OWNED BY app.precio.precio_id;


--
-- TOC entry 221 (class 1259 OID 17965)
-- Name: prediccion; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.prediccion (
    prediccion_id bigint NOT NULL,
    imagen_id bigint NOT NULL,
    modelo_id bigint NOT NULL,
    clase_id bigint NOT NULL,
    confianza numeric(5,4) NOT NULL,
    tiempo_ms integer,
    creado_en timestamp with time zone DEFAULT now(),
    CONSTRAINT prediccion_confianza_check CHECK (((confianza >= (0)::numeric) AND (confianza <= (1)::numeric)))
);


ALTER TABLE app.prediccion OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17964)
-- Name: prediccion_prediccion_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.prediccion_prediccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.prediccion_prediccion_id_seq OWNER TO postgres;

--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 220
-- Name: prediccion_prediccion_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.prediccion_prediccion_id_seq OWNED BY app.prediccion.prediccion_id;


--
-- TOC entry 217 (class 1259 OID 17937)
-- Name: sesion; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.sesion (
    sesion_id bigint NOT NULL,
    iniciado_en timestamp with time zone DEFAULT now(),
    finalizado_en timestamp with time zone,
    dispositivo text,
    plataforma text,
    version_app text
);


ALTER TABLE app.sesion OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17936)
-- Name: sesion_sesion_id_seq; Type: SEQUENCE; Schema: app; Owner: postgres
--

CREATE SEQUENCE app.sesion_sesion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE app.sesion_sesion_id_seq OWNER TO postgres;

--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 216
-- Name: sesion_sesion_id_seq; Type: SEQUENCE OWNED BY; Schema: app; Owner: postgres
--

ALTER SEQUENCE app.sesion_sesion_id_seq OWNED BY app.sesion.sesion_id;


--
-- TOC entry 3204 (class 2604 OID 17908)
-- Name: clase_modelo clase_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.clase_modelo ALTER COLUMN clase_id SET DEFAULT nextval('app.clase_modelo_clase_id_seq'::regclass);


--
-- TOC entry 3200 (class 2604 OID 17894)
-- Name: fruta fruta_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.fruta ALTER COLUMN fruta_id SET DEFAULT nextval('app.fruta_fruta_id_seq'::regclass);


--
-- TOC entry 3213 (class 2604 OID 17950)
-- Name: imagen imagen_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.imagen ALTER COLUMN imagen_id SET DEFAULT nextval('app.imagen_imagen_id_seq'::regclass);


--
-- TOC entry 3219 (class 2604 OID 17992)
-- Name: mercado mercado_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.mercado ALTER COLUMN mercado_id SET DEFAULT nextval('app.mercado_mercado_id_seq'::regclass);


--
-- TOC entry 3207 (class 2604 OID 17926)
-- Name: modelo modelo_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.modelo ALTER COLUMN modelo_id SET DEFAULT nextval('app.modelo_modelo_id_seq'::regclass);


--
-- TOC entry 3220 (class 2604 OID 18001)
-- Name: precio precio_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.precio ALTER COLUMN precio_id SET DEFAULT nextval('app.precio_precio_id_seq'::regclass);


--
-- TOC entry 3216 (class 2604 OID 17968)
-- Name: prediccion prediccion_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.prediccion ALTER COLUMN prediccion_id SET DEFAULT nextval('app.prediccion_prediccion_id_seq'::regclass);


--
-- TOC entry 3211 (class 2604 OID 17940)
-- Name: sesion sesion_id; Type: DEFAULT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sesion ALTER COLUMN sesion_id SET DEFAULT nextval('app.sesion_sesion_id_seq'::regclass);


--
-- TOC entry 3401 (class 0 OID 17905)
-- Dependencies: 213
-- Data for Name: clase_modelo; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.clase_modelo (clase_id, fruta_id, estado, etiqueta, creado_en) FROM stdin;
23	42	bueno	0 fresa_buena	2025-12-17 08:51:16.266225-05
6	6	medio	8 manzana_media	2025-12-17 07:53:20.202064-05
15	28	bueno	6 manzana_buena	2025-12-17 08:38:50.613991-05
2	31	bueno	3 guineo_bueno	2025-12-17 07:52:11.272985-05
9	2	daniado	4 guineo_daniado	2025-12-17 07:54:23.31681-05
17	17	medio	1 fresa_daniada	2025-12-17 08:39:27.529995-05
49	49	bueno	12 tomate_bueno	2025-12-17 09:39:20.891988-05
5	31	medio	5 guineo_medio	2025-12-17 07:53:03.260876-05
24	30	medio	10 naranja_daniada	2025-12-17 08:51:46.009612-05
21	30	bueno	9 naranja_buena	2025-12-17 08:41:10.943744-05
\.


--
-- TOC entry 3399 (class 0 OID 17891)
-- Dependencies: 211
-- Data for Name: fruta; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.fruta (fruta_id, nombre, unidad, activo, creado_en) FROM stdin;
30	Naranja	kg	t	2025-12-17 09:22:48.775208-05
42	Fresa	kg	t	2025-12-17 09:36:27.873823-05
28	Manzana	kg	t	2025-12-17 09:15:47.715113-05
2	guineo	kg	t	2025-12-17 07:52:11.272985-05
31	Guineo	kg	t	2025-12-17 09:24:37.208081-05
17	fresa	kg	t	2025-12-17 08:39:27.529995-05
21	naranja	kg	t	2025-12-17 08:41:10.943744-05
6	manzana	kg	t	2025-12-17 07:53:20.202064-05
49	Tomate	kg	t	2025-12-17 09:39:20.891988-05
\.


--
-- TOC entry 3407 (class 0 OID 17947)
-- Dependencies: 219
-- Data for Name: imagen; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.imagen (imagen_id, sesion_id, ruta_imagen, hash_sha256, formato, ancho, alto, origen, capturada_en) FROM stdin;
1	2	camara	f79f3dcdc1ccfa0371bb01f74ab480a3a796d500910acdbfd70d18fa398b07be	jpeg	1321	743	camara	2025-12-17 07:52:11.272985-05
2	2	camara	600c140fac741aa20d5cda103e29be4da36afe217dced7a5438dda40ecb6469b	jpeg	1321	743	camara	2025-12-17 07:52:29.344193-05
3	2	camara	13e8323eb670d9165922c40e85f72d75a794dd4d21cf8289526b57036a46a842	jpeg	1321	743	camara	2025-12-17 07:52:45.946877-05
4	2	camara	abef3ee115c102653d61c85c9536a0011e4249bac3bbd69f008c77168502b017	jpeg	1321	743	camara	2025-12-17 07:53:03.260876-05
5	2	camara	7c11904577a647060226cbc88703446808dbb4f3a7d8ff4891a3abc40093fd60	jpeg	1321	743	camara	2025-12-17 07:53:20.202064-05
6	2	camara	d6c9e46d16de9326bc7b5f219ef6f669cc23862fc633f49f8eb9b5aad508978f	jpeg	1321	743	camara	2025-12-17 07:53:50.914509-05
7	2	camara	f62d1021c2eca9607ac05a05fed299c8796feddad2317e055e4d4598b56eec32	jpeg	1321	743	camara	2025-12-17 07:54:07.401274-05
8	2	camara	5b552dadf3052e02ebcd4d03671fc3b0764cabccac078892778493def86a86f0	jpeg	1321	743	camara	2025-12-17 07:54:23.31681-05
9	2	camara	2131b725b4a5a558885cc2559fced90ffbe19a0d49afd2fc267abfc312e0a684	jpeg	1321	743	camara	2025-12-17 07:55:09.436791-05
10	2	camara	6d57c2455547cbc837a20eeccc70b80aca6adf6d03361bc7dc32d02a6320dea4	jpeg	1321	743	camara	2025-12-17 07:55:28.244539-05
11	2	camara	b90768fd8fdb84859b0d7c0c35bb627c72131fd6ffb29678f38d503e54b59c9f	jpeg	1321	743	camara	2025-12-17 07:55:35.461893-05
13	10	usb_cam_1.jpg	b710fdfb4ba45c975308949e4d8c092b2e0f78a695c22542d0f63818226e18d6	jpg	640	480	camara	2025-12-17 08:38:36.136073-05
14	10	usb_cam_1.jpg	cb79d57c053f7a41e28c99af9f78a058fbfc03c8669b82a95a87bce9c9416338	jpg	640	480	camara	2025-12-17 08:38:50.613991-05
15	10	usb_cam_1.jpg	6bf708097602a83f70e9006cf91f4c816bc399eb20fbd72da5583bb30078eb5b	jpg	640	480	camara	2025-12-17 08:38:55.725587-05
16	10	usb_cam_1.jpg	63bfaf66ccf4cf77c22d868402f8c7c31115175a57f816315d02a50d378c07ef	jpg	640	480	camara	2025-12-17 08:39:27.529995-05
17	10	usb_cam_1.jpg	07fa3f88672eead75b41330c6c70bb184d9dd61946d1ff2f583fcf82c6ba51bd	jpg	640	480	camara	2025-12-17 08:39:42.182591-05
18	10	usb_cam_1.jpg	60364c9e899917db262baf5de0535a4d8a8560b9ae3b8d5e6604cd6765ffde2b	jpg	640	480	camara	2025-12-17 08:39:59.973349-05
19	10	usb_cam_1.jpg	bc4dc8e80437d71cc2c024d8a1becb692aeba5436be200998f2c17d0562acc04	jpg	640	480	camara	2025-12-17 08:40:50.370305-05
20	10	usb_cam_1.jpg	fb05b8d6490463cd0c5d98c54cb75b374cd969e32f14e460d1f0f21e09174cfd	jpg	640	480	camara	2025-12-17 08:41:10.943744-05
21	13	camara.jpg	aa34164e4dee8072ee6d0d6aa8756ded9f6d9bd7aff95bc3ed0650c86972094f	jpg	1366	768	camara	2025-12-17 08:51:04.347339-05
22	13	camara.jpg	115ee86665747fa2a54d8169794e6b6d0b31c44f6d26f0bf001c001f02a8cf3d	jpg	1366	768	camara	2025-12-17 08:51:16.266225-05
23	13	camara.jpg	a8b35d25240b6c22da6db1efa49c0deb7a118332c5ef91feb23df4e06d2ce674	jpg	1366	768	camara	2025-12-17 08:51:46.009612-05
24	13	camara.jpg	565c9f1276a710ce126128f71ebf5be4efcc3b4a964d3176aa0915ebec0a59df	jpg	1366	768	camara	2025-12-17 08:55:24.547446-05
25	14	camara.jpg	b05167c54367d33c63b12a193dbced6c31eb56c619a34302f1d80329b455982f	jpg	580	326	camara	2025-12-17 08:58:49.189853-05
26	15	camara.jpg	e06b4c1735ced772a53caaa9b5fdef2a3f79f4d250e2764def4b2c6b91f8818d	jpg	580	434	camara	2025-12-17 09:03:31.421652-05
27	16	camara.jpg	069529673875b8cc115b31c2251af2b243a4f62a104f73def7249b467af420f8	jpg	589	442	camara	2025-12-17 09:15:47.715113-05
28	17	camara.jpg	f5bfb8e16e4ab6162343f277eb7f188cf147dee70bf57d6fefc2ee5ae29c9575	jpg	589	442	camara	2025-12-17 09:20:15.483217-05
29	18	camara.jpg	6a904df9512558fa70857d5f5b5508c613c6d485f4eb8ff4de4db7e4e6410bd6	jpg	589	442	camara	2025-12-17 09:22:48.775208-05
30	19	camara.jpg	d2b68c05557f8be9bfe490e7834d66396e4f33d33f345182843f380b6ae273fd	jpg	589	442	camara	2025-12-17 09:24:37.208081-05
31	20	camara.jpg	1491cdc26fad13914a8e844e2b482301386e407f30dc5165729b7088882ca15a	jpg	589	442	camara	2025-12-17 09:27:36.206846-05
32	21	camara.jpg	7fcae51f54a6914dc13d01ade9cfb394471d09eeecc21d40568154beea18eaad	jpg	738	415	camara	2025-12-17 09:31:02.893254-05
33	21	camara.jpg	545d2d2ba0ff7b7c9fb3a2de25d5bd26a015c594a814750103bf32f2568a7b2b	jpg	738	415	camara	2025-12-17 09:31:24.52692-05
34	21	camara.jpg	b04466562897a9755d51f7387487d03b3404a64f7036f936669e1579637adea8	jpg	738	415	camara	2025-12-17 09:31:35.538454-05
35	21	camara.jpg	943fa4737143f046ea09446e808a3a897716a781bbba30f7f673f41ed87b8dc9	jpg	738	415	camara	2025-12-17 09:31:47.309405-05
36	21	camara.jpg	ffb2edfbf754fa804ed8846bc635f1b2038c5d093b649dd233ee103515ef4275	jpg	738	415	camara	2025-12-17 09:32:11.894831-05
37	21	camara.jpg	6468d676fbf7abef5d008a5ae681c1a7c683ea859dd00ee8fe406215c7c01daa	jpg	738	415	camara	2025-12-17 09:32:24.616028-05
38	21	camara.jpg	8d16ddc9467ad3a525d3a61ff28014471cab6bcd1b4916fa6577687ecc289029	jpg	738	415	camara	2025-12-17 09:35:18.749552-05
39	21	camara.jpg	123e6330746f2b043a6e826fe2464301816e139e03346179790e06d67a9ae8f1	jpg	738	415	camara	2025-12-17 09:35:38.290291-05
40	21	camara.jpg	5a997f9b87cea4564581e685eb82aaf159686f9e4dc5226cca82df3f3247b741	jpg	738	415	camara	2025-12-17 09:36:27.873823-05
41	21	camara.jpg	c110b88d5a01c64e671493e75b890392ec41f2a06833af14422f7ebba8da2ef0	jpg	738	415	camara	2025-12-17 09:36:44.550572-05
42	21	camara.jpg	f6caced4bf49432745ce4d2f67aef3939b924d7dad451a6540a9d1858187d2c9	jpg	738	415	camara	2025-12-17 09:36:57.816178-05
43	21	camara.jpg	aa3d774fc3f1f119879dc33af9cf980a87d574c795371487046111a86ac0dbd9	jpg	589	442	camara	2025-12-17 09:38:07.937869-05
44	21	camara.jpg	7c68e112ce8399e957d80415de3a1786c3fc48c875cb0eb1922ed65376dfe898	jpg	589	442	camara	2025-12-17 09:38:29.171231-05
45	21	camara.jpg	abf2d1513e80e38c8e1dc64f6abf468b76e58b99e422727e79a1f297b944199f	jpg	589	442	camara	2025-12-17 09:38:43.298496-05
46	21	camara.jpg	136be5f979f031f5c6fd12b64f2c61fca13a8fa829f2ba1bdd07249c8a7eedb9	jpg	589	442	camara	2025-12-17 09:39:04.152305-05
47	21	camara.jpg	c1047ef2032b86c47df701035f166d0b269afc6d6746b502926c13c92d97b10d	jpg	589	442	camara	2025-12-17 09:39:20.891988-05
48	21	camara.jpg	0beb2e1f78abc782f629311d30e5711a230d7656408854bde8a2b7844de2f370	jpg	589	442	camara	2025-12-17 09:40:05.491054-05
49	21	camara.jpg	7705abb2473f8286f33743e1fe0cb4562bad01faf7a4622828a8d9f00d06faa7	jpg	589	442	camara	2025-12-17 09:40:12.630297-05
50	21	camara.jpg	6407d352e29319ffccd5cb951b5567a1104edd9fa402c2c396e7a5626dc44663	jpg	589	442	camara	2025-12-17 09:40:21.429004-05
51	21	camara.jpg	44449b363992ef7da2f133375a99cfb2ccdb18708acff2e8dc72973ccae80c91	jpg	589	442	camara	2025-12-17 09:40:29.671004-05
52	21	camara.jpg	b8dbe8d59904d11decdaea7a01d7b1bf89b134d2a47877746edd8d97da4115b2	jpg	589	442	camara	2025-12-17 09:40:37.689996-05
53	21	camara.jpg	d436aa1f7515db159ec31697d0811fb3dcc2e697680e140b1d0b9d45a3e4fc18	jpg	589	442	camara	2025-12-17 09:40:49.95518-05
54	21	camara.jpg	4d5f838fa22e531aba542a763a2c2adc284287af30d9f1f8d7d5b4f32cc48cbb	jpg	589	442	camara	2025-12-17 09:40:56.864172-05
55	21	camara.jpg	3ae3e2a4271645fdcc9dc9ff45f8514c5237c621d97b634b4f4f9aa51032b913	jpg	589	442	camara	2025-12-17 09:41:18.059429-05
56	21	camara.jpg	c7916f5bb84a59e138e4e4c090eaaadc9c2d4286d69f3cc2f334ca5cc4005f88	jpg	589	442	camara	2025-12-17 09:43:45.973125-05
57	21	camara.jpg	3d57cf36dc69eb04b86ceb5903ed387f663c3a94c61002a696181eca774f729d	jpg	589	442	camara	2025-12-17 09:43:56.322624-05
58	21	camara.jpg	7eba65deaa023c8ecf253b68ae0c711de501415480c1cf3265f3f0b1696c7025	jpg	589	442	camara	2025-12-17 09:44:04.691303-05
59	21	camara.jpg	8798cbcaafaadb93c68abfd99b485d09b4c1dcd66027ab577e8725e10529e5d5	jpg	589	442	camara	2025-12-17 09:44:31.482921-05
60	21	camara.jpg	3d8642b6b21db7623db8ef8785666c94e7680d2901fe9b9d8da1b2638ddc2f6b	jpg	589	442	camara	2025-12-17 09:45:11.912421-05
61	21	camara.jpg	b169b2afcbb799d0fa1d482b1a84adc853670af7d754407288530267f0ba3be4	jpg	589	442	camara	2025-12-17 09:45:26.613426-05
62	21	camara.jpg	772f24f23dfe5ee9a3f5f2c87dab6722d05741cdebec224d1d1b4beb30086f1b	jpg	589	442	camara	2025-12-17 09:45:40.597615-05
63	21	camara.jpg	b23bb7a8e08359526a4c596ed10a1bd5ba026e41dd07b048cda7fc06f957ae6b	jpg	589	442	camara	2025-12-17 09:45:56.099585-05
64	21	camara.jpg	e125226dfc347af4766bbe60cb13d502bef7ec98712e9352fdfa659654bbcff4	jpg	589	442	camara	2025-12-17 09:46:26.619378-05
65	21	camara.jpg	cce1f6302e001e194d2e1f900a2ca9c19bcfeaf2592a7e4ece55149fe39d4570	jpg	590	442	camara	2025-12-17 09:48:29.021715-05
66	21	camara.jpg	414f83a23ece269d3d4edb5d5228d1aa4611d22a694e487802afe633d1f48582	jpg	590	442	camara	2025-12-17 09:51:44.380845-05
67	21	camara.jpg	c04b452bfe4f618f8e36e83d39a1d86fa0b948ad442f8a1ab544c71968f3d1d6	jpg	590	442	camara	2025-12-17 09:51:49.766504-05
68	21	camara.jpg	c912371b6163b57ac8e1c31cfeffeada2ef2e5ba51b1bbd610b4b5b1c36f054f	jpg	590	442	camara	2025-12-17 09:52:21.02397-05
69	23	camara.jpg	fbd6b9b7257ff62c5f37aae90eb8176b0f06a8103b2334850f41b6cefa149879	jpg	590	442	camara	2026-01-06 08:33:58.180582-05
\.


--
-- TOC entry 3411 (class 0 OID 17989)
-- Dependencies: 223
-- Data for Name: mercado; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.mercado (mercado_id, nombre, ciudad, fuente) FROM stdin;
\.


--
-- TOC entry 3403 (class 0 OID 17923)
-- Dependencies: 215
-- Data for Name: modelo; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.modelo (modelo_id, nombre, version, framework, input_w, input_h, n_clases, activo, creado_en) FROM stdin;
1	TFLite-MobileNetV2	v1	TensorFlow	224	224	15	t	2025-12-17 07:52:11.272985-05
\.


--
-- TOC entry 3413 (class 0 OID 17998)
-- Dependencies: 225
-- Data for Name: precio; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.precio (precio_id, fruta_id, mercado_id, fecha, precio_kg, moneda) FROM stdin;
\.


--
-- TOC entry 3409 (class 0 OID 17965)
-- Dependencies: 221
-- Data for Name: prediccion; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.prediccion (prediccion_id, imagen_id, modelo_id, clase_id, confianza, tiempo_ms, creado_en) FROM stdin;
1	1	1	2	0.6838	4	2025-12-17 07:52:11.272985-05
2	2	1	2	0.3968	2	2025-12-17 07:52:29.344193-05
3	3	1	2	0.7633	3	2025-12-17 07:52:45.946877-05
4	4	1	5	0.9070	2	2025-12-17 07:53:03.260876-05
5	5	1	6	0.6625	2	2025-12-17 07:53:20.202064-05
6	6	1	2	0.9920	3	2025-12-17 07:53:50.914509-05
7	7	1	5	0.5168	2	2025-12-17 07:54:07.401274-05
8	8	1	9	0.3781	2	2025-12-17 07:54:23.31681-05
9	9	1	5	0.3289	1	2025-12-17 07:55:09.436791-05
10	10	1	9	0.4783	2	2025-12-17 07:55:28.244539-05
11	11	1	2	0.2365	2	2025-12-17 07:55:35.461893-05
12	13	1	2	0.4493	15	2025-12-17 08:38:36.136073-05
13	14	1	15	0.9956	8	2025-12-17 08:38:50.613991-05
14	15	1	15	0.9948	3	2025-12-17 08:38:55.725587-05
15	16	1	17	0.6465	4	2025-12-17 08:39:27.529995-05
16	17	1	15	0.9996	7	2025-12-17 08:39:42.182591-05
17	18	1	15	0.6256	2	2025-12-17 08:39:59.973349-05
18	19	1	15	0.9804	2	2025-12-17 08:40:50.370305-05
19	20	1	21	0.9579	8	2025-12-17 08:41:10.943744-05
20	21	1	15	0.9259	9	2025-12-17 08:51:04.347339-05
21	22	1	23	0.3267	1	2025-12-17 08:51:16.266225-05
22	23	1	24	0.4964	1	2025-12-17 08:51:46.009612-05
23	24	1	15	0.8867	3	2025-12-17 08:55:24.547446-05
24	25	1	15	0.9592	5	2025-12-17 08:58:49.189853-05
25	26	1	15	0.5098	4	2025-12-17 09:03:31.421652-05
26	27	1	15	0.9469	4	2025-12-17 09:15:47.715113-05
27	28	1	15	0.9599	3	2025-12-17 09:20:15.483217-05
28	29	1	24	0.4079	2	2025-12-17 09:22:48.775208-05
29	30	1	2	0.4380	3	2025-12-17 09:24:37.208081-05
30	31	1	15	0.7706	5	2025-12-17 09:27:36.206846-05
31	32	1	15	0.5476	3	2025-12-17 09:31:02.893254-05
32	33	1	15	0.7251	2	2025-12-17 09:31:24.52692-05
33	34	1	15	0.7288	3	2025-12-17 09:31:35.538454-05
34	35	1	15	0.5027	3	2025-12-17 09:31:47.309405-05
35	36	1	15	0.7500	5	2025-12-17 09:32:11.894831-05
36	37	1	2	0.6865	3	2025-12-17 09:32:24.616028-05
37	38	1	15	0.8623	2	2025-12-17 09:35:18.749552-05
38	39	1	15	0.9970	4	2025-12-17 09:35:38.290291-05
39	40	1	23	0.9374	3	2025-12-17 09:36:27.873823-05
40	41	1	23	0.6769	4	2025-12-17 09:36:44.550572-05
41	42	1	5	0.3202	4	2025-12-17 09:36:57.816178-05
42	43	1	23	0.9997	2	2025-12-17 09:38:07.937869-05
43	44	1	23	0.9775	6	2025-12-17 09:38:29.171231-05
44	45	1	23	0.9913	4	2025-12-17 09:38:43.298496-05
45	46	1	23	0.3210	2	2025-12-17 09:39:04.152305-05
46	47	1	49	0.8396	3	2025-12-17 09:39:20.891988-05
47	48	1	49	0.9443	6	2025-12-17 09:40:05.491054-05
48	49	1	23	0.7885	4	2025-12-17 09:40:12.630297-05
49	50	1	23	0.9580	3	2025-12-17 09:40:21.429004-05
50	51	1	24	0.4875	2	2025-12-17 09:40:29.671004-05
51	52	1	15	0.9698	3	2025-12-17 09:40:37.689996-05
52	53	1	15	0.6554	4	2025-12-17 09:40:49.95518-05
53	54	1	24	0.5839	3	2025-12-17 09:40:56.864172-05
54	55	1	24	0.7563	5	2025-12-17 09:41:18.059429-05
55	56	1	15	0.9808	4	2025-12-17 09:43:45.973125-05
56	57	1	15	0.7162	5	2025-12-17 09:43:56.322624-05
57	58	1	5	0.9894	3	2025-12-17 09:44:04.691303-05
58	59	1	2	0.8798	4	2025-12-17 09:44:31.482921-05
59	60	1	15	0.9762	9	2025-12-17 09:45:11.912421-05
60	61	1	23	0.6713	3	2025-12-17 09:45:26.613426-05
61	62	1	23	0.8698	5	2025-12-17 09:45:40.597615-05
62	63	1	24	0.5722	4	2025-12-17 09:45:56.099585-05
63	64	1	21	0.8376	2	2025-12-17 09:46:26.619378-05
64	65	1	15	0.9146	3	2025-12-17 09:48:29.021715-05
65	66	1	23	0.7656	3	2025-12-17 09:51:44.380845-05
66	67	1	15	0.6538	3	2025-12-17 09:51:49.766504-05
67	68	1	15	0.8089	3	2025-12-17 09:52:21.02397-05
68	69	1	2	0.6779	3	2026-01-06 08:33:58.180582-05
\.


--
-- TOC entry 3405 (class 0 OID 17937)
-- Dependencies: 217
-- Data for Name: sesion; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.sesion (sesion_id, iniciado_en, finalizado_en, dispositivo, plataforma, version_app) FROM stdin;
1	2025-12-17 07:36:55.481852-05	\N	unknown	web	1.0
2	2025-12-17 07:51:10.046237-05	\N	unknown	web	1.0
3	2025-12-17 07:59:28.867386-05	\N	unknown	web	1.0
4	2025-12-17 08:08:40.825419-05	\N	unknown	web	1.0
5	2025-12-17 08:15:37.09199-05	\N	unknown	desktop	1.0
6	2025-12-17 08:21:59.117249-05	\N	unknown	desktop	1.0
7	2025-12-17 08:28:03.842497-05	\N	unknown	desktop	1.0
8	2025-12-17 08:28:04.896298-05	\N	unknown	desktop	1.0
9	2025-12-17 08:29:24.723811-05	\N	unknown	desktop	1.0
10	2025-12-17 08:38:02.680314-05	\N	unknown	desktop	1.0
11	2025-12-17 08:47:14.393234-05	\N	unknown	web	1.0
12	2025-12-17 08:48:24.033752-05	\N	unknown	web	1.0
13	2025-12-17 08:50:21.149726-05	\N	unknown	web	1.0
14	2025-12-17 08:58:20.869089-05	\N	unknown	web	1.0
15	2025-12-17 09:03:14.226474-05	\N	unknown	web	1.0
16	2025-12-17 09:15:32.284858-05	\N	unknown	web	1.0
17	2025-12-17 09:20:00.90409-05	\N	unknown	web	1.0
18	2025-12-17 09:22:42.373836-05	\N	unknown	web	1.0
19	2025-12-17 09:24:30.504319-05	\N	unknown	web	1.0
20	2025-12-17 09:27:30.040321-05	\N	unknown	web	1.0
21	2025-12-17 09:30:53.467328-05	\N	unknown	web	1.0
22	2025-12-22 10:13:35.366445-05	\N	unknown	web	1.0
23	2026-01-06 08:33:29.12105-05	\N	unknown	web	1.0
24	2026-01-06 08:44:32.551639-05	\N	web	streamlit	1.0
25	2026-01-06 08:46:03.609705-05	\N	web	streamlit	1.0
26	2026-01-06 08:46:18.378395-05	\N	web	streamlit	1.0
27	2026-01-06 08:46:41.172114-05	\N	web	streamlit	1.0
28	2026-01-06 08:47:28.170852-05	\N	web	streamlit	1.0
29	2026-01-06 08:47:44.435513-05	\N	web	streamlit	1.0
30	2026-01-06 08:48:10.352354-05	\N	web	streamlit	1.0
31	2026-01-06 08:48:31.575167-05	\N	web	streamlit	1.0
32	2026-01-06 08:48:52.108694-05	\N	web	streamlit	1.0
33	2026-01-06 08:49:09.909085-05	\N	web	streamlit	1.0
34	2026-01-06 08:49:37.582105-05	\N	web	streamlit	1.0
35	2026-01-06 08:50:17.458805-05	\N	web	streamlit	1.0
36	2026-01-06 08:51:13.414736-05	\N	web	streamlit	1.0
37	2026-01-06 08:51:31.755488-05	\N	web	streamlit	1.0
38	2026-01-06 08:52:26.854563-05	\N	web	streamlit	1.0
39	2026-01-06 08:55:47.984337-05	\N	web	streamlit	1.0
40	2026-01-06 08:56:27.716591-05	\N	web	streamlit	1.0
41	2026-01-06 08:57:52.984346-05	\N	web	streamlit	1.0
\.


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 212
-- Name: clase_modelo_clase_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.clase_modelo_clase_id_seq', 73, true);


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 210
-- Name: fruta_fruta_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.fruta_fruta_id_seq', 73, true);


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 218
-- Name: imagen_imagen_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.imagen_imagen_id_seq', 69, true);


--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 222
-- Name: mercado_mercado_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.mercado_mercado_id_seq', 1, false);


--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 214
-- Name: modelo_modelo_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.modelo_modelo_id_seq', 69, true);


--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 224
-- Name: precio_precio_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.precio_precio_id_seq', 1, false);


--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 220
-- Name: prediccion_prediccion_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.prediccion_prediccion_id_seq', 68, true);


--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 216
-- Name: sesion_sesion_id_seq; Type: SEQUENCE SET; Schema: app; Owner: postgres
--

SELECT pg_catalog.setval('app.sesion_sesion_id_seq', 41, true);


--
-- TOC entry 3227 (class 2606 OID 17916)
-- Name: clase_modelo clase_modelo_etiqueta_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.clase_modelo
    ADD CONSTRAINT clase_modelo_etiqueta_key UNIQUE (etiqueta);


--
-- TOC entry 3229 (class 2606 OID 17914)
-- Name: clase_modelo clase_modelo_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.clase_modelo
    ADD CONSTRAINT clase_modelo_pkey PRIMARY KEY (clase_id);


--
-- TOC entry 3223 (class 2606 OID 17903)
-- Name: fruta fruta_nombre_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.fruta
    ADD CONSTRAINT fruta_nombre_key UNIQUE (nombre);


--
-- TOC entry 3225 (class 2606 OID 17901)
-- Name: fruta fruta_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.fruta
    ADD CONSTRAINT fruta_pkey PRIMARY KEY (fruta_id);


--
-- TOC entry 3238 (class 2606 OID 17958)
-- Name: imagen imagen_hash_sha256_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.imagen
    ADD CONSTRAINT imagen_hash_sha256_key UNIQUE (hash_sha256);


--
-- TOC entry 3240 (class 2606 OID 17956)
-- Name: imagen imagen_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.imagen
    ADD CONSTRAINT imagen_pkey PRIMARY KEY (imagen_id);


--
-- TOC entry 3246 (class 2606 OID 17996)
-- Name: mercado mercado_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.mercado
    ADD CONSTRAINT mercado_pkey PRIMARY KEY (mercado_id);


--
-- TOC entry 3231 (class 2606 OID 17935)
-- Name: modelo modelo_nombre_version_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.modelo
    ADD CONSTRAINT modelo_nombre_version_key UNIQUE (nombre, version);


--
-- TOC entry 3233 (class 2606 OID 17933)
-- Name: modelo modelo_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.modelo
    ADD CONSTRAINT modelo_pkey PRIMARY KEY (modelo_id);


--
-- TOC entry 3249 (class 2606 OID 18008)
-- Name: precio precio_fruta_id_mercado_id_fecha_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.precio
    ADD CONSTRAINT precio_fruta_id_mercado_id_fecha_key UNIQUE (fruta_id, mercado_id, fecha);


--
-- TOC entry 3251 (class 2606 OID 18006)
-- Name: precio precio_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.precio
    ADD CONSTRAINT precio_pkey PRIMARY KEY (precio_id);


--
-- TOC entry 3244 (class 2606 OID 17972)
-- Name: prediccion prediccion_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.prediccion
    ADD CONSTRAINT prediccion_pkey PRIMARY KEY (prediccion_id);


--
-- TOC entry 3235 (class 2606 OID 17945)
-- Name: sesion sesion_pkey; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.sesion
    ADD CONSTRAINT sesion_pkey PRIMARY KEY (sesion_id);


--
-- TOC entry 3236 (class 1259 OID 18021)
-- Name: idx_imagen_fecha; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_imagen_fecha ON app.imagen USING btree (capturada_en);


--
-- TOC entry 3247 (class 1259 OID 18022)
-- Name: idx_precio_fecha; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_precio_fecha ON app.precio USING btree (fecha);


--
-- TOC entry 3241 (class 1259 OID 18020)
-- Name: idx_prediccion_clase; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_prediccion_clase ON app.prediccion USING btree (clase_id);


--
-- TOC entry 3242 (class 1259 OID 18019)
-- Name: idx_prediccion_fecha; Type: INDEX; Schema: app; Owner: postgres
--

CREATE INDEX idx_prediccion_fecha ON app.prediccion USING btree (creado_en);


--
-- TOC entry 3252 (class 2606 OID 17917)
-- Name: clase_modelo clase_modelo_fruta_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.clase_modelo
    ADD CONSTRAINT clase_modelo_fruta_id_fkey FOREIGN KEY (fruta_id) REFERENCES app.fruta(fruta_id);


--
-- TOC entry 3253 (class 2606 OID 17959)
-- Name: imagen imagen_sesion_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.imagen
    ADD CONSTRAINT imagen_sesion_id_fkey FOREIGN KEY (sesion_id) REFERENCES app.sesion(sesion_id);


--
-- TOC entry 3257 (class 2606 OID 18009)
-- Name: precio precio_fruta_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.precio
    ADD CONSTRAINT precio_fruta_id_fkey FOREIGN KEY (fruta_id) REFERENCES app.fruta(fruta_id);


--
-- TOC entry 3258 (class 2606 OID 18014)
-- Name: precio precio_mercado_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.precio
    ADD CONSTRAINT precio_mercado_id_fkey FOREIGN KEY (mercado_id) REFERENCES app.mercado(mercado_id);


--
-- TOC entry 3256 (class 2606 OID 17983)
-- Name: prediccion prediccion_clase_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.prediccion
    ADD CONSTRAINT prediccion_clase_id_fkey FOREIGN KEY (clase_id) REFERENCES app.clase_modelo(clase_id);


--
-- TOC entry 3254 (class 2606 OID 17973)
-- Name: prediccion prediccion_imagen_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.prediccion
    ADD CONSTRAINT prediccion_imagen_id_fkey FOREIGN KEY (imagen_id) REFERENCES app.imagen(imagen_id);


--
-- TOC entry 3255 (class 2606 OID 17978)
-- Name: prediccion prediccion_modelo_id_fkey; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.prediccion
    ADD CONSTRAINT prediccion_modelo_id_fkey FOREIGN KEY (modelo_id) REFERENCES app.modelo(modelo_id);


-- Completed on 2026-01-06 10:19:34

--
-- PostgreSQL database dump complete
--

