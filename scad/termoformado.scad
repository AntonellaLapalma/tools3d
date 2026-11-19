/*
    MOLDE DE TERMOFORMADO EN TRES PIEZAS + TAPON + TRABA (por ahora con forma de cubo)

    Macho    : placa (reborde) con esquinas redondeadas + cuerpo con la forma de la cesta. Va entero.
    Hembra   : solo el marco. Hueco = contorno de la placa del macho + holgura. Lleva una canaleta
               en la cara superior y una muesca semicircular en el centro superior por donde sale la rosca.
    Pieza 3  : lamina del medio. Borde elevado que entra en la canaleta (interrumpido en el tramo del
               hueco), hueco pequeno DENTRO de la banda del borde (abajo), y media rosca arriba que
               arranca DESPUES del borde, apoyada sobre una base.
    Tapon    : cuerpo estriado con asa arriba y rosca interna (hueco) abajo, donde entra la rosca.
    Traba    : clip en C. Su altura es igual al ancho del hueco de la pieza 3 (hueco_pw).

    Todo el interior sale de UN solo contorno (contorno_placa): la placa del macho, el hueco de la
    hembra, la canaleta y la pieza 3 se derivan de el, asi que difieren solo por las holguras.

    Macho y hembra estan centrados en X e Y y apoyados en Z = 0, asi que quedan encastrados tal como
    se exportan. La pieza 3 se exporta lista para imprimir (borde y rosca hacia arriba); para usarla
    se da vuelta sobre el marco. El tapon se imprime con la boca (rosca) hacia abajo.
*/

/* [Cuerpo - forma de la cesta] */

// Ancho (X)
ancho = 60;

// Largo (Y)
largo = 60;

// Alto del cuerpo, sin contar la placa
alto = 25;

// Radio de las aristas del cuerpo
radio_cuerpo = 6;

// Inclinacion de las paredes, en grados (ayuda a desmoldar)
inclinacion = 5;


/* [Encastre - placa del macho] */

// Ancho de la placa alrededor del cuerpo
pestana = 10;

// Espesor de la placa
espesor_placa = 3;

// Radio de las esquinas de la placa (y del hueco del marco)
radio_esquina = 8;

// Redondeo del borde inferior de la placa (facilita encastrar)
bisel = 0.8;

// Espacio entre la placa y el marco (a cada lado)
holgura = 1.5;


/* [Marco - hembra] */

// Ancho del borde del marco
pared = 9;

// Alto del marco
alto_marco = 8;


/* [Canaleta de la hembra] */

// Distancia entre el hueco y la canaleta
canal_dist = 2;

// Ancho de la canaleta
canal_ancho = 3;

// Profundidad de la canaleta
canal_prof = 3;


/* [Rosca - compartida por hembra, pieza 3 y tapon] */

// Diametro exterior de la rosca (la muesca de la hembra y el tapon usan este mismo valor)
diam_rosca = 8;

// Paso de la rosca
paso_rosca = 2;

// Cuanto sobresale la rosca del marco
saliente_rosca = 8;

// Holgura de la muesca de la hembra respecto de la rosca
holgura_rosca = 0.5;


/* [Pieza 3 - lamina del medio] */

// Espesor de la lamina
espesor_lam = 1.2;

// Alto del borde que sobresale de la lamina
alto_borde = 2.5;

// Holgura del borde dentro de la canaleta (a cada lado)
holgura_canal = 0.3;

// Hueco pequeno de abajo: ancho (tambien es el alto de la traba)
hueco_pw = 8;

// Hueco pequeno de abajo: alto (tiene que entrar dentro de la banda del borde)
hueco_ph = 2;


/* [Tapon] */

// Espesor de pared del tapon alrededor de la rosca
tapon_pared = 6;

// Profundidad de la rosca interna (hueco)
prof_tapon = 9;

// Espesor del techo del tapon (sobre el fondo de la rosca)
tapon_techo = 3;

// Holgura de la rosca interna respecto de la rosca de la pieza 3
holgura_tapon = 0.4;

// Cantidad de estrias del agarre
tapon_estrias = 10;

// Radio de cada estria
estria_r = 1.2;

// Asa: ancho
asa_w = 14;

// Asa: alto sobre el tapon
asa_h = 13;

// Asa: grosor de la barra
asa_barra = 3;

// Asa: espesor (profundidad)
asa_esp = 4;


/* [Traba - clip de abajo] */

// Ancho exterior (X)
traba_w = 16;

// Profundidad exterior (Y)
traba_d = 14;

// Abertura de la ranura frontal
traba_ranura = 7;

// Juego de la pared de la traba dentro del hueco de la pieza 3
traba_juego = 0.4;


/* [Visualizacion] */

// Pieza a exportar
parte = "Macho"; // [Macho, Hembra, Pieza3, Tapon, Traba]


/* =========================
   MEDIDAS
========================= */

placa_w = ancho + 2 * pestana;
placa_d = largo + 2 * pestana;
hueco_w = placa_w + 2 * holgura;
hueco_d = placa_d + 2 * holgura;
radio_hueco = radio_esquina + holgura;

// Pieza 3: su contorno llega hasta la canaleta, menos la holgura
o_out = canal_dist + canal_ancho - holgura_canal;
pl_w = hueco_w + 2 * o_out;
pl_d = hueco_d + 2 * o_out;
esp_borde = canal_ancho - 2 * holgura_canal;

// Borde exterior de la pieza 3 en el eje Y (donde empieza la rosca)
y_ext = pl_d / 2;

// La rosca sale por el centro superior (+Y). Empieza justo despues del borde
y_rosca0 = y_ext - 0.01;
y_rosca1 = hueco_d / 2 + pared + saliente_rosca;
largo_rosca = y_rosca1 - y_rosca0;

// Hueco pequeno: centrado en la banda del borde, en el centro inferior (-Y)
y_hueco = -(y_ext - esp_borde / 2);

// Traba
traba_alto = hueco_pw;
traba_pared = hueco_ph - traba_juego;

// Tapon
tapon_d = diam_rosca + 2 * tapon_pared;
tapon_h = prof_tapon + tapon_techo;


/* =========================
   CONTORNOS 2D (una sola fuente)
========================= */

// Rectangulo redondeado centrado
module rr(w, d, r) {
    r2 = max(0.01, min(r, min(w, d) / 2 - 0.01));
    offset(r = r2, $fn = 48) square([w - 2 * r2, d - 2 * r2], center = true);
}

// Contorno de la placa del macho. Todo lo demas se deriva de aca.
module contorno_placa() { rr(placa_w, placa_d, radio_esquina); }

// Hueco de la hembra = placa + holgura
module contorno_hueco() { offset(r = holgura, $fn = 48) contorno_placa(); }

// Contorno exterior de la pieza 3 = hueco + o_out
module contorno_pl() { offset(r = o_out, $fn = 48) contorno_hueco(); }


/* =========================
   GEOMETRIA
========================= */

// ---------- Macho ----------
module placa() {
    hull() {
        linear_extrude(height = 0.01)
            offset(delta = -bisel) contorno_placa();
        translate([0, 0, bisel])
            linear_extrude(height = espesor_placa - bisel)
                contorno_placa();
    }
}

module cuerpo() {
    rc = max(0.5, min(radio_cuerpo, alto, ancho / 2 - 0.5, largo / 2 - 0.5));
    d = max(0, min(alto * tan(inclinacion), ancho / 2 - rc - 0.5, largo / 2 - rc - 0.5));
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (ancho / 2 - rc), sy * (largo / 2 - rc), 0])
                cylinder(r = rc, h = 0.01, $fn = 32);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (ancho / 2 - rc - d), sy * (largo / 2 - rc - d), alto - rc])
                sphere(r = rc, $fn = 32);
    }
}

module macho() {
    union() {
        placa();
        translate([0, 0, espesor_placa - 0.01]) cuerpo();
    }
}

// ---------- Hembra ----------
// Canaleta: anillo hundido en la cara superior, alrededor del hueco
module canaleta() {
    translate([0, 0, alto_marco - canal_prof])
        linear_extrude(height = canal_prof + 1)
            difference() {
                offset(r = canal_dist + canal_ancho, $fn = 48) contorno_hueco();
                offset(r = canal_dist, $fn = 48) contorno_hueco();
            }
}

// Muesca semicircular en el centro superior: por aca sale la rosca de la pieza 3
module muesca_rosca() {
    translate([0, hueco_d / 2 - 1, alto_marco])
        rotate([-90, 0, 0])
            cylinder(r = (diam_rosca + holgura_rosca) / 2, h = pared + 2 + 1, $fn = 40);
}

module hembra() {
    difference() {
        linear_extrude(height = alto_marco)
            offset(r = pared, $fn = 48) contorno_hueco();
        translate([0, 0, -1])
            linear_extrude(height = alto_marco + 2)
                contorno_hueco();
        canaleta();
        muesca_rosca();
    }
}

// ---------- Rosca ----------
// Rosca helicoidal derecha a lo largo de +Z (macho)
module rosca_z(L, d_ext, paso) {
    r = d_ext / 2;
    prof = min(1.2, paso * 0.6);
    w = paso * 0.5;
    union() {
        cylinder(r = r - prof, h = L, $fn = 40);
        linear_extrude(height = L, twist = -360 * L / paso, slices = ceil(L / paso * 16), convexity = 10)
            polygon([[r - prof - 0.2, -w / 2], [r, -w * 0.12], [r, w * 0.12], [r - prof - 0.2, w / 2]]);
    }
}

// Mismo perfil que rosca_z pero agrandado "h" en todas direcciones: es el hueco para el tapon
module rosca_hueco(L, d_ext, paso, h) {
    r = d_ext / 2;
    prof = min(1.2, paso * 0.6);
    w = paso * 0.5;
    rc = r - prof;
    union() {
        cylinder(r = rc + h, h = L, $fn = 48);
        linear_extrude(height = L, twist = -360 * L / paso, slices = ceil(L / paso * 16), convexity = 10)
            polygon([[rc - 0.2, -(w / 2 + h)], [r + h, -(w * 0.12 + h)],
                     [r + h, w * 0.12 + h], [rc - 0.2, w / 2 + h]]);
    }
}

// Media rosca (la mitad superior), con el eje en Y y el plano plano en Z = espesor_lam
module media_rosca() {
    translate([0, y_rosca0, espesor_lam])
        rotate([-90, 0, 0])
            intersection() {
                rosca_z(largo_rosca, diam_rosca, paso_rosca);
                translate([-diam_rosca, -diam_rosca, -1])
                    cube([2 * diam_rosca, diam_rosca, largo_rosca + 2]);
            }
}

// ---------- Pieza 3 ----------
module pieza3() {
    union() {
        // lamina con el hueco pequeno, dentro de la banda del borde
        linear_extrude(height = espesor_lam, convexity = 10)
            difference() {
                contorno_pl();
                translate([0, y_hueco]) square([hueco_pw, hueco_ph], center = true);
            }
        // borde elevado a lo largo del contorno, SIN borde en el tramo del hueco
        linear_extrude(height = espesor_lam + alto_borde, convexity = 10)
            difference() {
                contorno_pl();
                offset(delta = -esp_borde) contorno_pl();
                translate([0, y_hueco]) square([hueco_pw, esp_borde + 2], center = true);
            }
        // base bajo la rosca: arranca dentro de la lamina y llega hasta el final de la rosca
        translate([-diam_rosca / 2, y_ext - 1, 0])
            cube([diam_rosca, y_rosca1 - (y_ext - 1), espesor_lam]);
        // media rosca: empieza despues del borde, apoyada en la base
        media_rosca();
    }
}

// ---------- Tapon ----------
// Perfil de arco 2D: base plana en y = 0, cupula redonda arriba
module arco(w, h) {
    hull() {
        translate([-w / 2, 0]) square([w, 0.01]);
        translate([0, h - w / 2]) circle(d = w, $fn = 48);
    }
}

module asa() {
    emb = 0.5;   // cuanto se hunde en el techo del tapon
    translate([0, asa_esp / 2, tapon_h - emb])
        rotate([90, 0, 0])
            linear_extrude(height = asa_esp, convexity = 10)
                difference() {
                    arco(asa_w, asa_h);
                    translate([0, emb]) arco(asa_w - 2 * asa_barra, asa_h - asa_barra - emb);
                }
}

module tapon() {
    r = diam_rosca / 2;
    union() {
        difference() {
            // cuerpo con el borde superior achaflanado
            hull() {
                cylinder(d = tapon_d, h = tapon_h - 1.2, $fn = 64);
                translate([0, 0, tapon_h - 1.2])
                    cylinder(d = tapon_d - 2.4, h = 1.2, $fn = 64);
            }
            // estrias de agarre
            for (i = [0 : tapon_estrias - 1])
                rotate([0, 0, i * 360 / tapon_estrias])
                    translate([tapon_d / 2 + 0.3, 0, -1])
                        cylinder(r = estria_r, h = tapon_h - 1.2 + 1, $fn = 24);
            // rosca interna (hueco) abajo
            translate([0, 0, -0.01]) rosca_hueco(prof_tapon + 0.01, diam_rosca, paso_rosca, holgura_tapon);
            // entrada avellanada
            translate([0, 0, -0.01])
                cylinder(r1 = r + holgura_tapon + 0.8, r2 = r + holgura_tapon, h = 0.8, $fn = 48);
        }
        asa();
    }
}

// ---------- Traba ----------
// Clip en C: la pared pasa por el hueco de la pieza 3 y su altura es igual al ancho del hueco
module traba() {
    linear_extrude(height = traba_alto, convexity = 10)
        union() {
            difference() {
                rr(traba_w, traba_d, 3);
                rr(traba_w - 2 * traba_pared, traba_d - 2 * traba_pared, 1.5);
                translate([0, traba_d / 2 - traba_pared / 2])
                    square([traba_ranura, traba_pared + 1], center = true);
            }
            // labios que retienen en los bordes de la ranura
            for (s = [-1, 1])
                translate([s * traba_ranura / 2, traba_d / 2 - traba_pared])
                    circle(r = 0.7, $fn = 24);
        }
}


/* =========================
   RESULTADO
========================= */

if (parte == "Macho") macho();
if (parte == "Hembra") hembra();
if (parte == "Pieza3") pieza3();
if (parte == "Tapon") tapon();
if (parte == "Traba") traba();
