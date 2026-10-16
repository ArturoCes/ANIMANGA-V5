package com.salesianos.triana.animanga;

import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.order.CardValidator;
import com.salesianos.triana.animanga.order.OrderStatus;
import com.salesianos.triana.animanga.storage.ImageValidator;
import com.salesianos.triana.animanga.storage.StorageException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.YearMonth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DisplayName("Tests unitarios")
class UnitTests {

    @Nested
    @DisplayName("Validación de tarjetas")
    class Cards {
        private final YearMonth now = YearMonth.of(2026, 10);

        @Test
        void aceptaTarjetasValidasYDevuelveLosUltimosDigitos() {
            assertThat(CardValidator.validate("4242 4242 4242 4242", "12/28", "123", now)).isEqualTo("4242");
            assertThat(CardValidator.validate("5555-5555-5555-4444", "10/26", "1234", now)).isEqualTo("4444");
        }

        @Test
        void rechazaNumeroCaducidadYCvcIncorrectos() {
            assertThatThrownBy(() -> CardValidator.validate("4242424242424241", "12/28", "123", now))
                    .isInstanceOf(ApiException.class).hasMessageContaining("número");
            assertThatThrownBy(() -> CardValidator.validate("4242424242424242", "09/26", "123", now))
                    .hasMessageContaining("caducada");
            assertThatThrownBy(() -> CardValidator.validate("4242424242424242", "13/28", "123", now))
                    .hasMessageContaining("no es válida");
            assertThatThrownBy(() -> CardValidator.validate("4242424242424242", "12/28", "12", now))
                    .hasMessageContaining("CVC");
        }
    }

    @Nested
    @DisplayName("Estados de pedido")
    class Statuses {
        @Test
        void soloPermiteLasTransicionesDelFlujo() {
            assertThat(OrderStatus.PAID.canChangeTo(OrderStatus.SHIPPED)).isTrue();
            assertThat(OrderStatus.PAID.canChangeTo(OrderStatus.CANCELLED)).isTrue();
            assertThat(OrderStatus.SHIPPED.canChangeTo(OrderStatus.DELIVERED)).isTrue();
            assertThat(OrderStatus.PAID.canChangeTo(OrderStatus.DELIVERED)).isFalse();
            assertThat(OrderStatus.SHIPPED.canChangeTo(OrderStatus.CANCELLED)).isFalse();
            assertThat(OrderStatus.DELIVERED.canChangeTo(OrderStatus.PAID)).isFalse();
            assertThat(OrderStatus.CANCELLED.canChangeTo(OrderStatus.PAID)).isFalse();
        }
    }

    @Nested
    @DisplayName("Imágenes")
    class Images {
        @Test
        void rechazaNombresPeligrosos() {
            assertThatThrownBy(() -> ImageValidator.checkName("../secreto.jpg")).isInstanceOf(StorageException.class);
            assertThatThrownBy(() -> ImageValidator.checkName("a/b.jpg")).isInstanceOf(StorageException.class);
            ImageValidator.checkName("portada-1.jpg");
        }

        @Test
        void detectaElTipoRealPorElContenido() {
            byte[] png = {(byte) 0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n', 0, 0, 0, 0x0d, 'I', 'H', 'D', 'R'};
            assertThat(ImageValidator.validate(png, "foto.jpg")).isEqualTo("image/png");
            assertThatThrownBy(() -> ImageValidator.validate("<script>".getBytes(), "foto.jpg"))
                    .isInstanceOf(StorageException.class);
        }
    }
}
