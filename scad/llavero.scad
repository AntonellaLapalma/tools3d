/*
    LLAVERO PARAMETRICO CON NOMBRE

    Fondo: silueta, rectangulo, redondeado, pildora, ovalo o sin fondo
    Letras: relieve, incrustadas o grabadas
    Borde de las letras (independiente): redondeado, recto, biselado o sombra
    Extras: marco perimetral y arandela en distintas posiciones
*/

/* [Texto] */

// Nombre del llavero
nombre = "Texto";

// Fuente: reemplazar por el nombre exacto de tu fuente
fuente = "Argentina 2026 GOMBOFONTS";

// Altura aproximada de las letras
tamano = 20;

// Espaciado entre caracteres
espaciado = 1.0;


/* [Fondo] */

// Forma del fondo
forma_fondo = "Silueta"; // [Silueta, Rectangulo, Redondeado, Pildora, Ovalo, Ninguno]

// Margen entre las letras y el borde del fondo
margen = 2.5;

// Altura de la base
altura_base = 2.5;

// Silueta: suavizado (0 = sin suavizar; rellena huecos chicos)
suavizado = 0;

// Redondeado: radio de las esquinas
radio_esquinas = 4;


/* [Letras] */

// Estilo de las letras (con "Ninguno" de fondo siempre son Relieve)
estilo_texto = "Relieve"; // [Relieve, Incrustado, Grabado]

// Altura de las letras sobre la base (Relieve)
altura_relieve = 1.5;

// Incrustado y Grabado: profundidad dentro de la base
profundidad = 1.0;

// Borde de las letras, a la misma altura que ellas (no aplica a Grabado)
estilo_borde = "Ninguno"; // [Ninguno, Redondeado, Recto, Biselado, Sombra]

// Grosor del borde
grosor_borde = 1.2;


/* [Marco] */

// Grosor del marco perimetral (0 = sin marco)
marco_grosor = 0;

// Altura del marco sobre la base
marco_altura = 1.0;


/* [Arandela] */

// Posicion de la arandela
lado_arandela = "Manual"; // [Manual, Izquierda, Derecha, Arriba, Sin]

// Radio exterior
radio_exterior = 4;

// Radio del agujero
radio_interior = 1.5;

// Manual: posicion horizontal respecto al inicio del texto
posicion_x = -3;

// Manual: posicion vertical respecto a la linea base
posicion_y = 3;


/* [Colores - Vista previa] */

color_base = "#303030";
color_texto = "#FFFFFF";
color_borde = "#000000";


/* [Visualizacion] */

// Seleccionar parte para exportar
parte = "Completo"; // [Completo, Base, Nombre, Borde]


/* [Hidden] */

// Caja de las letras [x_min, y_min, x_max, y_max]. La pagina web la mide sola.
// En OpenSCAD de escritorio queda en 0 y se estima a partir del largo del nombre.
caja = [0, 0, 0, 0];


/* =========================
   MEDIDAS
========================= */

tiene_caja = (caja[2] - caja[0]) > 0;
x0 = tiene_caja ? caja[0] : 0;
y0 = tiene_caja ? caja[1] : 0;
x1 = tiene_caja ? caja[2] : len(nombre) * tamano * 0.62;
y1 = tiene_caja ? caja[3] : tamano;
ancho_t = x1 - x0;
alto_t = y1 - y0;

sin_fondo = forma_fondo == "Ninguno";
estilo_ef = sin_fondo ? "Relieve" : estilo_texto;
con_borde = estilo_borde != "Ninguno" && estilo_ef != "Grabado";

// Margen efectivo: con borde, el fondo sobresale el contorno de las letras ademas del margen
m = margen + (con_borde ? grosor_borde : 0);
// Para ubicar la arandela: sin fondo solo cuenta el borde
m_pos = sin_fondo ? (con_borde ? grosor_borde : 0) : m;

con_arandela = lado_arandela != "Sin";

function centro_arandela() =
    lado_arandela == "Izquierda" ? [x0 - m_pos - 0.25 * radio_exterior, y0 + alto_t / 2] :
    lado_arandela == "Derecha"   ? [x1 + m_pos + 0.25 * radio_exterior, y0 + alto_t / 2] :
    lado_arandela == "Arriba"    ? [x0 + ancho_t / 2, y1 + m_pos + 0.25 * radio_exterior] :
                                   [posicion_x, posicion_y];


/* =========================
   GEOMETRIA 2D
========================= */

// Texto original
module texto_2d() {
    text(
        text = nombre,
        size = tamano,
        font = fuente,
        spacing = espaciado,
        halign = "left",
        valign = "baseline",
        $fn = 64
    );
}

// Rectangulo que encierra las letras
module caja_2d() {
    if (tiene_caja) {
        translate([x0, y0]) square([ancho_t, alto_t]);
    } else {
        L = 1000;
        intersection() {
            hull() { translate([0, L]) texto_2d(); translate([0, -L]) texto_2d(); }
            hull() { translate([L, 0]) texto_2d(); translate([-L, 0]) texto_2d(); }
        }
    }
}

// Contorno que sigue la forma de las letras
module contorno_silueta() {
    offset(r = m, $fn = 48) texto_2d();
}

module silueta_2d() {
    if (suavizado > 0)
        offset(r = -suavizado, $fn = 48)
            offset(r = suavizado, $fn = 48)
                contorno_silueta();
    else
        contorno_silueta();
}

module rectangulo_2d() {
    offset(delta = m) caja_2d();
}

module redondeado_2d(radio) {
    offset(r = radio, $fn = 48)
        offset(delta = -radio)
            rectangulo_2d();
}

// Fondo sin arandela
module fondo_2d() {
    alto_fondo = alto_t + 2 * m;
    if (forma_fondo == "Rectangulo")
        rectangulo_2d();
    else if (forma_fondo == "Redondeado")
        redondeado_2d(min(radio_esquinas, alto_fondo / 2 - 0.01));
    else if (forma_fondo == "Pildora")
        redondeado_2d(alto_fondo / 2 - 0.01);
    else if (forma_fondo == "Ovalo")
        translate([x0 + ancho_t / 2, y0 + alto_t / 2])
            scale([(ancho_t / 2 + m) * 1.4142, (alto_t / 2 + m) * 1.4142])
                circle(r = 1, $fn = 128);
    else
        silueta_2d();
}

// Arandela: disco exterior y agujero
module anillo_ext_2d() { translate(centro_arandela()) circle(r = radio_exterior, $fn = 96); }
module agujero_2d() { translate(centro_arandela()) circle(r = radio_interior, $fn = 96); }

// Fondo con arandela y agujero
module base_2d() {
    difference() {
        union() {
            fondo_2d();
            if (con_arandela) anillo_ext_2d();
        }
        if (con_arandela) agujero_2d();
    }
}

// Marco perimetral
module marco_2d() {
    difference() {
        base_2d();
        offset(delta = -marco_grosor) base_2d();
    }
}

// Sombra: copias de las letras corridas hacia abajo y a la derecha
module sombra_2d() {
    pasos = ceil(grosor_borde / 0.4);
    for (i = [0 : pasos])
        translate([grosor_borde * i / pasos, -grosor_borde * i / pasos]) texto_2d();
}

// Borde de las letras segun el estilo elegido (solo la franja, sin las letras)
module borde_2d() {
    difference() {
        union() {
            if (estilo_borde == "Redondeado") offset(r = grosor_borde, $fn = 32) texto_2d();
            else if (estilo_borde == "Recto") offset(delta = grosor_borde) texto_2d();
            else if (estilo_borde == "Biselado") offset(delta = grosor_borde, chamfer = true) texto_2d();
            else if (estilo_borde == "Sombra") sombra_2d();
        }
        texto_2d();
    }
}

// Letras mas su borde
module zona_letras_2d() {
    if (con_borde) { texto_2d(); borde_2d(); }
    else texto_2d();
}


/* =========================
   MODELO 3D
========================= */

// Altura y nivel de las letras: sin fondo parten desde la mesa y tienen el espesor de una base mas el relieve
z_letras = sin_fondo ? 0 : altura_base;
h_letras = sin_fondo ? altura_base + altura_relieve : altura_relieve;

// Sin fondo, el agujero de la arandela tambien atraviesa las letras y el borde
module sin_agujero() {
    if (sin_fondo && con_arandela)
        difference() {
            children();
            translate([0, 0, -1])
                linear_extrude(height = altura_base + altura_relieve + 2) agujero_2d();
        }
    else children();
}

module base_3d() {
    color(color_base)
    difference() {
        union() {
            if (!sin_fondo) {
                linear_extrude(height = altura_base, convexity = 10) base_2d();
                if (marco_grosor > 0)
                    translate([0, 0, altura_base])
                        linear_extrude(height = marco_altura, convexity = 10) marco_2d();
            } else if (con_arandela) {
                linear_extrude(height = altura_base, convexity = 10)
                    difference() { anillo_ext_2d(); agujero_2d(); }
            }
        }
        if (estilo_ef == "Incrustado")
            translate([0, 0, altura_base - profundidad])
                linear_extrude(height = profundidad + 0.01, convexity = 10) zona_letras_2d();
        else if (estilo_ef == "Grabado")
            translate([0, 0, altura_base - profundidad])
                linear_extrude(height = profundidad + 0.01, convexity = 10) texto_2d();
    }
}

module nombre_3d() {
    sin_agujero() {
        if (estilo_ef == "Relieve") {
            color(color_texto)
            translate([0, 0, z_letras])
                linear_extrude(height = h_letras, convexity = 10) texto_2d();
        } else if (estilo_ef == "Incrustado") {
            color(color_texto)
            translate([0, 0, altura_base - profundidad])
                linear_extrude(height = profundidad, convexity = 10) texto_2d();
        }
    }
}

module borde_3d() {
    if (con_borde) {
        sin_agujero() {
            if (estilo_ef == "Incrustado") {
                color(color_borde)
                translate([0, 0, altura_base - profundidad])
                    linear_extrude(height = profundidad, convexity = 10) borde_2d();
            } else {
                color(color_borde)
                translate([0, 0, z_letras])
                    linear_extrude(height = h_letras, convexity = 10) borde_2d();
            }
        }
    }
}


/* =========================
   RESULTADO
========================= */

if (parte == "Completo") {
    base_3d();
    nombre_3d();
    borde_3d();
}

if (parte == "Base") {
    base_3d();
}

if (parte == "Nombre") {
    nombre_3d();
}

if (parte == "Borde") {
    borde_3d();
}

// Uso interno de la pagina web: mide las letras
if (parte == "Medida") {
    linear_extrude(height = 0.2) texto_2d();
}
