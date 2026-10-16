package com.salesianos.triana.animanga.order;

import com.salesianos.triana.animanga.common.ApiException;

import java.time.YearMonth;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Validación de la tarjeta de la pasarela simulada (no se cobra nada). */
public final class CardValidator {

    private static final Pattern EXPIRY = Pattern.compile("^(\\d{2})/(\\d{2})$");

    private CardValidator() {}

    /** Valida número, caducidad y CVC; devuelve los 4 últimos dígitos. */
    public static String validate(String number, String expiry, String cvc, YearMonth now) {
        String digits = number == null ? "" : number.replaceAll("[\\s-]", "");
        if (!digits.matches("\\d{13,19}") || !passesLuhn(digits)) {
            throw ApiException.badRequest("El número de tarjeta no es válido");
        }
        Matcher m = EXPIRY.matcher(expiry == null ? "" : expiry.trim());
        if (!m.matches()) throw ApiException.badRequest("La fecha de caducidad debe tener el formato MM/AA");
        int month = Integer.parseInt(m.group(1));
        if (month < 1 || month > 12) throw ApiException.badRequest("La fecha de caducidad no es válida");
        if (YearMonth.of(2000 + Integer.parseInt(m.group(2)), month).isBefore(now)) {
            throw ApiException.badRequest("La tarjeta está caducada");
        }
        if (cvc == null || !cvc.matches("\\d{3,4}")) throw ApiException.badRequest("El CVC no es válido");
        return digits.substring(digits.length() - 4);
    }

    public static boolean passesLuhn(String digits) {
        int sum = 0;
        boolean doubleIt = false;
        for (int i = digits.length() - 1; i >= 0; i--) {
            int n = digits.charAt(i) - '0';
            if (doubleIt) {
                n *= 2;
                if (n > 9) n -= 9;
            }
            sum += n;
            doubleIt = !doubleIt;
        }
        return sum % 10 == 0;
    }
}
