import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class Main {

public static void main(String[] args) throws Exception {
    String mysqlHost = getEnv("MYSQL_HOST", "localhost");
    String mysqlPort = getEnv("MYSQL_PORT", "3306");
    String mysqlDb   = getEnv("MYSQL_DATABASE", "mecaniqa");
    String redisHost = getEnv("REDIS_HOST", "localhost");
    String redisPort = getEnv("REDIS_PORT", "6379");

    System.out.println("=========================================");
    System.out.println(" MecaniQA Tech - Servico Java (BOA VISTA)");
    System.out.println("=========================================");
    System.out.println("Aplicacao Java em execucao dentro do container!");
    System.out.println("Configuracao MySQL -> host=" + mysqlHost
            + " port=" + mysqlPort + " db=" + mysqlDb);
    System.out.println("Configuracao Redis -> host=" + redisHost
            + " port=" + redisPort);

    HttpServer server = HttpServer.create(
            new InetSocketAddress("0.0.0.0", 8080),
            0
    );

    server.createContext("/", Main::handleRequest);

    server.setExecutor(null);
    server.start();

    System.out.println("Servidor HTTP iniciado na porta 8080...");
}

private static void handleRequest(HttpExchange exchange) throws IOException {
    String response =
            "MecaniQA-BOA-VISTA - Aplicacao Java funcionando no Docker/Kubernetes!\n";

    byte[] responseBytes = response.getBytes(StandardCharsets.UTF_8);

    exchange.getResponseHeaders().set(
            "Content-Type",
            "text/plain; charset=UTF-8"
    );

    exchange.sendResponseHeaders(200, responseBytes.length);

    try (OutputStream output = exchange.getResponseBody()) {
        output.write(responseBytes);
    }
}

private static String getEnv(String key, String defaultValue) {
    String value = System.getenv(key);
    return (value == null || value.isEmpty()) ? defaultValue : value;
}

}