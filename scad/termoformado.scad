/*
    MOLDE DE TERMOFORMADO EN TRES PIEZAS (por ahora con forma de cubo)

    Macho    : placa (reborde) con esquinas redondeadas + cuerpo con la forma de la cesta. Va entero.
    Hembra   : solo el marco. Hueco = placa del macho + holgura. Lleva una canaleta en la cara superior
               y una muesca semicircular en el centro superior por donde sale la rosca de la pieza 3.
    Pieza 3  : lamina del medio. Borde elevado que entra en la canaleta, media rosca arriba
               (entra en la muesca de la hembra) y un hueco pequeno abajo.

    La rosca (diam_rosca) es un valor compartido: la muesca de la hembra y la media rosca de la pieza 3
    usan el mismo diametro.

    Macho y hembra estan centrados en X e Y y apoyados en Z = 0, asi que quedan encastrados tal como
    se exportan. La pieza 3 se exporta lista para imprimir (borde y rosca hacia arriba); para usarla
    se da vuelta sobre el marco.
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

// Espacio entre la placa y el marco
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


/* [Rosca - compartida por hembra y pieza 3] */

// Diametro exterior de la rosca (la muesca de la hembra usa este mismo valor)
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

// Hueco pequeno de abajo: ancho
hueco_pw = 8;

// Hueco pequeno de abajo: alto
hueco_ph = 2;


/* [Visualizacion] */

// Pieza a exportar
parte = "Macho"; // [Macho, Hembra, Pieza3]


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
r_pl = radio_hueco + o_out;
esp_borde = canal_ancho - 2 * holgura_canal;

// La rosca sale por el centro superior (+Y), hasta pasar el borde del marco
y_rosca0 = pl_d / 2 - esp_borde - 0.5;
y_rosca1 = hueco_d / 2 + pared + saliente_rosca;
largo_rosca = y_rosca1 - y_rosca0;


/* =========================
   GEOMETRIA
========================= */

// Rectangulo redondeado centrado
module rr(w, d, r) {
    r2 = max(0.01, min(r, min(w, d) / 2 - 0.01));
    offset(r = r2, $fn = 48) square([w - 2 * r2, d - 2 * r2], center = true);
}

// ---------- Macho ----------
module placa() {
    hull() {
        linear_extrude(height = 0.01)
            rr(placa_w - 2 * bisel, placa_d - 2 * bisel, radio_esquina - bisel);
        translate([0, 0, bisel])
            linear_extrude(height = espesor_placa - bisel)
                rr(placa_w, placa_d, radio_esquina);
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
                rr(hueco_w + 2 * (canal_dist + canal_ancho), hueco_d + 2 * (canal_dist + canal_ancho),
                   radio_hueco + canal_dist + canal_ancho);
                rr(hueco_w + 2 * canal_dist, hueco_d + 2 * canal_dist, radio_hueco + canal_dist);
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
            rr(hueco_w + 2 * pared, hueco_d + 2 * pared, radio_hueco + pared);
        translate([0, 0, -1])
            linear_extrude(height = alto_marco + 2)
                rr(hueco_w, hueco_d, radio_hueco);
        canaleta();
        muesca_rosca();
    }
}

// ---------- Pieza 3 ----------
// Rosca helicoidal derecha a lo largo de +Z
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

module pieza3() {
    union() {
        // lamina con el hueco pequeno de abajo
        linear_extrude(height = espesor_lam, convexity = 10)
            difference() {
                rr(pl_w, pl_d, r_pl);
                translate([0, -(pl_d / 2 - esp_borde - 1 - hueco_ph / 2)])
                    square([hueco_pw, hueco_ph], center = true);
            }
        // borde elevado, a lo largo del contorno
        linear_extrude(height = espesor_lam + alto_borde, convexity = 10)
            difference() {
                rr(pl_w, pl_d, r_pl);
                rr(pl_w - 2 * esp_borde, pl_d - 2 * esp_borde, r_pl - esp_borde);
            }
        // lengueta bajo la rosca (queda apoyada en la cama de impresion)
        translate([-diam_rosca / 2, y_rosca0, 0])
            cube([diam_rosca, largo_rosca, espesor_lam]);
        media_rosca();
    }
}


/* =========================
   RESULTADO
========================= */

if (parte == "Macho") macho();
if (parte == "Hembra") hembra();
if (parte == "Pieza3") pieza3();
