package database

import (
	"fiber-project/models"
	"fmt"
	"log"
	"os"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		log.Fatal("DB_DSN environment variable is not set")
	}

	connection, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	DB = connection

	err = connection.AutoMigrate(&models.User{}, &models.PasswordReset{})
	if err != nil {
		log.Fatalf("Failed to auto migrate: %v", err)
	}

	fmt.Println("Database connection successful!")
}
