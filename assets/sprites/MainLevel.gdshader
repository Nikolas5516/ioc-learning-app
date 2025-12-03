shader_type canvas_item;

// Aici definim un parametru care va apărea în Inspector
// Poți trage de slider între 0.0 (subțire) și 5.0 (foarte gros)
uniform float grosime : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    // Calculăm cât de departe căutăm vecinii, bazat pe grosime
    vec2 size = TEXTURE_PIXEL_SIZE * grosime;

    // Algoritm de "Dilație" (Îngroșare):
    // Verificăm pixelul central ȘI cei 8 vecini din jur (sus, jos, stânga, dreapta și colțurile).
    // Căutăm cea mai "întunecată" valoare (min) din acea zonă.
    // Dacă imaginea originală are linii negre (valoare 0.0) pe fundal alb (1.0),
    // funcția 'min' va găsi 0.0 dacă există vreo urmă de linie neagră în apropiere.

    float min_val = texture(TEXTURE, UV).r; // Centru
    min_val = min(min_val, texture(TEXTURE, UV + vec2(0.0, -size.y)).r); // N
    min_val = min(min_val, texture(TEXTURE, UV + vec2(0.0, size.y)).r);  // S
    min_val = min(min_val, texture(TEXTURE, UV + vec2(-size.x, 0.0)).r); // V
    min_val = min(min_val, texture(TEXTURE, UV + vec2(size.x, 0.0)).r);  // E
    // Colțuri (pentru rotunjire mai frumoasă)
    min_val = min(min_val, texture(TEXTURE, UV + vec2(-size.x, -size.y)).r);
    min_val = min(min_val, texture(TEXTURE, UV + vec2(size.x, size.y)).r);
    min_val = min(min_val, texture(TEXTURE, UV + vec2(-size.x, size.y)).r);
    min_val = min(min_val, texture(TEXTURE, UV + vec2(size.x, -size.y)).r);

    // INVERSARE MAGICĂ (la fel ca înainte):
    // Dacă 'min_val' e aproape de 0 (negru), 'alpha_final' devine aproape de 1 (opac).
    float alpha_final = 1.0 - min_val;

    // TĂIERE (Threshold):
    // Facem marginea tăioasă. Fără asta, marginile ar fi cețoase/gri.
    // Orice nu e perfect transparent devine perfect opac.
    if (alpha_final > 0.1) {
        alpha_final = 1.0;
    } else {
        alpha_final = 0.0;
    }

    // Setăm culoarea finală: ALB PUR + Alpha-ul calculat și îngroșat
    COLOR = vec4(1.0, 1.0, 1.0, alpha_final);
}