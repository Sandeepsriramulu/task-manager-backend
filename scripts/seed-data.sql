USE taskdb;

CREATE TABLE IF NOT EXISTS tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tasks (title, description, completed)
VALUES
('Learn Docker', 'Complete Docker fundamentals', false),
('Learn Jenkins', 'Build a Jenkins CI/CD pipeline', false),
('Learn Ansible', 'Automate application deployment', false);
