CREATE DATABASE IF NOT EXISTS mecaniqa;
USE mecaniqa;

CREATE TABLE IF NOT EXISTS oficinas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS veiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    oficina_id INT,
    FOREIGN KEY (oficina_id) REFERENCES oficinas(id)
);

INSERT INTO oficinas (nome, cidade) VALUES ('Oficina Central', 'Boa Vista');
