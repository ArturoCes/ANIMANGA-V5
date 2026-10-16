package com.salesianos.triana.animanga.mail;

import com.salesianos.triana.animanga.config.AppProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Envía los emails de la cuenta. Si hay un servidor SMTP configurado
 * (variables SPRING_MAIL_HOST, SPRING_MAIL_USERNAME...) se envían de verdad;
 * si no, se escriben en el log para poder probar el flujo en local.
 */
@Slf4j
@Service
public class MailService {

    public record Mail(String to, String subject, String body) {}

    private final ObjectProvider<JavaMailSender> mailSender;
    private final AppProperties props;
    /** Últimos emails generados (útil en desarrollo y en los tests). */
    private final List<Mail> outbox = Collections.synchronizedList(new ArrayList<>());

    public MailService(ObjectProvider<JavaMailSender> mailSender, AppProperties props) {
        this.mailSender = mailSender;
        this.props = props;
    }

    public void sendVerification(String to, String name, String token) {
        String link = props.frontendUrl() + "/?verify=" + token;
        send(to, "Confirma tu email en Animanga", """
                Hola %s,

                Gracias por registrarte en Animanga. Confirma tu email desde este enlace:
                %s

                El enlace caduca en 48 horas.
                """.formatted(name, link));
    }

    public void sendPasswordReset(String to, String name, String token) {
        String link = props.frontendUrl() + "/?reset=" + token;
        send(to, "Restablece tu contraseña de Animanga", """
                Hola %s,

                Hemos recibido una solicitud para cambiar tu contraseña. Puedes hacerlo aquí:
                %s

                El enlace caduca en 1 hora. Si no has sido tú, ignora este mensaje.
                """.formatted(name, link));
    }

    public List<Mail> outbox() {
        return List.copyOf(outbox);
    }

    public void clearOutbox() {
        outbox.clear();
    }

    void send(String to, String subject, String body) {
        outbox.add(new Mail(to, subject, body));
        if (outbox.size() > 50) outbox.remove(0);

        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null) {
            log.info("[EMAIL no enviado: SMTP sin configurar] Para: {} | Asunto: {}\n{}", to, subject, body);
            return;
        }
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(props.mail().from());
            message.setTo(to);
            message.setSubject(subject);
            message.setText(body);
            sender.send(message);
        } catch (MailException e) {
            log.warn("No se pudo enviar el email a {}: {}", to, e.getMessage());
        }
    }
}
