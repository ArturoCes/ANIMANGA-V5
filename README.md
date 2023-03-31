# ANIMANGA-V4-BACKEND
<img src="https://img.shields.io/badge/Spring--Framework-5.7-green"/> <img src="https://img.shields.io/badge/Apache--Maven-3.8.6-blue"/> <img src="https://img.shields.io/badge/Java-17.0-brightgreen"/>

<div>
 <img src="https://niixer.com/wp-content/uploads/2020/11/spring-boot.png" width="500" alt="Spring Logo"/>

</div>
Una API que gestiona la compra y venta de mangas.

**Tecnología y lenguaje utilizado:**
Para el desarrollo de la aplicación, se han utilizado los siguientes elementos:

- **Spring Boot** como framework.
- **InteliJIdea** como IDE.
- **Java** para el desarrollo del código que atiende las peticiones a la API.
- **PostMan** para las pruebas de las diferentes peticiones.
- **Swagger UI** para la documentación.

## Pruebas:
Para poder probar la API, tendremos dos vías principales:
- **Documentación del proyecto en Swagger**: Accederemos a través de la ruta **http://localhost:8080/swagger-ui.html**. Aquí, podremos probar todos los endpoints
  disponibles en la API.
- **Aplicación de Postman**: Dentro del proyecto, se encuentra el archivo **animanga_collection.json**. Este archivo, podremos importarlo en las colecciones de Postman.
- **Base de datos PostgreSql**: Accederemos a través de un entorno como PgAdmin, o consultarlo directamente con docker Desktop,podremos acceder a la base de datos para comprobar la información ahí guardada, y, una vez 
  realicemos alguna petición mediante Postman o Swagger, veremos cómo se actualiza esta.
  


## Organización del proyecto:
En la carpeta principal nos encontramos diferentes elementos a tener en cuenta:
- **src**: Es la carpeta donde se aloja todo el código fuente utilizado en el desarrollo de la aplicación.
- **animanga_collection.json**: Es una colección de Postman, que podremos importar en dicho programa, y que nos permitirá acceder a los distintos endpoints de la aplicación.

