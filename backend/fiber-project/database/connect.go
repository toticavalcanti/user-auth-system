package database

import (
	"fiber-project/models"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	// Imprime o diretório atual para debug
	currentDir, err := os.Getwd()
	if err != nil {
		log.Printf("Error getting current directory: %v", err)
	}
	log.Printf("Current directory: %s", currentDir)

	// Tenta carregar .env do diretório atual e do diretório pai
	envPaths := []string{
		".env",
		filepath.Join(currentDir, ".env"),
	}

	for _, path := range envPaths {
		if err := godotenv.Load(path); err != nil {
			log.Printf("Could not load .env from %s: %v", path, err)
		} else {
			log.Printf("Successfully loaded .env from %s", path)
			break
		}
	}

	// Obtém a variável de ambiente para a conexão DSN
	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		log.Printf("Trying to set DSN manually...")
		dsn = "root:mysql0401@/fluent_admin?charset=utf8mb4&parseTime=True&loc=Local"
		os.Setenv("DB_DSN", dsn)
	}

	log.Printf("Using DSN: %s", dsn)

	// Abre a conexão com o banco de dados
	connection, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	DB = connection

	// Faz a migração automática dos modelos de User e PasswordReset
	if err = connection.AutoMigrate(&models.User{}, &models.PasswordReset{}); err != nil {
		log.Fatalf("Failed to auto migrate: %v", err)
	}

	fmt.Println("Database connection successful!")
}
